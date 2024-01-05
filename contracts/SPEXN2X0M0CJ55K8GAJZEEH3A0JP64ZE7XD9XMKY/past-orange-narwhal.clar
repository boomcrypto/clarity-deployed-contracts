;; NOT A PRODUCTION DEPLOYMENT
;; THIS CONTRACT SHOULD BE USED FOR TEST PURPOSES ONLY

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_CALL_A (err u1003))
(define-constant ERR_CALL_B (err u1004))
(define-constant ERR_ROUTER_STATUS (err u1005))
(define-constant ERR_MINIMUM_OUTPUT (err u1006))

(define-data-var contract-owner principal tx-sender)
(define-data-var router-status bool true)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-router-status)
  (ok (var-get router-status))
)

(define-public (route-a (amount uint) (min-output uint))
  (let (
    (a (unwrap! (bitflow-a amount) ERR_CALL_A))
    (b (unwrap! (alex-a a) ERR_CALL_B))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "route-a", sender: tx-sender, amount: amount, output: b, min-output: min-output})
      (ok b)
    )
  )
)

(define-public (route-b (amount uint) (min-output uint))
  (let (
    (a (unwrap! (alex-b amount) ERR_CALL_A))
    (b (unwrap! (bitflow-b a) ERR_CALL_B))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "route-b", sender: tx-sender, amount: amount, output: b, min-output: min-output})
      (ok b)
    )
  )
)

(define-public (set-router-status (status bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (ok (var-set router-status status))
  )
)

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (ok (var-set contract-owner address))
  )
)

(define-public (bitflow-a (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-1 swap-x-for-y
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
          'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-1
          amount u0)))
  )
    (ok call)
  )
)

(define-public (bitflow-b (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-1 swap-y-for-x
          'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-1
          amount u0)))
  )
    (ok call)
  )
)

(define-public (alex-a (amount uint))
  (let (
    (call (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          u100000000 amount (some u0))))
  )
    (ok call)
  )
)

(define-public (alex-b (amount uint))
  (let (
    (call (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
          u100000000 amount (some u0))))
  )
    (ok call)
  )
)