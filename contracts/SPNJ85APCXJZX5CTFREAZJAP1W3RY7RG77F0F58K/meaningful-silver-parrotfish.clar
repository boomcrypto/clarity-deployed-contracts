;; alex-swap-helper-caller-poc
;; Exchange STX by xBTC

(define-constant contract-owner tx-sender)

(define-constant err-not-owner (err 101))

(define-public (simple-hardcoded-swap (amount uint) (min-dy (optional uint))) 
    (begin
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01
                swap-helper
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
                amount
                min-dy)
    )
)
