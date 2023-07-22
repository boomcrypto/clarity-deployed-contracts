;; NOT A PRODUCTION DEPLOYMENT
;; This contract should be used for test purposes only

(define-public (usm-to-alex (amount uint))
  (let (
    (a (unwrap-panic (usm-a amount)))
    (b (unwrap-panic (alex-a a)))
  )
    (ok (list amount a b))
  )
)

(define-public (usm-a (dx uint))
  (let (
    (call (try! (contract-call? 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-stability-module-v1-1-0 swap-x-for-y dx)))
  )
    (ok (* (- dx (/ (* dx u50) u10000)) u100))
  )
)

(define-public (alex-a (dx uint))
  (let (
    (call (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0))))
  )
    (ok call)
  )
)