(impl-trait 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token test)

(define-constant ERR_NOT_AUTHORIZED (err u1001))

(define-data-var token-uri (string-utf8 256) u"")

(define-read-only (get-name)
  (ok "Test Token")
)

(define-read-only (get-symbol)
  (ok "TEST")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply test))
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance test account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
    (print (default-to 0x memo))
    (ft-transfer? test amount sender recipient)
  )
)

(define-public (mint (amount uint) (account principal))
  (ok true)
)

(define-public (burn (amount uint) (account principal))
  (ok true)
)

(ft-mint? test u1000000000 tx-sender)