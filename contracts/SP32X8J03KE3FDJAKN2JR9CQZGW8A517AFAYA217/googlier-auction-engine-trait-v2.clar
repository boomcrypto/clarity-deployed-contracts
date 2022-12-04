;; @contract Auction Engine trait 
;; @version 2

(use-trait oracle-trait .googlier-oracle-trait-v1.oracle-trait)
(use-trait vault-manager-trait .googlier-vault-manager-trait-v1.vault-manager-trait)
(use-trait collateral-types-trait .googlier-collateral-types-trait-v1.collateral-types-trait)

(define-trait auction-engine-trait
  (
    (get-minimum-collateral-amount (<oracle-trait> uint) (response uint uint))
    (start-auction (uint <collateral-types-trait> uint uint uint uint) (response bool uint))
  )
)
