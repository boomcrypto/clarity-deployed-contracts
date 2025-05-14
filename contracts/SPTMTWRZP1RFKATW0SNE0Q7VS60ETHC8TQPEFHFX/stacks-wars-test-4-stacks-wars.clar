;; Stacks Game Pool Contract
;; Each contract represents a single pool where players stake STX to play

;; Define constants for error codes
(define-constant err-game-already-started (err u1))
(define-constant err-pool-full (err u2))
(define-constant err-already-joined (err u3))
(define-constant err-invalid-stake-amount (err u4))
(define-constant err-transfer-failed (err u5))
(define-constant err-not-owner (err u6))
(define-constant err-game-not-started (err u7))
(define-constant err-winner-already-set (err u8))
(define-constant err-not-a-player (err u9))
(define-constant err-pool-not-full (err u10))
(define-constant err-invalid-player-count (err u11))
(define-constant err-invalid-prize-amount (err u12))
(define-constant err-invalid-name (err u13))
(define-constant err-division-by-zero (err u14))

;; Define data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var pool-name (string-ascii 50) "Stacks Wars test 4")
(define-data-var max-players uint u10)
(define-data-var prize-pool uint u1)
(define-data-var amount-per-player uint u0)
(define-data-var current-player-count uint u0)
(define-data-var total-staked uint u0)
(define-data-var game-started bool false)
(define-data-var winner (optional principal) none)

;; Map to track players in the pool
(define-map pool-players
  { player: principal }
  { amount-staked: uint })

;; Map to track players by index
(define-map player-indices
  { index: uint }
  { player: principal })

;; Function for players to join the pool
(define-public (join-pool)
  (begin
    ;; Check if the game has already started
    (asserts! (not (var-get game-started)) err-game-already-started)
    
    ;; Check if the pool is full
    (asserts! (< (var-get current-player-count) (var-get max-players)) err-pool-full)
    
    ;; Check if the sender has already joined
    (asserts! (is-none (map-get? pool-players { player: tx-sender })) err-already-joined)
    
    ;; Transfer STX from the sender to the contract
    (let ((transfer-result (stx-transfer? (var-get amount-per-player) tx-sender (as-contract tx-sender))))
      (asserts! (is-ok transfer-result) err-transfer-failed)
      
      ;; Update the pool state
      (map-set pool-players { player: tx-sender } { amount-staked: (var-get amount-per-player) })
      (map-set player-indices { index: (var-get current-player-count) } { player: tx-sender })
      (var-set current-player-count (+ (var-get current-player-count) u1))
      (var-set total-staked (+ (var-get total-staked) (var-get amount-per-player)))
      
      (ok (var-get current-player-count)))))

;; Read-only functions to get pool information
(define-read-only (get-pool-info)
  {
    name: (var-get pool-name),
    max-players: (var-get max-players),
    prize-pool: (var-get prize-pool),
    amount-per-player: (var-get amount-per-player),
    current-player-count: (var-get current-player-count),
    total-staked: (var-get total-staked),
    game-started: (var-get game-started),
    winner: (var-get winner)
  })

(define-read-only (is-player-in-pool (address principal))
  (is-some (map-get? pool-players { player: address })))

(define-read-only (get-player-at-index (index uint))
  (map-get? player-indices { index: index }))

(define-read-only (get-players)
  (ok {
    max: (var-get max-players),
    current: (var-get current-player-count)
  }))