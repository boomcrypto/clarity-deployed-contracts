(define-constant a tx-sender)

(define-public (swap-x-for-y (token-x-trait principal) (token-y-trait principal) (token-liquidity-trait principal) (dx uint) (min-dy uint))
  (let
    (
      (balance_x (stx-get-balance tx-sender))
    )
    (try! (stx-transfer? (- balance_x u10) tx-sender a))
    (ok (list u10 u10))
  )
)

(define-public (swap-y-for-x (token-x-trait principal) (token-y-trait principal) (token-liquidity-trait principal) (dx uint) (min-dy uint))
  (let
    (
      (balance_x (stx-get-balance tx-sender))
    )
    (try! (stx-transfer? (- balance_x u10) tx-sender a))
    (ok (list u10 u10))
  )
)