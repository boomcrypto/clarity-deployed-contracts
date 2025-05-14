---
title: "Trait testing-4-stacks-wars"
draft: true
---
```
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
(define-data-var pool-name (string-ascii 50) "")
(define-data-var max-players uint u0)
(define-data-var prize-pool uint u0)
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

;; Function to initialize pool parameters (only called once when contract deployed)
(define-public (initialize-pool (name (string-ascii 50)) (players uint) (total-prize uint))
  (begin
    ;; Only contract owner can initialize
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
    
    ;; Validate input parameters
    (asserts! (> (len name) u0) err-invalid-name)
    (asserts! (> players u1) err-invalid-player-count)
    (asserts! (> total-prize u0) err-invalid-prize-amount)
    (asserts! (>= total-prize players) err-invalid-prize-amount)
    
    ;; Set pool parameters
    (var-set pool-name name)
    (var-set max-players players)
    (var-set prize-pool total-prize)
    
    ;; Calculate amount each player needs to stake
    ;; Protected against division by zero with the above assertion (players > 1)
    (var-set amount-per-player (/ total-prize players))
    
    (ok {
      name: name,
      max-players: players,
      prize-pool: total-prize,
      amount-per-player: (var-get amount-per-player)
    })))

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

;; Function to manually start the game (called by owner after pool is full)
(define-public (start-game)
  (begin
    ;; Only contract owner can start the game
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
    
    ;; Check if the pool is full
    (asserts! (is-eq (var-get current-player-count) (var-get max-players)) err-pool-not-full)
    
    ;; Set the game as started
    (var-set game-started true)
    
    (ok true)))

;; Function to determine the winner (called by owner after game is played)
(define-public (determine-winner (winner-address principal))
  (begin
    ;; Only contract owner can determine winner
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
    
    ;; Check if the game has started
    (asserts! (var-get game-started) err-game-not-started)
    
    ;; Check if the winner has already been set
    (asserts! (is-none (var-get winner)) err-winner-already-set)
    
    ;; Check if the winner is a valid player
    (asserts! (is-some (map-get? pool-players { player: winner-address })) err-not-a-player)
    
    ;; Set the winner
    (var-set winner (some winner-address))
    
    ;; Transfer the total staked amount to the winner
    (let ((transfer-result (as-contract (stx-transfer? (var-get total-staked) tx-sender winner-address))))
      (asserts! (is-ok transfer-result) err-transfer-failed)
      
      (ok (var-get total-staked)))))

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

;; Function for players to leave the pool and retrieve their staked STX
(define-public (leave-pool)
  (begin
    ;; Check if the game has already started
    (asserts! (not (var-get game-started)) err-game-already-started)
    
    ;; Check if the sender is a player
    (let ((player-entry (map-get? pool-players { player: tx-sender })))
      (asserts! (is-some player-entry) err-not-a-player)
      
      ;; Get the amount staked by the player
      (let ((amount (get amount-staked (unwrap! player-entry err-not-a-player))))
        ;; Transfer the staked amount back to the player from the contract's balance
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
          
        ;; Remove the player from the pool
        (map-delete pool-players { player: tx-sender })
        
        ;; Decrement current-player-count and total-staked
        (var-set current-player-count (- (var-get current-player-count) u1))
        (var-set total-staked (- (var-get total-staked) amount))
        
        (ok amount)))))
```
