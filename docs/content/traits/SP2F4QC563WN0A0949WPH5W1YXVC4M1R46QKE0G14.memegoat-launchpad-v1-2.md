---
title: "Trait memegoat-launchpad-v1-2"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait ft-plus-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)

;; ERRS

(define-constant ERR-INVALID-POOL (err u4001))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u5001))
(define-constant ERR-ZERO-AMOUNT (err u5002))
(define-constant ERR-INVALID-AMOUNT (err u5003))
(define-constant ERR-INVALID-ID (err u5004))
(define-constant ERR-INVALID-ADDRESS (err u5005))
(define-constant ERR-NOT-QUALIFIED (err u5006))
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-BELOW-MIN-PERIOD (err u6000))
(define-constant ERR-LAUNCHPAD-INACTIVE (err u7000))
(define-constant ERR-INVALID-TOKEN (err u7001))
(define-constant ERR-INVALID-LP-TOKEN (err u7002))
(define-constant ERR-TOKEN-LAUNCH-NOT-ENDED (err u7003))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))
(define-constant ERR-TOKEN-IS-VESTED (err u8004))
(define-constant ERR-BELOW-MINIMUM-POOL-ALLOCATION (err u9000))
(define-constant ERR-BELOW-MINIMUM-LISTING-ALLOCATION (err u9001))
(define-constant ERR-BELOW-MINIMUM-CAMPAIGN-ALLOCATION (err u9002))
(define-constant ERR-NO-CAMPAIGN-ALLOCATION (err u9003))


;; DATA MAPS AND VARS

(define-data-var contract-owner principal tx-sender)
(define-data-var launchpad-nonce uint u0)
(define-data-var min-goat-balance uint u200000000000)
(define-data-var goat-token principal .memegoatstx)
(define-data-var paused bool false)
(define-data-var launchpad-fee uint u2)

;; @desc map to stop token launches
(define-map launchpad-map
  {token-launch-id: uint}
  {
    token: principal,
    pool-amount: uint,
    hardcap: uint,
    softcap: uint,
    total-stx-deposited: uint,
    no-of-participants: uint,
    min-stx-deposit: uint,
    max-stx-deposit: uint,
    duration: uint,
    start-block: uint,
    end-block: uint,
    owner: principal,
    is-vested: bool,
    is-listed: bool,
    listing-allocation: uint,
    campaign-allocation: (optional uint),
    campaign-rewards-sent: uint
  }
)

;; @desc map to store token-addr
(define-map launchpad-map-by-token-addr
  {token-addr: principal}
  uint
)

;; @desc map to store user deposits
(define-map users-deposits
    { user-addr: principal, token-launch-id: uint }
    uint
)

;; @desc map to store claim history
(define-map user-claimed 
  { user-addr : principal, token-launch-id: uint }
  bool
)


;; READ-ONLY CALLS

;; @desc is-paused: contract status
;; @returns (boolean)
(define-read-only (is-paused)
    (var-get paused)
)

;; @desc get-token-launch-by-id: gets the token launch by id
;; @params token-launch-id
;; @returns (response launchpad-record)
(define-read-only (get-token-launch-by-id (token-launch-id uint))
  (ok (unwrap! (map-get? launchpad-map {token-launch-id: token-launch-id}) ERR-INVALID-ID))
)

;; @desc get-token-id-launch-by-addr : gets the token id of a token-launch using the token address
;; @params token-addr
;; @returns (response uint)
(define-read-only (get-token-id-launch-by-addr (token-addr <ft-trait>))
  (ok (unwrap! (map-get? launchpad-map-by-token-addr {token-addr: (contract-of token-addr)}) ERR-INVALID-ADDRESS))
)

;; @desc get-user-deposits-exists: checks if user has deposited stx
;; @params user-addr
;; @params token-launch-id
;; @returns (response boolean)
(define-read-only (get-user-deposits-exists (user-addr principal) (token-launch-id uint))
  (map-get? users-deposits {user-addr: user-addr, token-launch-id: token-launch-id})
)

;; @desc get-user-deposits: gets amount of stx deposited by user
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (get-user-deposits (user-addr principal) (token-launch-id uint)) 
  (default-to u0 (get-user-deposits-exists user-addr token-launch-id))
)

