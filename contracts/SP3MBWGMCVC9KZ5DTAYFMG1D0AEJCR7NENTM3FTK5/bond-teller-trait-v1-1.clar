;; @contract Bond Teller Trait
;; @version 1

(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait staking-trait .staking-trait-v1-1.staking-trait)

(define-trait bond-teller-trait
  (

    ;; new bond
    (new-bond (<staking-distributor-trait> <treasury-trait> <staking-trait> uint principal principal uint uint uint) (response uint uint))
  
    ;; claimable tokens for bond
    (redeem (uint uint) (response uint uint))

    ;; claimable tokens for user
    (redeem-all (uint) (response uint uint))
  )
)
