(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ONE_8 u100000000)

(define-public (preview-exchange-reward (sats-amount uint) (slippeage uint)) 
(swap-preview 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx sats-amount slippeage))

(define-private (minus-percent (a uint) (percent uint))
  (if (is-eq a u0)
    u0
    (/ (- (* a u100) (* a percent)) u100)))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))


(define-public (swap-preview (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (multiplied-amount uint) (slippeage uint)) 
  (let (
    (token-x (contract-of token-x-trait))
    (token-y (contract-of token-y-trait))
    (fee-amount 
      (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 fee-helper token-x token-y ONE_8))
    (get-helper-result (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper token-x token-y ONE_8 multiplied-amount)))
    (converted-amount 
      (mul-down 
        get-helper-result 
        (- ONE_8 (unwrap-panic fee-amount))))
    (converted-amount-slippeage (minus-percent converted-amount slippeage)))
      (ok converted-amount)))
