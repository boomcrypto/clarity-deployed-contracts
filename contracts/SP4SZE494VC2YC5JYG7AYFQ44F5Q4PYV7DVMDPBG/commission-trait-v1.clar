;; @contract Commission Trait
;; @version 1

(use-trait staking-trait .staking-trait-v1.staking-trait)

(define-trait commission-trait
  (
    (add-commission (<staking-trait> uint) (response uint uint))
  )
)
