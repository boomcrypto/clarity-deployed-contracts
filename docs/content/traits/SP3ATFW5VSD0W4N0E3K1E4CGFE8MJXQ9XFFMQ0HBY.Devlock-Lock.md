---
title: "Trait Devlock-Lock"
draft: true
---
```

;; ---------------------------------------------------------
;; MEMEGOAT X CATDOG LOCK
;; ---------------------------------------------------------

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INITIALIZED (err u1001))
(define-constant ERR-NOT-INITIALIZED (err u1001))
(define-constant ERR-INVALID-BLOCK (err u5000))
(define-constant ERR-INVALID-BLOCK-ARR (err u5002))
(define-constant ERR-INSUFFICIENT_AMOUNT (err u5001))
(define-constant ERR-INVALID-TOKEN (err u5005))
(define-constant ERR-INVALID-AMOUNT (err u6001))
(define-constant ERR-INVALID-LOCK (err u6003))
(define-constant ERR-OUT-OF-BOUNDS (err u6005))
(define-constant ERR-ONLY-SINGLE-LOCK (err u7001))
(define-constant ERR-INFO-NOT-FOUND (err u7006))
(define-constant ERR-REWARD-BLOCK-NOT-REACHED (err u7007))
(define-constant ERR-CANNOT-EXCEED-CLAIM-AMOUNT (err u7008))
(define-constant ERR-INVALID-PERCENTAGE (err u8000))
(define-constant ERR-ALREADY-UNLOCKED (err u8002))
(define-constant ERR-ALREADY-CLAIMED (err u8003))
(define-constant ERR-INVALID-CONFIG (err u8004))

;; STORAGE
(define-constant LOCK-TOKEN 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY.catdog-stxcity)
(define-constant LOCK-ADDRESS (as-contract tx-sender))
(define-data-var initialized bool false)
(define-data-var lock-owner principal tx-sender)
(define-data-var lock-block uint u0)
(define-data-var total-amount uint u0)
(define-data-var is-vested bool false)
(define-data-var unlock-blocks (list 200 {height: uint, percentage: uint}) (list {height: u0, percentage: u0}))
(define-data-var total-addresses uint u0)

(define-map user-lock-data
    { address: principal }
    {
      last-claim-block: uint,
      claim-index: uint, 
      total-claimed: uint,
      total-amount: uint,
      withdrawal-address: principal,
    }
)

;; define the fee parameters
(define-constant STX-FEE u1000000) ;; small stacks fee to prevent spams
(define-constant SEC-FEE-TOKEN 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoatstx) ;; in this case memegoat
(define-constant SEC-TOKEN-FEE u1000000000) ;; option memegoat ~ 1000 memegoat


(define-read-only (get-token-lock-data)
  (ok {
    initialized: (var-get initialized),
    lock-block: (var-get lock-block),
    total-amount: (var-get total-amount),
    lock-owner: (var-get lock-owner),
    locked-token: LOCK-TOKEN,
    is-vested: (var-get is-vested),
    unlock-blocks: (var-get unlock-blocks),
    total-addresses: (var-get total-addresses)
  })
)

(define-read-only (get-user-lock-info (address principal))
  (ok (unwrap! (map-get? user-lock-data {address: address}) ERR-INFO-NOT-FOUND))
)

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-community-dao) (contract-call? 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

;; DAO ACTION
(define-public (emergency-withdraw (token-trait <ft-trait>) (recipient principal))
  (let
    (
      (remaining-bal (try! (contract-call? token-trait get-balance LOCK-ADDRESS)))
    )
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer remaining-bal tx-sender recipient none))
  )
)

;; PUBLIC CALLS
;; relockToken
(define-public (relock-token (new-unlock-block uint) (fee-in-stx bool) (secondary-token-trait <ft-trait-ext>) ) 
  (begin 
    (try! (check-is-owner))
    (try! (check-is-initialized))
    (let
      (
        (sender tx-sender)
        (vested (var-get is-vested))
        (user-lock-info (try! (get-user-lock-info sender)))
        (claim-index (get claim-index user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (lock-block- (var-get lock-block))
        (unlock-blocks-data (var-get unlock-blocks))
        (user-unlock-block (unwrap! (element-at? unlock-blocks-data claim-index) ERR-OUT-OF-BOUNDS))
        (updated-block-info (merge user-unlock-block {
          height: new-unlock-block
        }))
        (updated-unlock-blocks (unwrap! (replace-at? unlock-blocks-data claim-index updated-block-info) ERR-OUT-OF-BOUNDS)) 
      )
      (asserts! (not vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (and (> new-unlock-block lock-block-) (> new-unlock-block block-height)) ERR-INVALID-BLOCK)
      (asserts! (is-eq total-claimed u0) ERR-ALREADY-CLAIMED)
      (asserts! (> (get height user-unlock-block) block-height) ERR-ALREADY-UNLOCKED)

      (if fee-in-stx
        ;; Pay fee in STX
        (try! (stx-transfer? STX-FEE tx-sender 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-treasury))
        ;; Burn token
        (begin
          (asserts! (is-eq SEC-FEE-TOKEN (contract-of secondary-token-trait)) ERR-INVALID-TOKEN)
          (try! (contract-call? secondary-token-trait burn SEC-TOKEN-FEE sender))
        )
      )
      (var-set unlock-blocks updated-unlock-blocks)
    )
    (ok true)
  )
)

;; withdraw
(define-public (withdraw-token (locked-token <ft-trait>)) 
  (begin
    (try! (check-is-initialized))
    (let
      (
        (recipient tx-sender)
        (vested (var-get is-vested))
        (user-lock-info (try! (get-user-lock-info recipient)))
        (unlock-blocks-data (var-get unlock-blocks))
        (claim-index (get claim-index user-lock-info))
        (locked-amount (get total-amount user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (withdrawal-address (get withdrawal-address user-lock-info))
        (user-unlock-block (unwrap! (element-at? unlock-blocks-data claim-index) ERR-OUT-OF-BOUNDS))
        (height (get height user-unlock-block))
        (percentage (get percentage user-unlock-block))
        (unlock-amount (/ (* locked-amount percentage) u100))
        (user-lock-info-updated (merge user-lock-info {
            claim-index: (+ claim-index u1),
            last-claim-block: block-height,
            total-claimed: (+ total-claimed unlock-amount)
          })
        )
      )
  
      (asserts! (> block-height height) ERR-REWARD-BLOCK-NOT-REACHED)
      (asserts! (is-eq LOCK-TOKEN (contract-of locked-token)) ERR-INVALID-TOKEN)
      (asserts! (< total-claimed locked-amount) ERR-CANNOT-EXCEED-CLAIM-AMOUNT)
      (asserts! (is-eq (contract-of locked-token) LOCK-TOKEN) ERR-INVALID-TOKEN)

      ;; transfer token from vault
      (try! (as-contract (contract-call? locked-token transfer unlock-amount tx-sender recipient none)))
      (map-set user-lock-data {address: recipient} user-lock-info-updated)
      
      (if (is-eq claim-index (- (len unlock-blocks-data) u1))
        (map-delete user-lock-data {address: recipient})
        true
      )
    )
    (ok true)
  )
)

;; incrementlock
(define-public (increment-lock (locked-token <ft-trait>) (amount uint)) 
  (begin 
    (try! (check-is-owner))
    (try! (check-is-initialized))
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (let
      (
        (sender tx-sender)
        (vested (var-get is-vested))
        (unlock-blocks-data (var-get unlock-blocks))
        (total-locked (var-get total-amount))
        (user-lock-info (try! (get-user-lock-info sender)))
        (claim-index (get claim-index user-lock-info))
        (user-lock-amount (get total-amount user-lock-info))
        (user-unlock-block (unwrap! (element-at? unlock-blocks-data claim-index) ERR-OUT-OF-BOUNDS))
        (user-lock-info-updated (merge user-lock-info {
          total-amount: (+ user-lock-amount amount)
        }))
      ) 
      (asserts! (not vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (is-eq LOCK-TOKEN (contract-of locked-token)) ERR-INVALID-TOKEN)
      (asserts! (> (get height user-unlock-block) block-height) ERR-ALREADY-UNLOCKED)

      ;; transfer token to vault
      (try! (contract-call? locked-token transfer amount sender LOCK-ADDRESS none))

      ;; update records
      (map-set user-lock-data {address: sender} user-lock-info-updated)
      (var-set total-amount (+ total-locked amount))
    )
    (ok true)
  )
)

;; split and share lock
(define-public (split-lock (addresses-info (list 200 {address: principal, amount: uint, withdrawal-address: principal}))) 
  (begin
    (try! (check-is-initialized))
    (try! (check-is-owner))
    (asserts! (is-eq (len (filter check-lock-amount-iter addresses-info)) u0) ERR-INVALID-AMOUNT)
    (let
      (
        (sender tx-sender)
        (total-amt (fold sum-lock-amount-iter addresses-info u0))
        (vested (var-get is-vested))
        (total-addresses- (var-get total-addresses))
        (user-lock-info (try! (get-user-lock-info sender)))
        (locked-amt (get total-amount user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (user-lock-info-updated (merge user-lock-info {
          total-amount: (if (>= total-amt locked-amt) u0 (- locked-amt total-amt)),
        }))
      )

      (asserts! (not vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (< total-amt locked-amt) ERR-INVALID-AMOUNT)
      (asserts! (is-eq total-claimed u0) ERR-ALREADY-CLAIMED)
      (map-set user-lock-data {address: sender} user-lock-info-updated)
      (var-set total-addresses (+ total-addresses- (len addresses-info)))

      (fold store-lock-info-iter addresses-info u0)
    )
    (ok true)
  )
)

;; transferlockownership
(define-public (transfer-lock-ownership (new-owner principal) (withdrawal-address principal)) 
  (begin
    (try! (check-is-initialized))
    (try! (check-is-owner))
    (if (not (var-get is-vested))
      (let
        (
          (user-lock-info (try! (get-user-lock-info tx-sender)))
          (user-lock-amount (get total-amount user-lock-info))
          (total-claimed (get total-claimed user-lock-info))
          (claim-index (get claim-index user-lock-info))
          (last-claim-block (get last-claim-block user-lock-info))
        )
        (map-set user-lock-data
          {address: new-owner} 
          {
            last-claim-block: last-claim-block, 
            claim-index: claim-index, 
            total-claimed: total-claimed, 
            total-amount: user-lock-amount, 
            withdrawal-address: withdrawal-address
          }
        )
        (map-delete user-lock-data {address: tx-sender})
      )
      true
    )

    (ok (var-set lock-owner new-owner))
  )
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq contract-caller (var-get lock-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-block-info-iter (blocks {height: uint, percentage: uint}))
  (not (and (> (get height blocks) block-height) (> (get percentage blocks) u0) (<= (get percentage blocks) u100)))
)

(define-private (check-block-heights-iter (blocks {height: uint, percentage: uint}) (data {check: bool, last-height: uint}))
  (let 
    (
      (height (get height blocks))
    )
    {check: (> height (get last-height data)), last-height: height}
  )
)

(define-private (check-lock-amount-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}))
  (not (> (get amount user-record) u0))
)

(define-private (sum-lock-amount-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}) (amount uint))
  (begin 
    (+ amount (get amount user-record))
  )
)

(define-private (sum-block-percentage-iter (blocks {height: uint, percentage: uint}) (total-percentage uint))
  (begin 
    (+ total-percentage (get percentage blocks))
  )
)

(define-private (store-lock-info-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}) (count uint))
  (begin
    (map-set user-lock-data
      {address: (get address user-record)} 
      {
        last-claim-block: u0, 
        claim-index: u0, 
        total-claimed: u0, 
        total-amount: (get amount user-record), 
        withdrawal-address: (get withdrawal-address user-record)
      }
    )
    (+ count u1)
  )
)

;; PRIVATE CALLS
(define-private (check-is-initialized)
  (ok (asserts! (var-get initialized) ERR-NOT-INITIALIZED))
)


(define-public (initialize) 
  (begin
    (let
      (
        (token-amount u85621792120523)
        (fee-in-stx true)
        (vested false)
        (unlock-blocks-data (list {height: u172346, percentage: u100}))
        (addresses-info (list {address: 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY, amount: u85621792120523, withdrawal-address: 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY}))
      ) 
      (asserts! (is-eq (len (filter check-block-info-iter unlock-blocks-data)) u0) ERR-INVALID-BLOCK)
      (asserts! (is-eq (len (filter check-lock-amount-iter addresses-info)) u0) ERR-INVALID-AMOUNT)
      (asserts! (is-eq (fold sum-lock-amount-iter addresses-info u0) token-amount) ERR-INSUFFICIENT_AMOUNT)
      (asserts! (is-eq (fold sum-block-percentage-iter unlock-blocks-data u0) u100) ERR-INVALID-PERCENTAGE)
      (asserts! (get check (fold check-block-heights-iter unlock-blocks-data {check: false, last-height: block-height})) ERR-INVALID-BLOCK-ARR)

      (if fee-in-stx
        ;; Pay fee in STX
        (try! (stx-transfer? STX-FEE tx-sender 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-treasury)) 
        ;; Burn token
        (begin
          (try! (contract-call? 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoatstx burn SEC-TOKEN-FEE tx-sender))
        )
      )

      (if vested
        (begin
          (asserts! (> (len unlock-blocks-data) u1) ERR-INVALID-CONFIG)
        )
        (asserts! (and (is-eq (len unlock-blocks-data) u1) (is-eq (len addresses-info) u1)) ERR-INVALID-CONFIG)
      )

      (fold store-lock-info-iter addresses-info u0)
      
      ;; transfer token to LOCK ADDRESS
      (try! (contract-call? 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY.catdog-stxcity transfer token-amount tx-sender LOCK-ADDRESS none))

      (var-set lock-block block-height)
      (var-set total-amount token-amount)
      (var-set is-vested vested)
      (var-set unlock-blocks unlock-blocks-data)
      (var-set total-addresses (len addresses-info))
      
      (var-set initialized true)
    )
  (ok true)
  )
)

(begin 
  (initialize)
)  
  

```
