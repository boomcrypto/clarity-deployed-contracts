;; ---------------------------------------------------------
;; Something Token
;; ---------------------------------------------------------

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Something)
(define-constant contract-owner tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://raw.githubusercontent.com/mafakajan/something/main/something.json"))

(define-constant ERR_YOU_RICH (err u100))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_YOU_RICH)
    (try! (ft-transfer? Something amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance Something owner))
)

(define-read-only (get-name)
  (ok "Something")
)

(define-read-only (get-symbol)
  (ok "SOME")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply Something))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set token-uri (some value)))
    (err ERR_YOU_RICH)
  )
)

(define-public (send-many (recipients (list 1000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)
;; 88,975,877,083,900
(begin
  (try! (ft-mint? Something u88975877083900 'SP3MRT36YWK7R0SKFCQ1TDJB3Y3XBAVRFXPYBQ33E))
)