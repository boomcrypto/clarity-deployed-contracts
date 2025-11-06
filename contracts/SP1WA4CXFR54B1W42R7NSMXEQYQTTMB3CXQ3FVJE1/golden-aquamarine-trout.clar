;; golden-aquamarine-trout

(impl-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-fungible-token testB)

(define-data-var token-uri (string-utf8 256) u"")

(define-read-only (get-total-supply)
  (ok (ft-get-supply testB))
)

(define-read-only (get-name)
  (ok "testB Token")
)

(define-read-only (get-symbol)
  (ok "testB")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance testB account))
)

(define-read-only (get-balance-simple (account principal))
  (ft-get-balance testB account)
)


(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1001))

    (match (ft-transfer? testB amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (ft-mint? testB amount recipient)
  )
)

(define-public (burn (amount uint))
  (begin
    (ft-burn? testB amount tx-sender)
  )
)

(mint u100000000000000 'SP1WA4CXFR54B1W42R7NSMXEQYQTTMB3CXQ3FVJE1)