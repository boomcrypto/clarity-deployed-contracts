---
title: "Trait leaderboard-v0"
draft: true
---
```
(define-constant err-unauthorized (err u100))

(define-map scores {game-id: uint, team-id: uint} uint)

(define-map team-first uint uint)
(define-map team-second uint uint)
(define-map team-third uint uint)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-private (score-of (game-id uint) (team-id uint))
  (default-to u0 (map-get? scores {game-id: game-id, team-id: team-id}))
)

(define-private (update-score-for (game-id uint) (team-id uint) (new-score uint)) 
  (let
    (
      (current-first (get-team-first game-id))
      (current-second (get-team-second game-id))
      (current-third (get-team-third game-id))
    )
    (begin 
      (if (> new-score (score-of game-id current-first))
        (begin
          (print {event: "new-first-place", game-id: game-id, team-id: team-id, score: new-score})
          (map-set team-third game-id current-second)
          (map-set team-second game-id current-first)
          (map-set team-first game-id team-id)
        )
        (if (> new-score (score-of game-id current-second))
          (begin
            (print {event: "new-second-place", game-id: game-id, team-id: team-id, score: new-score})
            (map-set team-third game-id current-second)
            (map-set team-second game-id team-id)
          )
          (if (> new-score (score-of game-id current-third))
            (begin
              (print {event: "new-third-place", game-id: game-id, team-id: team-id, score: new-score})
              (map-set team-third game-id team-id)
            )
            true
          )
        )
      )
      (map-set scores {game-id: game-id, team-id: team-id} new-score)
      (get-score-of game-id team-id)
    )
  )
)

(define-read-only (get-team-first (game-id uint))
  (default-to u0 (map-get? team-first game-id))
)

(define-read-only (get-team-second (game-id uint))
  (default-to u0 (map-get? team-second game-id))
)

(define-read-only (get-team-third (game-id uint))
  (default-to u0 (map-get? team-third game-id))
)

(define-read-only (get-score-of (game-id uint) (team-id uint))
  (score-of game-id team-id)
)

(define-public (submit-score (game-id uint) (team-id uint) (new-score uint))
  (let
    (
        (updated-score (+ (score-of game-id team-id) new-score))
    )
    (try! (is-dao-or-extension))
    (print {event: "submit-score", game-id: game-id, team-id: team-id, score: updated-score})
    (ok (update-score-for game-id team-id updated-score))
  )
)

;; New function to get the leaderboard
(define-read-only (get-leaderboard (game-id uint))
  (let
  (
    (team-first-id (get-team-first game-id))
    (team-second-id (get-team-second game-id))
    (team-third-id (get-team-third game-id))
  )
  {
    first: { team-id: team-first-id, score: (score-of game-id team-first-id) },
    second: { team-id: team-second-id, score: (score-of game-id team-second-id) },
    third: { team-id: team-third-id, score: (score-of game-id team-third-id) }
  }
  )
)
```
