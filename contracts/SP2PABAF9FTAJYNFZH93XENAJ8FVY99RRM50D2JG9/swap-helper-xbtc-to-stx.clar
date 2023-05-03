;; wrapper to swap xbtc to stx on alexgo
(define-public (swap-helper (amount-xsats uint) (amount-min-ustx (optional uint)))
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03
    swap-helper
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
    amount-xsats
    amount-min-ustx))
