(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-constant PERMISSION_DENIED_ERROR u4203)

(define-data-var deployer-principal principal tx-sender)

(define-read-only (get-balance (owner principal))
  (begin
    (ok (print (stx-get-balance owner)))
  )
)

(define-read-only (get-total-supply)
  (ok stx-liquid-supply)
)

(define-read-only (get-name)
  (ok "wrapped STX")
)

(define-read-only (get-symbol)
  (ok "STX")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-data-var uri (string-utf8 256) u"url")

(define-read-only (get-token-uri)
  (ok (some (var-get uri))))


(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err PERMISSION_DENIED_ERROR))
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))


(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err PERMISSION_DENIED_ERROR))
    (if (is-some memo)
      (print memo)
      none
    )
    (stx-transfer? amount tx-sender to)
  )
)