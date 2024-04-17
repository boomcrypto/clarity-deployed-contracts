;; ---------------------------------------------------------
;; FrodoSaylorKeanuPepe10Inu Token
;; ---------------------------------------------------------

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token FrodoSaylorKeanuPepe10Inu)
(define-constant contract-owner tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-constant ERR_GIT_GOOD (err u100))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_GIT_GOOD)
    (try! (ft-transfer? FrodoSaylorKeanuPepe10Inu amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance FrodoSaylorKeanuPepe10Inu owner))
)

(define-read-only (get-name)
  (ok "FrodoSaylorKeanuPepe10Inu")
)

(define-read-only (get-symbol)
  (ok "ETHEREUM")
)

(define-read-only (get-decimals)
  (ok u18)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply FrodoSaylorKeanuPepe10Inu))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set token-uri (some value)))
    (err ERR_GIT_GOOD)
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

(begin
  (try! (ft-mint? FrodoSaylorKeanuPepe10Inu u120138879310000000000000000 'SP1X7JGV8DXEF0A4J1NNVZXK33WYGB0XH2M02BKWD))
)