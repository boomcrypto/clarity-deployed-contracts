(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u8001)
(define-constant DECIMALS u8)

(define-fungible-token TEST1)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance TEST1 user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply TEST1))
)

(define-read-only (get-name)
  (ok "Test1")
)

(define-read-only (get-symbol)
  (ok "TEST1")
)

(define-read-only (get-decimals)
  (ok DECIMALS)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? TEST1 amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? TEST1 count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://raw.githubusercontent.com/asdaasdassas/testtt/main/test11.json"))
)

(define-public (test_mint (receiver principal) (amount uint))
  (begin
    (ft-mint? TEST1 amount receiver)
  )
)

(test_mint tx-sender (* u200 (pow u10 DECIMALS)))
