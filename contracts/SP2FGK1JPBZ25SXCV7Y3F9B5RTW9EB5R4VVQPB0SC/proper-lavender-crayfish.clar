;; exhchange utilities
(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000)

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (minus-percent (a uint) (percent uint))
  (if (is-eq a u0)
    u0
    (/ (- (* a u100) (* a percent)) u100)))

;; public to check return btc-to-stx amount
;; input: 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 5000
(define-public (swap-stx-to-xbtc (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (sats-amount uint)) 
  (let (
    (token-x (contract-of token-x-trait))
    (token-y (contract-of token-y-trait))
    (fee-amount 
      (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 fee-helper token-x token-y ONE_8))
    (stx-amount 
      (mul-down 
        (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper token-x token-y ONE_8 sats-amount)) 
        (- ONE_8 (unwrap-panic fee-amount)))))
    (ok stx-amount)))