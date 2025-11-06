(define-constant ERR_NOT_ADMIN (err u200))
(define-constant ERR_INSUFFICIENT_FUNDS (err u201))

(define-data-var admin principal contract-caller)

;; Emergency withdraw function for admin to withdraw sBTC funds
(define-public (emergency-withdraw-sbtc
    (amount uint)
    (recipient principal)
  )
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (> amount u0) ERR_INSUFFICIENT_FUNDS)
    (let ((contract-balance (unwrap-panic (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        get-balance-available (as-contract contract-caller)
      ))))
      (asserts! (>= contract-balance amount) ERR_INSUFFICIENT_FUNDS)
      (try! (as-contract (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        transfer amount tx-sender recipient none
      )))
      (ok true)
    )
  )
)
