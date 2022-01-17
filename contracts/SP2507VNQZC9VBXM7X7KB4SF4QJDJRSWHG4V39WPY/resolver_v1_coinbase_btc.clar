(define-constant openOracleSource "coinbase")
(define-constant openOracleSymbol "BTC")

(define-read-only (readMarketThreshold (marketId int))
  (begin
    (contract-call? 'SP15RGYVK9ACFQWMFFA2TVASDVZH38B4VATY8CJ01.stxpredict_v5 readMarketThreshold marketId)
  )
)

;; public function for a user to call to request resolution of a market
(define-public (requestResolution (marketId int))
  (let (
    (result (unwrap-panic (decideResolution marketId)))
    (currentvalue (to-int (unwrap-panic (get amount (getOraclePrice)))))
    )
    (if (is-eq result true)
      (ok (resolveMarket marketId result))
      (ok (resolveMarket marketId result))
    )
  )
)

(define-private (decideResolution (marketId int))
  (let (
    (threshold (default-to 0 (unwrap-panic (readMarketThreshold marketId))))
    (currentvalue (to-int (unwrap-panic (get amount (getOraclePrice)))))
    )
    (if (> currentvalue threshold)
      (ok true)
      (ok false)
    )
  )
)

(define-private (resolveMarket (marketId int) (result bool))
  (begin
    (contract-call? 'SP15RGYVK9ACFQWMFFA2TVASDVZH38B4VATY8CJ01.stxpredict_v5 resolveMarket marketId result)
  )
)

;; psq signed oracle from exchanges
;; testnet STZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ED5QB123.oracle-v1
;; mainnet SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD.oracle-v1
(define-private (getOraclePrice)
  (contract-call? 'SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD.oracle-v1 get-price openOracleSource openOracleSymbol)
)