;; @desc calculate-allocation: gets the calculated amount of launch tokens allocated to the user
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (calculate-allocation (user-addr principal) (token-launch-id uint))
  (let
    ((user-deposit (get-user-deposits user-addr token-launch-id)))
    (if (> user-deposit u0) 
      (* (unwrap-panic (get-stx-quote token-launch-id)) user-deposit) 
      u0
    )
  )
)

;; @desc check-if-claimed: checks if user has claimed tokens
;; @params user-addr
;; @params token-launch-id
;; @returns (response boolean)
(define-read-only (check-if-claimed (user-addr principal) (token-launch-id uint)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr, token-launch-id: token-launch-id}))
)

;; @desc get-contract-owner: gets owner address
;; @returns (response principal)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; @desc get-stx-quote: gets the current exchange rate of token
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (get-stx-quote (token-launch-id uint))
  (let
    (
      (token-launch (try! (get-token-launch-by-id token-launch-id)))
      (token-pool (get pool-amount token-launch))
      (stx-pool (get total-stx-deposited token-launch))
    )

    (if (> stx-pool u0)
      (ok (/ token-pool stx-pool))
      (ok u0)
    )
  )
)

;; @desc get-launchpad-fee: gets launchpad fee
;; @returns (response uint)
(define-read-only (get-launchpad-fee)
  (var-get launchpad-fee)
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

;; @desc set-launchpad-fee: updates the launchpad-fee
;; @requirement only callable by current owner
;; @params new-fee
;; @returns (response boolean)
(define-public (set-launchpad-fee (new-fee uint))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set launchpad-fee new-fee))
  )
)

;; @desc set-min-goat-balance: updates the minimum balance of memegoat tokens required to participate
;; @requirement only callable by current owner
;; @params amount
;; @returns (response boolean)
(define-public (set-min-goat-balance (amount uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    (var-set min-goat-balance amount)
    (ok true)
  )
)

;; @desc transfer-campaign-rewards: send campaign rewards to participants
;; @requirement only callable by current owner
;; @params token-launch-id
;; @params addresse
;; @params total-points
;; @params token
;; @returns (response boolean)
(define-public (transfer-campaign-rewards (token-launch-id uint) (addresses (list 200 {addr: principal, points: uint})) (total-points uint) (token <ft-trait>))
  (begin
    (try! (check-is-owner))
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (token-contract (get token token-launch))
        (campaign-allocation (unwrap! (get campaign-allocation token-launch) ERR-NO-CAMPAIGN-ALLOCATION))
        (campaign-rewards-sent (get campaign-rewards-sent token-launch))
        (factor {total-points: total-points, campaign-allocation: campaign-allocation, rewards-sent: campaign-rewards-sent, token: token })
        (factor-updated (fold transfer-many-iter addresses factor))
        (rewards-sent (get rewards-sent factor-updated))
        (token-launch-updated (merge token-launch {
          campaign-rewards-sent: rewards-sent
        }))
      )
      (asserts! (is-eq (contract-of token) token-contract) ERR-INVALID-TOKEN)
      (asserts! (<= rewards-sent campaign-allocation) ERR-INSUFFICIENT-AMOUNT)
      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
    )
    (ok true)
  )
)

;; @desc add-exchange-liquidity: transfers launch liquidity to velar
;; @requirement only callable by current owner or campaign creator
;; @params token-launch-id
;; @params token-trait 
;; @params token-0
;; @param lp-token
;; @returns (response boolean)
(define-public (add-exchange-liquidity
    (token-launch-id uint) 
    (token-trait <ft-trait>) 
    (token-0 <ft-trait>) 
    (lp-token <ft-plus-trait>) 
  )
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (pool-id (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool-id (contract-of token-0) (contract-of token-trait)) ERR-INVALID-POOL))
        (pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool pool-id))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (softcap (get softcap token-launch))
        (hardcap (get hardcap token-launch))
        (token (get token token-launch))
        (end-block (get end-block token-launch))
        (owner (get owner token-launch))
        (listing-allocation (get listing-allocation token-launch))
        (fee (get-fee total-stx-deposited))
        (list-amount-stx (- total-stx-deposited fee))
         (token-launch-updated (merge token-launch {
            is-listed: true,
        }))
      )
      (asserts! (or (is-eq owner sender) (try! (check-is-owner)))  ERR-NOT-AUTHORIZED)
      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! (is-eq token (contract-of token-trait)) ERR-INVALID-TOKEN)
      (asserts! (is-eq (get lp-token pool) (contract-of lp-token)) ERR-INVALID-LP-TOKEN)
      
      ;; transfer stx to vault
      (try! 
        (as-contract (contract-call? .memegoat-launchpad-vault-v2 transfer-to-exchange 
            pool-id
            token-0
            token-trait
            lp-token
            list-amount-stx
            listing-allocation
            (calc-4-percent  list-amount-stx)
            (calc-4-percent  listing-allocation)
          )
        )
      )
      ;; next we transfer to dead wallet
      (try! (as-contract (contract-call?  .memegoat-launchpad-vault-v2 burn-lp-token lp-token)))

      ;; transfer fee to treasury
      (try! (as-contract (contract-call? .memegoat-launchpad-vault-v2 transfer-stx fee .memegoat-treasury)))

      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
    )
    (ok true)
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

