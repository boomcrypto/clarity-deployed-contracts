(define-constant ERR_INSUFFICIENT_FUNDS (err u100))
(define-constant ERR_UNAUTHORIZED (err u101))

(define-data-var total-supply uint u0)
(define-data-var owner principal tx-sender)
(define-map balances { account: principal } uint)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (let ((balance (default-to u0 (map-get? balances { account: sender }))))
      (if (< balance amount)
          ERR_INSUFFICIENT_FUNDS
          (begin
            (map-set balances { account: sender } (- balance amount))
            (map-set balances { account: recipient } (+ (default-to u0 (map-get? balances { account: recipient })) amount))
            (ok true)
          )
      )
    )
  )
)

(define-public (burn (amount uint))
  (let ((balance (default-to u0 (map-get? balances { account: tx-sender }))))
    (if (< balance amount)
        ERR_INSUFFICIENT_FUNDS
        (begin
          (map-set balances { account: tx-sender } (- balance amount))
          (var-set total-supply (- (var-get total-supply) amount))
          (ok true)
        )
    )
  )
)

(define-public (burn-as-contract (from principal) (amount uint))
  (let ((balance (default-to u0 (map-get? balances { account: from }))))
    (if (< balance amount)
        ERR_INSUFFICIENT_FUNDS
        (begin
          (map-set balances { account: from } (- balance amount))
          (var-set total-supply (- (var-get total-supply) amount))
          (ok true)
        )
    )
  )
)

(define-public (get-balance (account principal))
  (ok (default-to u0 (map-get? balances { account: account })))
)

(define-public (get-total-supply)
  (ok (var-get total-supply))
)

(define-public (get-owner)
  (ok (var-get owner))
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR_UNAUTHORIZED)
    (var-set owner new-owner)
    (ok true)
  )
)

(define-read-only (get-name)
  (ok "Test Token")
)

(define-read-only (get-symbol)
  (ok "TEST")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-public (send-many (recipients (list 1000 { to: principal, amount: uint })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint }))
  (transfer (get amount recipient) tx-sender (get to recipient))
)

(begin
  (var-set total-supply u100000)
  (map-set balances { account: (var-get owner) } u100000)
)
