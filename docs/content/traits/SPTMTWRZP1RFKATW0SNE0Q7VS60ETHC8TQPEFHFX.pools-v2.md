---
title: "Trait pools-v2"
draft: true
---
```
;; Pool Smart Contract
;; Manages STX pools where users can join and compete for rewards

;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_POOL_NOT_FOUND (err u101))
(define-constant ERR_POOL_CLOSED (err u102))
(define-constant ERR_POOL_FULL (err u103))
(define-constant ERR_ALREADY_JOINED (err u104))
(define-constant ERR_INVALID_AMOUNT (err u105))
(define-constant ERR_INVALID_MAX_PLAYERS (err u108))
(define-constant ERR_INVALID_ENTRY_AMOUNT (err u109))

;; Data Maps
;; Store pool information
(define-map pools uint {
  owner: principal,
  max-players: uint,
  entry-amount: uint,
  prize-pool: uint,
  status: (string-ascii 10), ;; "open", "closed", "finished"
  winner: (optional principal)
})

;; Track participants in each pool
(define-map pool-participants { pool-id: uint, user: principal } {
  amount: uint,
  joined-at: uint
})

;; Track how many participants are in each pool
(define-map pool-participant-count uint uint)

;; Track total pools created
(define-data-var pool-counter uint u0)

;; Getters
(define-read-only (get-pool (pool-id uint))
  (map-get? pools pool-id)
)

(define-read-only (get-participant (pool-id uint) (user principal))
  (map-get? pool-participants { pool-id: pool-id, user: user })
)

(define-read-only (get-participant-count (pool-id uint))
  (default-to u0 (map-get? pool-participant-count pool-id))
)

(define-read-only (get-total-pools)
  (var-get pool-counter)
)

;; Create a new pool
(define-public (create-pool (max-players uint) (entry-amount uint))
  (let ((pool-id (var-get pool-counter)))
    (begin
      ;; Validate input parameters
      (asserts! (> max-players u0) ERR_INVALID_MAX_PLAYERS)
      (asserts! (> entry-amount u0) ERR_INVALID_ENTRY_AMOUNT)
      
      ;; Store pool data
      (map-set pools pool-id {
        owner: tx-sender,
        max-players: max-players,
        entry-amount: entry-amount,
        prize-pool: u0,
        status: "open",
        winner: none
      })
      
      ;; Initialize participant count
      (map-set pool-participant-count pool-id u0)
      
      ;; Increment pool counter
      (var-set pool-counter (+ pool-id u1))
      
      ;; Return the pool ID
      (ok pool-id)
    )
  )
)

;; Join a pool
(define-public (join-pool (pool-id uint))
  (let (
    (pool (unwrap! (get-pool pool-id) ERR_POOL_NOT_FOUND))
    (current-count (get-participant-count pool-id))
    (entry-amount (get entry-amount pool))
  )
    ;; Check pool is open
    (asserts! (is-eq (get status pool) "open") ERR_POOL_CLOSED)
    
    ;; Check pool is not full
    (asserts! (< current-count (get max-players pool)) ERR_POOL_FULL)
    
    ;; Check user not already in pool
    (asserts! (is-none (get-participant pool-id tx-sender)) ERR_ALREADY_JOINED)
    
    ;; Transfer STX from sender to contract
    (try! (stx-transfer? entry-amount tx-sender (as-contract tx-sender)))
    
    ;; Record participation
    (map-set pool-participants 
      { pool-id: pool-id, user: tx-sender }
      { amount: entry-amount, joined-at: stacks-block-height }
    )
    
    ;; Update participant count
    (map-set pool-participant-count pool-id (+ current-count u1))
    
    ;; Update prize pool
    (map-set pools pool-id 
      (merge pool { prize-pool: (+ (get prize-pool pool) entry-amount) })
    )
    
    (ok true)
  )
)

;; Close pool (only owner)
(define-public (close-pool (pool-id uint))
  (let ((pool (unwrap! (get-pool pool-id) ERR_POOL_NOT_FOUND)))
    ;; Ensure sender is pool owner
    (asserts! (is-eq tx-sender (get owner pool)) ERR_NOT_AUTHORIZED)
    
    ;; Update pool status
    (map-set pools pool-id 
      (merge pool { status: "closed" })
    )
    
    (ok true)
  )
)

;; Declare winner and distribute prize (only owner)
(define-public (end-pool-with-winner (pool-id uint) (winner principal))
  (let (
    (pool (unwrap! (get-pool pool-id) ERR_POOL_NOT_FOUND))
    (prize-amount (get prize-pool pool))
  )
    ;; Ensure sender is pool owner
    (asserts! (is-eq tx-sender (get owner pool)) ERR_NOT_AUTHORIZED)
    
    ;; Ensure pool is closed
    (asserts! (is-eq (get status pool) "closed") 
              (err u106))
    
    ;; Ensure winner is a participant
    (asserts! (is-some (get-participant pool-id winner))
              (err u107))
    
    ;; Transfer prize to winner
    (try! (as-contract (stx-transfer? prize-amount tx-sender winner)))
    
    ;; Update pool status and winner
    (map-set pools pool-id 
      (merge pool { 
        status: "finished",
        winner: (some winner),
        prize-pool: u0
      })
    )
    
    (ok true)
  )
)

;; Get all pools a user has joined
(define-read-only (get-user-pools (user principal))
  ;; Note: This function would typically return a list of pool IDs,
  ;; but Clarity doesn't support dynamic lists in read-only functions.
  ;; In a real application, you would query this information client-side.
  (ok true)
)

```
