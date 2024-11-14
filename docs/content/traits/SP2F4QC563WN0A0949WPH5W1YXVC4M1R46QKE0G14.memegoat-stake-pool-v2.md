---
title: "Trait memegoat-stake-pool-v2"
draft: true
---
```
;;
;;  MEMEGOAT STAKING POOL CONTRACT
;;

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-BALANCE-EXCEEDED (err u2000))
(define-constant ERR-ZERO-AMOUNT (err u2001))
(define-constant ERR-INVALID-DURATION (err u3000))
(define-constant ERR-INVALID-STAKE-ID (err u3001))
(define-constant ERR-INVALID-TOKEN (err u3002))
(define-constant ERR-INVALID-REWARD-PER-BLOCK (err u3003))
(define-constant ERR-NO-STAKE-FOUND (err u3004))
(define-constant ERR-STAKE-ENDED (err u4000))

;; DATA MAPS AND VARS
(define-data-var contract-owner principal tx-sender)
(define-data-var paused bool false)
(define-data-var stake-nonce uint u0)
(define-data-var pool-fee uint u2000000)

(define-constant PRECISION (pow u10 u9))
(define-constant OLD-PRECISION (pow u10 u18))

;; @desc map to store stake pool data
(define-map stake-pool-map
  {stake-id: uint}
  {
    id: uint,
    stake-token: principal,
    reward-token: principal,
    reward-amount: uint,
    reward-per-block: uint,
    total-staked: uint,
    start-block: uint,
    end-block: uint,
    last-update-block: uint,
    reward-per-token-staked: uint,
    owner: principal,
    participants: uint,
    verified: bool,
  }
)

;; @desc map to store user staking data
(define-map user-stake-map
  {user-addr: principal, stake-id: uint}
  {
    amount-staked: uint,
    stake-rewards: uint,
    reward-per-token-staked: uint
  }
)

;; @desc map to store user staking status
(define-map has-stake {user-addr: principal, stake-id: uint} bool)

;; READ-ONLY CALLS

;; @desc is-paused: contract status
;; @returns (boolean)
(define-read-only (is-paused)
    (var-get paused)
)

;; @desc get-stake-nonce: returns stake nonce
;; @returns (uint)
(define-read-only (get-stake-nonce)
  (var-get stake-nonce)
)

;; @desc get-stake-pool: gets the stake pool
;; @params stake-id
;; @returns (response stake-pool)
(define-read-only (get-stake-pool (stake-id uint))
    (ok (unwrap! (get-stake-pool-exists stake-id) ERR-INVALID-STAKE-ID))
)

;; @desc get-stake-pool-exist: checks if stake pool exists
;; @params stake-id
;; @returns (option stake-pool)
(define-read-only (get-stake-pool-exists (stake-id uint))
    (map-get? stake-pool-map { stake-id: stake-id }) 
)

;; @desc get-stake-staking-data: get user stake data
;; @params user-addr
;; @returns (response stake-data)
(define-read-only (get-user-staking-data (stake-id uint) (user-addr principal))
    (ok (unwrap! (get-user-staking-data-exists stake-id  user-addr ) ERR-NO-STAKE-FOUND))
)

;; @desc get-stake-staking-data-exists: check if user stake data exists
;; @params user-addr
;; @returns (option stake-data)
(define-read-only (get-user-staking-data-exists (stake-id uint) (user-addr principal)) 
  (map-get? user-stake-map {user-addr: user-addr, stake-id: stake-id})
)

;; @desc get-user-has-stake: check if user has active stake
;; @params user-addr
;; @returns (boolean)
(define-read-only (get-user-stake-has-stake (stake-id uint) (user-addr principal)) 
  (default-to false (map-get? has-stake {user-addr: user-addr, stake-id: stake-id}))
)

;; @desc calculate-rewards: calculate rewards based on user staked amount 
;; @params user-addr
;; @returns (boolean)
(define-read-only (calculate-rewards (stake-id uint) (user-addr principal))
  (let
    (
      (reward-per-token-staked (do-calculate-reward stake-id))
    )
    (do-calculate-user-rewards stake-id user-addr reward-per-token-staked)
  )
)

;; @desc get-pool-fee: returns the fee for creating a pool
;; @returns fee
(define-read-only (get-pool-fee) 
  (var-get pool-fee)
)

;; MANAGEMENT CALLS

;; @desc set-contract-owner: sets owner
;; @requirement only callable by current owner
;; @params owner
;; @returns (response boolean)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

;; @desc pause: updates contracts paused state
;; @requirement only callable by current owner
;; @params new-paused
;; @returns (response boolean)
(define-public (pause (new-paused bool))
  (begin 
    (try! (check-is-owner))
    (ok (var-set paused new-paused))
  )
)

;; @desc set-pool-fee: updates fee for creating pool
;; @requirement only callable by current owner
;; @params amount
;; @returns (response boolean)
(define-public (set-fee (amount uint)) 
  (begin 
    (try! (check-is-owner))
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    (ok (var-set pool-fee amount))
  )
)

;; @desc verify-pool: verify pool as original
;; @requirement only callable by current owner
;; @params status
;; @returns (response boolean)
(define-public (verify-pool (stake-id uint) (status bool)) 
  (begin 
    (try! (check-is-owner))
    (let 
      (
        (stake-pool (try! (get-stake-pool stake-id)))
        (updated-stake-pool (merge stake-pool {
          verified: status
        }))
      )
      ;; update stake pool
      (map-set stake-pool-map {stake-id: stake-id} updated-stake-pool)
    )
    (ok true)
  )
)

;; @desc port-pools: move pools
(define-public (move-pool (stake-id uint))
  (begin 
    (try! (check-is-owner))
    (let
      (
        (next-stake-id (get-next-stake-id))
        (stake-pool (try! (contract-call? .memegoat-stake-pool-v1 get-stake-pool stake-id)))
      )
      (map-set stake-pool-map { stake-id: stake-id }
        {
          id: stake-id,
          stake-token: (get stake-token stake-pool),
          reward-token: (get reward-token stake-pool),
          reward-amount: (update-precision (get reward-amount stake-pool)),
          reward-per-block: (update-precision (get reward-per-block stake-pool)),
          total-staked: (update-precision (get total-staked stake-pool)),
          start-block: (get start-block stake-pool),
          end-block: (get end-block stake-pool),
          last-update-block: (get last-update-block stake-pool),
          reward-per-token-staked: (update-precision (get reward-per-token-staked stake-pool)),
          owner: (get owner stake-pool),
          participants: (get participants stake-pool),
          verified: false,
        }
      )
    )
    (ok true)
  )
)

;; @desc move-user-records: move records
(define-public (move-user-records (stake-id uint) (users (list 200 principal)))
  (begin 
    (try! (check-is-owner))
    (let
      (
        (next-stake-id (get-next-stake-id))
        (stake-pool (try! (contract-call? .memegoat-stake-pool-v1 get-stake-pool stake-id)))
      )
      (fold move users stake-id)
    )
    (ok true)
  )
)

(define-private (move (user principal) (stake-id uint))
  (let
    (
      (user-stake (unwrap-panic (contract-call? .memegoat-stake-pool-v1 get-user-staking-data stake-id user)))
    )

    (map-set has-stake { user-addr: user, stake-id: stake-id } true)
    (map-set user-stake-map 
      { user-addr: user, stake-id: stake-id } 
      {
        amount-staked: (update-precision (get amount-staked user-stake)), 
        stake-rewards: (update-precision (get stake-rewards user-stake)),
        reward-per-token-staked: (update-precision (get reward-per-token-staked user-stake))
      }
    )
    stake-id
  )
)

;; PUBLIC CALLS

;; @desc create-pool: creates staking pool
;; @params stake-token 
;; @params reward-token  
;; @params reward-amount
;; @params start-block
;; @params end-block
;; @params reward-per-block
;; @returns (response stake-id)
(define-public (create-pool 
    (stake-token <ft-trait>) 
    (reward-token <ft-trait>) 
    (reward-amount uint)
    (start-block uint)
    (end-block uint)
    (reward-per-block uint)
  )
  (let
    (
      (next-stake-id (get-next-stake-id))
      (sender tx-sender)
    )
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (and (> reward-amount u0) (> reward-per-block u0) (> reward-amount reward-per-block)) ERR-ZERO-AMOUNT)
    (asserts! (and (> start-block block-height) (> end-block start-block)) ERR-INVALID-DURATION)
    (asserts! (<= reward-per-block (/ reward-amount (- end-block start-block))) ERR-INVALID-REWARD-PER-BLOCK)

    ;; transfer reward-token to vault
    (try! (contract-call? reward-token transfer reward-amount sender .memegoat-stakepool-vault-v1 none)) 

    ;; transfer stx to treasury
    (try! (stx-transfer? (var-get pool-fee) tx-sender .memegoat-treasury-v1))

    ;; update new stake data  
    (map-set stake-pool-map { stake-id: next-stake-id }
    {
      id: next-stake-id,
      stake-token: (contract-of stake-token),
      reward-token: (contract-of reward-token),
      reward-amount: (to-precision reward-amount reward-token),
      reward-per-block: (to-precision reward-per-block reward-token),
      total-staked: u0,
      start-block: start-block,
      end-block: end-block,
      last-update-block: start-block,
      reward-per-token-staked: u0,
      owner: sender,
      participants: u0,
      verified: false,
    })
    (ok next-stake-id)    
  )
)

;; @desc stake: transfers amount to be staked.
;; @params amount
;; @returns (response boolean)
(define-public (stake (stake-id uint) (amount uint) (stake-token <ft-trait>))
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    ;; transfer stake token to vault
    (try! (do-stake stake-id tx-sender amount stake-token))
    (ok true)
  )
)

;; @desc unstake: withdraws stake from contract
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (unstake (stake-id uint) (amount uint) (stake-token <ft-trait>)) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (get-user-stake-has-stake stake-id tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-withdraw-stake stake-id tx-sender amount stake-token))
    (ok true)
  )
)

;; @desc claim-reward: withdraws rewards from contract
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (claim-reward (stake-id uint) (reward-token <ft-trait>)) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (get-user-stake-has-stake stake-id tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-claim-reward stake-id tx-sender reward-token))
    (ok true)
  )
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (do-stake (stake-id uint) (user-addr principal) (amount uint) (stake-token <ft-trait>))
  (begin
    (let
      ;; get variables
      (
        (user-has-stake (get-user-stake-has-stake stake-id user-addr))
        (stake-pool (try! (get-stake-pool stake-id)))
        (stake-token-contract (get stake-token stake-pool))
        (total-staked (get total-staked stake-pool))
        (participants (get participants stake-pool))
        (end-block (get end-block stake-pool))
        (new-reward-per-token-staked (do-calculate-reward stake-id))
        (precison-amount (to-precision amount stake-token))
        (updated-stake-pool (merge stake-pool {
          total-staked: (+ total-staked precison-amount),
          participants: (if user-has-stake participants (+ participants u1)),
          last-update-block: block-height,
          reward-per-token-staked: new-reward-per-token-staked
        }))
      )

      (asserts! (> amount u0) ERR-ZERO-AMOUNT)
      (asserts! (is-eq stake-token-contract (contract-of stake-token)) ERR-INVALID-TOKEN)
      (asserts! (< block-height end-block) ERR-STAKE-ENDED)

      ;; check for stake
      (if user-has-stake
        (let
          ;; calculate rewards and update stake data
          (
            (user-stake (try! (get-user-staking-data stake-id user-addr)))
            (amount-staked (get amount-staked user-stake))
            (user-stake-updated (merge user-stake {
              amount-staked: (+ amount-staked precison-amount),
              stake-rewards: (do-calculate-user-rewards stake-id user-addr new-reward-per-token-staked),
              reward-per-token-staked: new-reward-per-token-staked,
            }))
          )
          (map-set user-stake-map {user-addr: user-addr, stake-id: stake-id} user-stake-updated)
        )
        
        (begin
          ;; create new stake data for user
          (map-set has-stake { user-addr: user-addr, stake-id: stake-id } true)
          (map-set user-stake-map 
            { user-addr: user-addr, stake-id: stake-id } 
            {
              amount-staked: precison-amount, 
              stake-rewards: u0,
              reward-per-token-staked: new-reward-per-token-staked
            }
          )
        )
      )

      ;; transfer to vault
      (try! (contract-call? stake-token transfer amount tx-sender .memegoat-stakepool-vault-v1 none)) 

      ;; update stake pool
      (map-set stake-pool-map {stake-id: stake-id} updated-stake-pool)
    )
    (ok true)
  )
)

(define-private (do-withdraw-stake (stake-id uint) (user-addr principal) (amount uint) (stake-token <ft-trait>))
  (begin 
    (let
      ;; get variables and calculate rewards
      (
        (stake-pool (try! (get-stake-pool stake-id)))
        (stake-token-contract (get stake-token stake-pool))
        (total-staked (get total-staked stake-pool))
        (end-block (get end-block stake-pool))
        (new-reward-per-token-staked (do-calculate-reward stake-id))
        (precison-amount (to-precision amount stake-token))
        (updated-stake-pool (merge stake-pool {
          total-staked: (- total-staked precison-amount),
          last-update-block: (last-block-reward-applicable end-block),
          reward-per-token-staked: new-reward-per-token-staked
        }))
        (user-stake (try! (get-user-staking-data stake-id user-addr)))
        (amount-staked (get amount-staked user-stake))
        (updated-user-stake (merge user-stake {
          amount-staked: (- amount-staked precison-amount),
          stake-rewards: (do-calculate-user-rewards stake-id user-addr new-reward-per-token-staked),
          reward-per-token-staked: new-reward-per-token-staked,
        }))
      )

      ;; run checks 
      (asserts! (is-eq stake-token-contract (contract-of stake-token)) ERR-INVALID-TOKEN)
      (asserts! (> precison-amount u0) ERR-ZERO-AMOUNT)
      (asserts! (<= precison-amount amount-staked) ERR-BALANCE-EXCEEDED)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-stakepool-vault-v1 transfer-ft stake-token (from-precision precison-amount stake-token) user-addr)))   

      ;; update records
      (map-set user-stake-map {user-addr: user-addr, stake-id: stake-id} updated-user-stake)
      (map-set stake-pool-map {stake-id: stake-id} updated-stake-pool)
    )
    (ok true)
  )
)

(define-private (do-claim-reward (stake-id uint) (user-addr principal) (reward-token <ft-trait>))
  (begin 
    (let
      ;; get variables and calculate rewards
      (
        (stake-pool (try! (get-stake-pool stake-id)))
        (reward-token-contract (get reward-token stake-pool))
        (end-block (get end-block stake-pool))
        (new-reward-per-token-staked (do-calculate-reward stake-id))
        (updated-stake-pool (merge stake-pool {
          last-update-block: (last-block-reward-applicable end-block),
          reward-per-token-staked: new-reward-per-token-staked
        }))
        (user-stake (try! (get-user-staking-data stake-id user-addr)))
        (reward (do-calculate-user-rewards stake-id  user-addr new-reward-per-token-staked))
        (reward-amount (from-precision reward reward-token))
        (updated-user-stake (merge user-stake {
          stake-rewards: u0,
          reward-per-token-staked: new-reward-per-token-staked,
        }))
      )

      ;; run checks 
      (asserts! (is-eq reward-token-contract (contract-of reward-token)) ERR-INVALID-TOKEN)
      (asserts! (> reward-amount u0) ERR-ZERO-AMOUNT)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-stakepool-vault-v1 transfer-ft reward-token reward-amount user-addr)))   

      ;; update records
      (map-set user-stake-map {user-addr: user-addr, stake-id: stake-id} updated-user-stake)
      (map-set stake-pool-map {stake-id: stake-id} updated-stake-pool)
    )
    (ok true)
  )
)

(define-private (do-calculate 
  (last-update-block uint) 
  (reward-per-block uint)
  (end-block uint)
  (total-staked uint)
  )
  (if (> total-staked u0)
    (/ (* (- (last-block-reward-applicable end-block) last-update-block) reward-per-block PRECISION) total-staked)
    u0
  )
)

(define-private (do-calculate-reward (stake-id uint))
  (let
    (
      (stake-pool (unwrap-panic (get-stake-pool stake-id)))
      (stake-token-contract (get stake-token stake-pool))
      (last-update-block (get last-update-block stake-pool))
      (reward-per-token-staked (get reward-per-token-staked stake-pool))
      (reward-per-block (get reward-per-block stake-pool))
      (end-block (get end-block stake-pool))
      (total-staked (get total-staked stake-pool))
    )
    (+ reward-per-token-staked (do-calculate last-update-block reward-per-block end-block total-staked))
  ) 
)

(define-private (do-calculate-user-rewards (stake-id uint) (user-addr principal) (reward-per-token-staked uint))
  (if (get-user-stake-has-stake stake-id user-addr)
    (let
      (
        (user-stake (unwrap-panic (get-user-staking-data stake-id user-addr)))
        (stake-pool (unwrap-panic (get-stake-pool stake-id)))
        (end-block (get end-block stake-pool))
        (amount-staked (get amount-staked user-stake))
        (stake-rewards (get stake-rewards user-stake))
        (user-reward-per-token-staked (get reward-per-token-staked user-stake))
      )
      (+ stake-rewards (/ (* amount-staked (- reward-per-token-staked user-reward-per-token-staked)) PRECISION))
    )
    u0
  )
)

(define-private (get-next-stake-id)
  (let
    (
      (nonce (var-get stake-nonce))
    )
    (var-set stake-nonce (+ nonce u1))
    nonce
  )
)

(define-private (last-block-reward-applicable (end-block uint))
  (if (< block-height end-block)
  block-height
  end-block
  )
)

(define-private (pow-decimals (token <ft-trait>))
  (pow u10 (unwrap-panic (contract-call? token get-decimals)))
)

(define-private (from-precision (amount uint) (token <ft-trait>))
  (/ (* amount (pow-decimals token)) PRECISION)
)

(define-private (to-precision (amount uint) (token <ft-trait>))
  (/ (* amount PRECISION) (pow-decimals token))
)

(define-private (update-precision (amount uint))
  (/ (* amount PRECISION) OLD-PRECISION)
)
```
