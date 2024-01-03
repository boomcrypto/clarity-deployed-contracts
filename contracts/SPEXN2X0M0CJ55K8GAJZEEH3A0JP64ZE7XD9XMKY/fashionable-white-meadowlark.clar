;; NOT A PRODUCTION DEPLOYMENT
;; This contract should be used for test purposes only

(define-constant ERR-MINIMUM-OUTPUT (err u1000))

(define-public (route-a (input uint) (min-output uint))
  (let (
    (a (unwrap-panic (bitflow-a input)))
    (b (unwrap-panic (alex-a a)))
  )
    (begin
      (asserts! (>= input min-output) ERR-MINIMUM-OUTPUT)
      (ok (list input a b min-output))
    )
  )
)

(define-public (bitflow-a (input uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-1 swap-x-for-y
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
          'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-1
          input u0)))
  )
    (ok call)
  )
)

(define-public (alex-a (input uint))
  (let (
    (call (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          u100000000 input (some u0))))
  )
    (ok call)
  )
)