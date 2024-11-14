---
title: "Trait meme-mountain-v0"
draft: true
---
```
;; meme-mountain.clar

(define-constant err-unauthorized (err u1001))
(define-constant err-game-not-active (err u1002))
(define-constant err-warmup-period (err u1003))
(define-constant err-invalid-warmup (err u1004))
(define-constant err-invalid-game-length (err u1005))
(define-constant err-game-ended (err u1006))
(define-constant err-game-not-ended (err u1007))

(define-data-var current-game-id uint u0)
(define-data-var game-start-block uint u0)
(define-data-var warmup-period uint u1500) ;; Default to 1500 blocks (approximately 10 days)
(define-data-var game-length uint u3000) ;; Default to 3000 blocks (approximately 20 days)

(define-map game-data uint 
  {
    warmup-block: uint,
    start-block: uint,
    end-block: uint
  }
)

;; Authorization check
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; Start a new game
(define-public (start-new-game)
  (begin
    (try! (is-dao-or-extension))
    (let
      (
        (new-game-id (+ (var-get current-game-id) u1))
        (warmup-block block-height)
        (start-block (+ block-height (var-get warmup-period)))
        (end-block (+ block-height (var-get game-length)))
      )
      (var-set current-game-id new-game-id)
      (var-set game-start-block start-block)
      (map-set game-data new-game-id
        {
          warmup-block: warmup-block,
          start-block: start-block,
          end-block: end-block
        }
      )
      (print {event: "new-game-started", game-id: new-game-id, warmup-block: warmup-block, start-block: start-block, warmup-period: (var-get warmup-period), game-length: (var-get game-length), end-block: end-block})
      (ok new-game-id)
    )
  )
)

;; Set warmup period
(define-public (set-warmup-period (new-warmup uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (> new-warmup u0) err-invalid-warmup)
    (var-set warmup-period new-warmup)
    (print {event: "warmup-period-updated", new-warmup-period: new-warmup})
    (ok new-warmup)
  )
)

;; Set game length
(define-public (set-game-length (new-length uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (> new-length (var-get warmup-period)) err-invalid-game-length)
    (var-set game-length new-length)
    (print {event: "game-length-updated", new-game-length: new-length})
    (ok new-length)
  )
)

;; Add points to a team's score
(define-public (add-points (team-id uint) (points uint))
  (let
    (
      (game-id (var-get current-game-id))
      (game-info (unwrap! (map-get? game-data game-id) err-game-not-active))
    )
    (try! (is-dao-or-extension))
    (asserts! (>= block-height (get start-block game-info)) err-warmup-period)
    (asserts! (< block-height (get end-block game-info)) err-game-ended)
    (let
      (
        (result (unwrap-panic (contract-call? .leaderboard-v0 submit-score game-id team-id points)))
      )
      (print {event: "points-added", game-id: game-id, team-id: team-id, points-added: points, new-score: result})
      (ok result)
    )
  )
)

;; Get the current score for a team
(define-read-only (get-team-score (team-id uint))
  (contract-call? .leaderboard-v0 get-score-of (var-get current-game-id) team-id)
)

;; Get the current leaderboard
(define-read-only (get-leaderboard)
  (contract-call? .leaderboard-v0 get-leaderboard (var-get current-game-id))
)

;; Get the current game ID
(define-read-only (get-current-game-id)
  (var-get current-game-id)
)

;; Get the current warmup period
(define-read-only (get-warmup-period)
  (var-get warmup-period)
)

;; Get the current game length
(define-read-only (get-game-length)
  (var-get game-length)
)

;; Check if the game is active (past warmup period and before game end)
(define-read-only (is-game-active)
  (let
    (
      (game-id (var-get current-game-id))
      (game-info (map-get? game-data game-id))
    )
    (match game-info
      game-data-obj
        (and
          (>= block-height (get start-block game-data-obj))
          (< block-height (get end-block game-data-obj))
        )
      false
    )
  )
)

;; Get game info
(define-read-only (get-game-info (game-id uint))
  (map-get? game-data game-id)
)

;; Get current game info
(define-read-only (get-current-game-info)
  (map-get? game-data (var-get current-game-id))
)
```
