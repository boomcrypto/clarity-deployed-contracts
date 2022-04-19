(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-read-only (get-balance (owner principal))
    (ok (stx-get-balance owner))
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-name)
    (ok "Wrapped STX")
)

(define-read-only (get-symbol)
    (ok "WSTX")
)

(define-read-only (get-token-uri)
    (ok (some u"https://www.stacks.co"))
)

(define-read-only (get-total-supply)
    (ok stx-liquid-supply)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (try! (stx-transfer? amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)