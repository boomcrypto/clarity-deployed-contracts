;; SPDX-License-Identifier: BUSL-1.1

(use-trait callback-trait .trait-flash-loan-v1.flash-loan)
(impl-trait .trait-flash-loan-v1.flash-loan)


(define-constant ERR-NO-STORAGE (err u60001))

(define-data-var liquidator-data (optional {
  pyth-price-feed-data: (optional (buff 8192)),
  repay-amount: uint,
  min-collateral-expected: uint,
  user: principal
}) none)


(define-public (on-granite-flash-loan (amount uint) (fee uint) (data (optional (buff 20480))))
  (let (
      (ldata (unwrap! (var-get liquidator-data) ERR-NO-STORAGE))
      (pyth-price-feed (get pyth-price-feed-data ldata))
      (user (get user ldata))
      (repay-amount (get repay-amount ldata))
      (min-collateral-expected (get min-collateral-expected ldata))
    )
    (try! (contract-call? .liquidator-v1 liquidate-collateral pyth-price-feed 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token user repay-amount min-collateral-expected))
    (ok true)
  )
)


(define-public (liquidate-collateral 
  (pyth-price-feed-data (optional (buff 8192)))
  (user principal)
  (liquidator-repay-amount uint)
  (min-collateral-expected uint)
  (callback <callback-trait>)
)
  (begin
    (var-set liquidator-data (some {
      pyth-price-feed-data: pyth-price-feed-data,
      repay-amount: liquidator-repay-amount,
      min-collateral-expected: min-collateral-expected,
      user: user,
    }))
    (as-contract (try! (contract-call? .flash-loan-v1 flash-loan liquidator-repay-amount callback none)))
    (ok true)
  )
)
