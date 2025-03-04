
;; xyk-emissions-trait-v-1-2

;; Define emissions trait for XYK Core
(define-trait xyk-emissions-trait
  (
    (get-deployment-height () (response uint uint))
    (get-current-cycle () (response uint uint))
    (get-cycle-from-height (uint) (response uint uint))
    (get-starting-height-from-cycle (uint) (response uint bool))
    (get-claim-status () (response bool uint))
    (get-total-unclaimed-rewards () (response uint uint))
    (get-rewards-expiration () (response uint uint))
    (get-cycle (uint) (response (optional {
      total-rewards: uint,
      claimed-rewards: uint,
      unclaimed-rewards: uint
    }) uint))
    (get-user-claimed-at-cycle (principal uint) (response (optional bool) uint))
    (get-user-rewards-at-cycle (principal uint) (response {
      unclaimed-rewards: uint
    } uint))
    (claim-rewards (uint) (response {
      user-rewards: uint
    } uint))
  )
)