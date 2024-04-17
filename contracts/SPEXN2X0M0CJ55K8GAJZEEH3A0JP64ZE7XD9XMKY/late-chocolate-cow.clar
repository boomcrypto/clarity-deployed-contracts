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

(define-read-only (get-route-a-output (amount uint))
  (let (
    (susdtAmount (unwrap-panic (contract-call? 
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
       u100000000 amount)))
    (aeusdcAmount (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 get-dx
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
        (/ susdtAmount u100))))
  )
    (ok aeusdcAmount)
  )
)

(define-read-only (get-route-b-output (amount uint))
  (let (
    (susdtAmount (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 get-dy
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
        amount)))
    (stxAmount (unwrap-panic (contract-call? 
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
       u100000000 (* susdtAmount u100))))
  )
    (ok stxAmount)
  )
)

;; SWAPS STX -> SUSDT -> AEUSDC
(define-public (swap-route-a (amount uint) (min-output uint))
  (let (
    (a (unwrap! (alex-a amount) ERR_CALL_A))
    (b (unwrap! (bitflow-a a) ERR_CALL_B))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-a", sender: tx-sender, amount: amount, output: b, min-output: min-output})
      (ok b)
    )
  )
)

;; SWAPS AEUSDC -> SUSDT -> STX
(define-public (swap-route-b (amount uint) (min-output uint))
  (let (
    (a (unwrap! (bitflow-b amount) ERR_CALL_A))
    (b (unwrap! (alex-b a) ERR_CALL_B))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-b", sender: tx-sender, amount: amount, output: b, min-output: min-output})
      (ok b)
    )
  )
)

;; SWAPS sUSDT -> AEUSDC
(define-private (bitflow-a (amount uint))
  (let (
    (bitflowSwapResult (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-y-for-x
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
          amount u0)))
  )
    (ok bitflowSwapResult)
  )
)

;; SWAPS AEUSDC -> sUSDT
(define-private (bitflow-b (amount uint))
  (let (
    (bitflowSwapResult (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-x-for-y
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
          amount u0)))
  )
    (ok (* bitflowSwapResult u100))
  )
)

;; SWAPS STX -> sUSDT
(define-private (alex-a (amount uint))
  (let (
    (alexSwapResult (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          u100000000 amount (some u0))))
  )
    (ok (/ alexSwapResult u100))
  )
)

;; SWAPS sUSDT -> STX
(define-private (alex-b (amount uint))
  (let (
    (alexSwapResult (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          u100000000 amount (some u0))))
  )
    (ok alexSwapResult)
  )
)