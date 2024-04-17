;; TESTING PURPOSES ONLY
;; title: router-aeusdc-ststx-v-1-1

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_CALL_A (err u1003))
(define-constant ERR_CALL_B (err u1004))
(define-constant ERR_CALL_C (err u1005))
(define-constant ERR_ROUTER_STATUS (err u1006))
(define-constant ERR_MINIMUM_OUTPUT (err u1007))

(define-data-var contract-owner principal tx-sender)
(define-data-var router-status bool true)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-router-status)
  (ok (var-get router-status))
)

;; prev: susdt-stx, then stx-ststx
;; now: aeusdc-susdt, then susdt-stx, then stx-ststx
(define-read-only (get-route-a-output (amount uint))
  (let (
    (a (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 get-dy
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
        amount)))
    (b (unwrap-panic (contract-call? 
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
       u100000000 a)))
    (c (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        (/ b u100))))
  )
    (ok c)
  )
)

;; prev: ststx-stx, then stx-susdt
;; now: ststx-stx, then stx-susdt, then susdt-aeusdc
(define-read-only (get-route-b-output (amount uint))
  (let (
    (a (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        amount)))
    (b (unwrap-panic (contract-call? 
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-helper
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
       u100000000 (* a u100))))
    (c (unwrap-panic (contract-call?
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 get-dx
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
        b)))
  )
    (ok c)
  )
)

;; aeUSDC -> sUSDT -> wSTX -> stSTX
;; bitflow-a, alex-a, bitflow-c

(define-public (swap-route-a (amount uint) (min-output uint))
  (let (
    (a (unwrap! (bitflow-a amount) ERR_CALL_A))
    (b (unwrap! (alex-a a) ERR_CALL_B))
    (c (unwrap! (bitflow-c b) ERR_CALL_C))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= c min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-a", sender: tx-sender, amount: amount, output: c, min-output: min-output})
      (ok c)
    )
  )
)

;; stSTX -> wSTX -> sUSDT -> aeUSDC
;; bitflow-d, alex-b, bitflow-b


(define-public (swap-route-b (amount uint) (min-output uint))
  (let (
    (a (unwrap! (bitflow-d amount) ERR_CALL_A))
    (b (unwrap! (alex-b a) ERR_CALL_B))
    (c (unwrap! (bitflow-b b) ERR_CALL_C))
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get router-status) true) ERR_ROUTER_STATUS)
      (asserts! (>= c min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-b", sender: tx-sender, amount: amount, output: c, min-output: min-output})
      (ok c)
    )
  )
)


;; prev: stx->ststx
;; new bitflow-a: aeusdc->susdt
(define-private (bitflow-a (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-x-for-y
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
          amount u0)))
  )
    (ok call)
  )
)

;; prev: ststx->stx
;; new bitflow-b: susdt->aeusdc
(define-private (bitflow-b (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-y-for-x
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2
          amount u0)))
  )
    (ok call)
  )
)

;; bitflow-c: stx->ststx
(define-private (bitflow-c (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
          amount u0)))
  )
    (ok call)
  )
)

;; bitflow-d: ststx->stx
(define-private (bitflow-d (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
          amount u0)))
  )
    (ok (* call u100))
  )
)

;; alex-a: susdt->stx
(define-private (alex-a (amount uint))
  (let (
    (call (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          u100000000 amount (some u0))))
  )
    (ok (/ call u100))
  )
)

;; alex-b: stx->susdt
(define-private (alex-b (amount uint))
  (let (
    (call (try! (contract-call?
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
          'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
          u100000000 amount (some u0))))
  )
    (ok call)
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