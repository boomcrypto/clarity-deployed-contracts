
(impl-trait .counter-token-trait.sip-010-trait)

(define-fungible-token COUNT)

(define-public (transfer (amount uint) (sender principal) (receiver principal))
    ;; #[allow(unchecked_data)]
    (ft-transfer? COUNT amount sender receiver)
)

(define-public (safe-mint)
    (mint)
)

(define-read-only (get-name)
    (ok "The COUNT token")
)

(define-read-only (get-symbol)
    (ok "COUNT")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance COUNT who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply COUNT))
)

(define-private (mint)
    (ft-mint? COUNT u1 tx-sender)
)