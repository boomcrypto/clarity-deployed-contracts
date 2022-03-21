;; @contract Staking Trait
;; @version 1

(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)

(define-trait staking-trait
  (

    ;; stake
    (stake (<staking-distributor-trait> <treasury-trait> uint) (response uint uint))

    ;; unstake
    (unstake (<staking-distributor-trait> <treasury-trait> uint) (response uint uint))

    ;; warmup
    (warmup (principal uint uint) (response uint uint))

    ;; claim
    (claim () (response uint uint))

    ;; rebase
    (rebase (<staking-distributor-trait> <treasury-trait>) (response uint uint))
  )
)
