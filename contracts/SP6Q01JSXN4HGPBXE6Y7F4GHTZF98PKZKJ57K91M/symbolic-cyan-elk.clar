(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)


;; input:  'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 100 4
(define-public (swap-stx-to-xbtc (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (stx-amount uint) (slippeage uint)) 
  (let (
    (token-x (contract-of token-x-trait))
    (token-y (contract-of token-y-trait))
    (fee-amount 
      (contract-call? 
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 
        fee-helper 
        token-x
        token-y))
    (xbtc-amount 
      (/ 
        (unwrap-panic (contract-call? 
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 
          get-helper 
          token-x
          token-y
          (* stx-amount u100000000))) 
        (+ u1 (unwrap-panic fee-amount))))
    (xbtc-amount-slippeage (- xbtc-amount (/ (* xbtc-amount slippeage) u100))))
    (try! (print fee-amount))
    (print (some xbtc-amount))
    (print (some xbtc-amount-slippeage))
    (try! (contract-call? 
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 
        swap-helper
        token-x-trait
        token-y-trait
        stx-amount
        (some xbtc-amount-slippeage)))
    (ok true)))