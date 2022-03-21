;; @contract Staking Distributor Trait
;; @version 1

(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)

(define-trait staking-distributor-trait
  (

    ;; distribute rewards to recipient
    (distribute (<treasury-trait>) (response uint uint))
  
  )
)
