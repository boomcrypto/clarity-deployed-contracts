(use-trait collateral-types-trait .arkadiko-collateral-types-trait-v1.collateral-types-trait)
(use-trait oracle-trait .arkadiko-oracle-trait-v1.oracle-trait)

(define-public (calculate-current-collateral-to-debt-ratio
  (vault-id uint)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
  (include-stability-fees bool)
)
  (contract-call? .arkadiko-freddie-v1-1 calculate-current-collateral-to-debt-ratio vault-id coll-type oracle include-stability-fees)
)
