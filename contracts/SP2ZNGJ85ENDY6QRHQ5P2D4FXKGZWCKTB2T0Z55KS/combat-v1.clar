(define-constant err-unauthorized (err u401))

(define-data-var damage-multiplier uint u3000)
(define-data-var exp-multiplier-factor uint u10)
(define-data-var min-exp-factor uint u1000000)

;; --- Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Getter for damage-multiplier
(define-read-only (get-damage-multiplier)
  (ok (var-get damage-multiplier))
)

;; Setter for damage-multiplier
(define-public (set-damage-multiplier (new-multiplier uint))
  (begin
    (try! (is-authorized))
    (var-set damage-multiplier new-multiplier)
    (ok new-multiplier)
  )
)

;; Getter for exp-multiplier-factor
(define-read-only (get-exp-multiplier-factor)
  (ok (var-get exp-multiplier-factor))
)

;; Setter for exp-multiplier-factor
(define-public (set-exp-multiplier-factor (new-factor uint))
  (begin
    (try! (is-authorized))
    (var-set exp-multiplier-factor new-factor)
    (ok new-factor)
  )
)

;; Getter for has-min-exp factor
(define-read-only (get-min-exp-factor)
  (ok (var-get min-exp-factor))
)

;; Setter for has-min-exp factor
(define-public (set-min-exp-factor (new-factor uint))
  (begin
    (try! (is-authorized))
    (var-set min-exp-factor new-factor)
    (ok new-factor)
  )
)

(define-read-only (calculate-damage (energy uint) (attacker principal))
    (let
        (
            (has-min-exp (unwrap-panic (contract-call? .experience has-percentage-balance attacker (var-get min-exp-factor))))
            (exp-balance (unwrap-panic (contract-call? .experience get-balance attacker)))
            (total-exp-supply (unwrap-panic (contract-call? .experience get-total-supply)))
            (exp-percentage (/ (* exp-balance u10000) total-exp-supply))
        )
        (if (not has-min-exp)
            u0 ;; 100% resist if below minimum experience
            (let
                (
                    (exp-multiplier (+ u1 (* exp-percentage (var-get exp-multiplier-factor)))) ;; 1 + (exp% * 0.1)
                    (base-damage (* (pow (log2 energy) u3) (var-get damage-multiplier))) ;; Cubed log2 of energy, then multiplied
                    (scaled-damage (* base-damage exp-multiplier))
                )
                (/ scaled-damage u10000)
            )
        )
    )
)