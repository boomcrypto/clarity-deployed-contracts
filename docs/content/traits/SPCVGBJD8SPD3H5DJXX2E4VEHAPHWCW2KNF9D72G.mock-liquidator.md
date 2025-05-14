---
title: "Trait mock-liquidator"
draft: true
---
```
(impl-trait .trait-granite-liquidator.granite-liquidator-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant market-asset tx-sender) ;; TODO fixme

(define-public (liquidate-collateral (pyth-price-feed-data (optional (buff 8192))) (collateral <ft-trait>) (user principal) (liquidator-repay-amount uint) (min-collateral-expected uint))
  (begin
    (try! (transfer-to collateral contract-caller min-collateral-expected))
    (ok true)
  )
)

(define-read-only (user-collateral-repayment-info (collateral <ft-trait>) (user principal) (user-debt uint))
  (ok u0)
)

(define-public (transfer-from (token <ft-trait>) (user principal) (amount uint))
  (begin
    (try! (contract-call? token transfer amount user (as-contract contract-caller) none))
    (ok true)
))

(define-public (transfer-to (token <ft-trait>) (user principal) (amount uint))
  (begin
    (as-contract (try! (contract-call? token transfer amount (as-contract contract-caller) user none)))
    (ok true)
))

(define-public (batch-liquidate (pyth-price-feed-data (optional (buff 8192))) (collateral <ft-trait>) (batch (list 20 (optional {
  user: principal,
  liquidator-repay-amount: uint,
  min-collateral-expected: uint
}))))
  (begin
    (try! (get res (fold fold-execute-liquidation batch {collateral: collateral, res: (ok true)})))
    (ok true)
  )
)

(define-private (fold-execute-liquidation (maybe-liquidation-data (optional {
  user: principal,
  liquidator-repay-amount: uint,
  min-collateral-expected: uint
})) (result {collateral: <ft-trait>, res: (response bool uint)}))
  (let (
      (collateral (get collateral result))
      (prev-result (get res result))
    )
    
    (if (is-err prev-result)
      result
      (match maybe-liquidation-data liquidation-data
        {collateral: (get collateral result), res: (liquidate-collateral none (get collateral result) (get user liquidation-data)  (get liquidator-repay-amount liquidation-data) (get min-collateral-expected liquidation-data))}
        result
      )
    )
  )
)

```