;; PUBLIC CALLS

;; @desc register-token-launch: creates a new token launch
;; @params token
;; @params pool-amount
;; @params hardcap
;; @params softcap
;; @params start-block
;; @params end-block
;; @params min-stx-deposit
;; @params max-stx-deposit
;; @params is-vested
;; @params listing-allocation
;; @params campaign-allocation
;; @returns (response boolean)
(define-public 
  (register-token-launch 
    (token <ft-trait>)
    (pool-amount uint)
    (hardcap uint)
    (softcap uint)
    (start-block uint)
    (end-block uint)
    (min-stx-deposit uint)
    (max-stx-deposit uint)
    (is-vested bool)
    (listing-allocation uint)
    (campaign-allocation (optional uint))
  )
  (begin

    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (asserts! (> hardcap softcap) ERR-INVALID-AMOUNT)
    (asserts! (> pool-amount u0) ERR-ZERO-AMOUNT)
    (asserts! (and (> min-stx-deposit u0) (> max-stx-deposit u0)) ERR-ZERO-AMOUNT)

    (let
      (
        (total-supply (try! (contract-call? token get-total-supply)))
        (min-pool-amount (/ (* total-supply u60) u100))
        (min-listing-allocation (/ (* total-supply u30) u100))
        (min-campaign-allocation (/ (* total-supply u5) u100))
        (campaign-amount (if (is-some campaign-allocation) (unwrap-panic campaign-allocation) u0 ))
        (total-to-send (+ pool-amount listing-allocation campaign-amount))
        (duration (- end-block start-block))
        (next-launchpad-id (+ (var-get launchpad-nonce) u1))
      )

      (asserts! (>= pool-amount min-pool-amount ) ERR-BELOW-MINIMUM-POOL-ALLOCATION)
      (asserts! (>= listing-allocation min-listing-allocation ) ERR-BELOW-MINIMUM-LISTING-ALLOCATION)
      (asserts! (>= duration u144) ERR-BELOW-MIN-PERIOD) ;; rough estimate of one day

      (if (is-some campaign-allocation)
        (asserts! (>= campaign-amount min-campaign-allocation ) ERR-BELOW-MINIMUM-CAMPAIGN-ALLOCATION)
        (asserts! (is-eq  campaign-amount u0 ) ERR-INVALID-AMOUNT)
      )

      (map-set launchpad-map {token-launch-id: next-launchpad-id} {
        token: (contract-of token),
        pool-amount: pool-amount,
        hardcap: hardcap,
        softcap: softcap,
        total-stx-deposited: u0,
        no-of-participants: u0,
        min-stx-deposit: min-stx-deposit,
        max-stx-deposit: max-stx-deposit,
        duration: duration,
        start-block: start-block,
        end-block: end-block,
        owner: tx-sender,
        is-vested: is-vested,
        is-listed: false,
        listing-allocation: listing-allocation,
        campaign-allocation: campaign-allocation,
        campaign-rewards-sent: u0,
      })

      (map-set launchpad-map-by-token-addr {token-addr: (contract-of token)} next-launchpad-id)

      (try! (contract-call? token transfer total-to-send tx-sender .memegoat-launchpad-vault-v2 none))

      (var-set launchpad-nonce next-launchpad-id)
    )
    (ok true)
  )
)

