
(define-public (get-stake-amounts (user principal))
  (let (
    (stake-amount-gglr-USD (contract-call? .googlier-stake-pool-gglr-USD-v1-1 get-stake-amount-of user))
    (stake-amount-wstx-USD (contract-call? .googlier-stake-pool-wstx-USD-v1-1 get-stake-amount-of user))
    (stake-amount-wstx-gglr (contract-call? .googlier-stake-pool-wstx-gglr-v1-1 get-stake-amount-of user))
  )
    (ok {
      stake-amount-gglr-USD: stake-amount-gglr-USD,
      stake-amount-wstx-USD: stake-amount-wstx-USD,
      stake-amount-wstx-gglr: stake-amount-wstx-gglr,

    })
  )
)

(define-public (get-stake-totals)
  (let (
    (stake-total-gglr (contract-call? .googlier-stake-pool-gglr-v1-2 get-total-staked))
    (stake-total-gglr-USD (contract-call? .googlier-stake-pool-gglr-USD-v1-1 get-total-staked))
    (stake-total-wstx-USD (contract-call? .googlier-stake-pool-wstx-USD-v1-1 get-total-staked))
    (stake-total-wstx-gglr (contract-call? .googlier-stake-pool-wstx-gglr-v1-1 get-total-staked))
  )
    (ok {
      stake-total-gglr: stake-total-gglr,
      stake-total-gglr-USD: stake-total-gglr-USD,
      stake-total-wstx-USD: stake-total-wstx-USD,
      stake-total-wstx-gglr: stake-total-wstx-gglr,
    })
  )
)
