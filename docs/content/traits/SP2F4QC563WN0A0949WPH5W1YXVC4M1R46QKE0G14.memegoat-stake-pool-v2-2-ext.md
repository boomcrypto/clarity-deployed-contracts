---
title: "Trait memegoat-stake-pool-v2-2-ext"
draft: true
---
```
;;
;;  MEMEGOAT STAKING POOL EXTENSION CONTRACT
;;
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-ZERO-AMOUNT (err u2001))
(define-constant ERR-INVALID-TOKEN (err u3002))
(define-constant ERR-NO-STAKE-FOUND (err u3004))


(define-constant ERR-ALREADY-UNSTAKED (err u5000))
(define-constant ERR-ALREADY-CLAIMED (err u6000))

;; DATA MAPS AND VARS
(define-data-var contract-owner principal tx-sender)
(define-data-var paused bool false)
(define-constant PRECISION (pow u10 u18))

(define-map user-has-unstaked 
  {user-addr: principal}
  bool
)

(define-map user-has-claimed 
  {user-addr: principal}
  bool
)

(define-map approved-token
  {token: principal}
  bool
)

;; READ ONLY CALLS

(define-read-only (is-paused)
    (var-get paused)
)

(define-read-only (check-if-unstaked (user-addr principal)) 
  (default-to false (map-get? user-has-unstaked { user-addr: user-addr }))
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-has-claimed { user-addr: user-addr }))
)

(define-read-only (check-if-approved (token principal)) 
  (default-to false (map-get? approved-token { token: token }))
)


(define-public (pause (new-paused bool))
  (begin 
    (try! (check-is-owner))
    (ok (var-set paused new-paused))
  )
)

(define-public (update-stake-status (addr principal) (status bool))
  (begin 
    (try! (check-is-owner))
    (ok  (map-set user-has-unstaked {user-addr: addr} status)  )
  )
)

(define-public (update-claim-status (addr principal) (status bool))
  (begin 
    (try! (check-is-owner))
    (ok  (map-set user-has-claimed {user-addr: addr} status)  )
  )
)

(define-public (approve-token (token principal) (status bool))
  (begin 
    (try! (check-is-owner))
    (ok  (map-set approved-token {token: token} status)  )
  )
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


;; @desc unstake: withdraws stake from contract
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (unstake (stake-id uint) (stake-token <ft-trait>)) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (contract-call? .memegoat-staking-pool-v2-1 get-user-stake-has-stake stake-id tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-withdraw-stake stake-id tx-sender stake-token))
    (ok true)
  )
)

;; @desc claim-reward: withdraws rewards from contract
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (claim-reward (stake-id uint) (reward-token <ft-trait>)) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (contract-call? .memegoat-staking-pool-v2-1 get-user-stake-has-stake stake-id tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-claim-reward stake-id tx-sender reward-token))
    (ok true)
  )
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (do-withdraw-stake (stake-id uint) (user-addr principal) (stake-token <ft-trait>))
  (begin 
    (let
      ;; get variables and calculate rewards
      (
        (stake-pool (try! (contract-call? .memegoat-staking-pool-v2-1 get-stake-pool stake-id)))
        (stake-token-contract (get stake-token stake-pool))
        (user-stake (try! (contract-call? .memegoat-staking-pool-v2-1 get-user-staking-data stake-id user-addr)))
        (amount-staked (get amount-staked user-stake))
        (unstaked (check-if-unstaked user-addr))
      )
      ;; run checks 
      (asserts! (is-eq stake-token-contract (contract-of stake-token)) ERR-INVALID-TOKEN)
      (asserts! (not unstaked) ERR-ALREADY-UNSTAKED)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-stakepool-vault-v1 transfer-ft stake-token amount-staked user-addr)))

      ;; update records
      (map-set user-has-unstaked {user-addr: user-addr} true)   
    )
    (ok true)
  )
)

(define-private (do-claim-reward (stake-id uint) (user-addr principal) (reward-token <ft-trait>))
  (begin 
    (let
      ;; get variables and calculate rewards
      (
        (stake-pool (try! (contract-call? .memegoat-staking-pool-v2-1 get-stake-pool stake-id)))
        (reward-token-contract (get reward-token stake-pool))
        (end-block (get end-block stake-pool))
        (new-reward-per-token-staked (do-calculate-reward stake-id))
        (user-stake (try! (contract-call? .memegoat-staking-pool-v2-1 get-user-staking-data stake-id user-addr)))
        (reward (do-calculate-user-rewards stake-id  user-addr new-reward-per-token-staked))
        (claimed (check-if-claimed user-addr))
      )

      ;; run checks 
      (asserts! (check-if-approved (contract-of reward-token)) ERR-INVALID-TOKEN)
      (asserts! (> reward u0) ERR-ZERO-AMOUNT)
      (asserts! (not claimed) ERR-ALREADY-CLAIMED)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-stakepool-vault-v1 transfer-ft reward-token reward user-addr)))   

      ;; update records
      (map-set user-has-claimed {user-addr: user-addr} true)
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
      (stake-pool (unwrap-panic (contract-call? .memegoat-staking-pool-v2-1 get-stake-pool stake-id)))
      (stake-token-contract (get stake-token stake-pool))
      (reward-per-token-staked (get reward-per-token-staked stake-pool))
      (reward-per-block (get reward-per-block stake-pool))
      (end-block (get end-block stake-pool))
      (total-staked (get total-staked stake-pool))
    )
    (+ reward-per-token-staked (do-calculate end-block reward-per-block end-block total-staked))
  ) 
)

(define-private (do-calculate-user-rewards (stake-id uint) (user-addr principal) (reward-per-token-staked uint))
  (if (contract-call? .memegoat-staking-pool-v2-1 get-user-stake-has-stake stake-id user-addr)
    (let
      (
        (user-stake (unwrap-panic (contract-call? .memegoat-staking-pool-v2-1 get-user-staking-data stake-id user-addr)))
        (stake-pool (unwrap-panic (contract-call? .memegoat-staking-pool-v2-1 get-stake-pool stake-id)))
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


(define-private (last-block-reward-applicable (end-block uint))
  (if (< block-height end-block)
  block-height
  end-block
  )
)

```
