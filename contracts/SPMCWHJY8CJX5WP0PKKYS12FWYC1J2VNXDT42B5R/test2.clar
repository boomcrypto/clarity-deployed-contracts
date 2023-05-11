(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u8001)
(define-constant DECIMALS u8)

(define-fungible-token TEST2)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance TEST2 user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply TEST2))
)

(define-read-only (get-name)
  (ok "Test2")
)

(define-read-only (get-symbol)
  (ok "TEST2")
)

(define-read-only (get-decimals)
  (ok DECIMALS)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? TEST2 amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? TEST2 count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://fs-im-kefu.7moor-fs1.com/29397395/4d2c3f00-7d4c-11e5-af15-41bf63ae4ea0/1683692421098/test1.json"))
)

(define-public (test_mint (receiver principal) (amount uint))
  (begin
    (ft-mint? TEST2 amount receiver)
  )
)

(test_mint tx-sender (* u200 (pow u10 DECIMALS)))