;; @desc deposit-stx: sends stx to get launch token
;; @requirement user has active stake in contract or holds a min amount of goat token.
;; @params amount
;; @params token-launch-id
;; @params goat-token-trait
;; @returns (response boolean)
(define-public (deposit-stx (amount uint) (token-launch-id uint) (goat-token-trait <ft-trait-ext>))
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)

    ;; check that token passed is goat token
    (asserts! (is-eq (var-get goat-token) (contract-of goat-token-trait)) ERR-INVALID-TOKEN)

    (let
      (
        (sender tx-sender)
        (has-stake (contract-call? .memegoat-staking-v1 get-user-stake-has-staked sender))
        (user-goat-balance (try! (contract-call? goat-token-trait get-balance sender)))
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (participants (get no-of-participants token-launch))
        (min-stx-deposit (get min-stx-deposit token-launch))
        (max-stx-deposit (get max-stx-deposit token-launch))
        (exists (is-some (get-user-deposits-exists sender token-launch-id)))
        (user-deposit (get-user-deposits sender token-launch-id))
        (end-block (get end-block token-launch))
        (hardcap (get hardcap token-launch))
        (token-launch-updated (merge token-launch {
          total-stx-deposited: (+ total-stx-deposited amount),
          no-of-participants: (if exists participants (+ participants u1))
          }
        ))
      )

      ;; check that user has access
      (asserts! (or has-stake (>= user-goat-balance (var-get min-goat-balance))) ERR-NOT-QUALIFIED)

      (asserts! (>= amount min-stx-deposit) ERR-INSUFFICIENT-AMOUNT)

      ;; check that hardcap has not been reached
      (asserts! (<= (+ amount total-stx-deposited) hardcap) ERR-HARDCAP-EXCEEDED)

      ;; check that user has not exceeded max deposit
      (asserts! (<= (+ user-deposit amount) max-stx-deposit) ERR-MAX-DEPOSIT-EXCEEDED)
    
      ;; transfer stx to vault
      (try! (stx-transfer? amount tx-sender .memegoat-launchpad-vault-v2))

      ;; updated user-deposits
      (map-set users-deposits {user-addr: sender, token-launch-id: token-launch-id} (+ user-deposit amount))

      ;; updated token-launch
      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
    )
    (ok true)
  )
)

;; @desc claim-token: allows users to claim the allocated tokens
;; @params token-launch-id
;; @params token-trait
;; @returns (response boolean)
(define-public (claim-token (token-launch-id uint) (token-trait <ft-trait>))
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (softcap (get softcap token-launch))
        (hardcap (get hardcap token-launch))
        (token (get token token-launch))
        (is-vested (get is-vested token-launch))
        (end-block (get end-block token-launch))
        (exists (is-some (get-user-deposits-exists sender token-launch-id)))
        (user-allocation (calculate-allocation sender token-launch-id))
        (claimed (check-if-claimed sender token-launch-id))
      )

      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! exists ERR-NOT-PARTICIPANT)
      (asserts! (not claimed) ERR-ALREADY-CLAIMED)
      (asserts! (is-eq token (contract-of token-trait)) ERR-INVALID-TOKEN)
      (asserts! (not is-vested) ERR-TOKEN-IS-VESTED)
          
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-launchpad-vault-v2 transfer-ft token-trait user-allocation sender)))      
      
      ;; set user status to claimed 
      (map-set user-claimed { user-addr: sender, token-launch-id: token-launch-id } true)
    )
    (ok true)
  )
)


;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (calc-4-percent (amount uint))
  (let
    ((percent (/ (* amount u4) u100)))
    (- amount percent)
  )
)

(define-private (get-fee (amount uint))
  (/ (* amount (var-get launchpad-fee)) u100)
)

(define-private (transfer-many-iter (recipient {addr: principal, points: uint}) (factor {total-points: uint, campaign-allocation: uint, rewards-sent: uint, token: <ft-trait>}))
	(let
    (
      (addr (get addr recipient))
      (points (get points recipient))
      (total-points (get total-points factor))
      (token (get token factor))
      (rewards-sent (get rewards-sent factor))
      (campaign-allocation (get campaign-allocation factor))
      (reward (/ (* points campaign-allocation) total-points))
      (factor-updated (merge factor {
        rewards-sent: (+ rewards-sent reward)
      }))
    )
    ;; transfer token from vault
    (unwrap-panic (as-contract (contract-call? .memegoat-launchpad-vault-v2 transfer-ft token reward addr)))    
    factor-updated
  )
)

```
