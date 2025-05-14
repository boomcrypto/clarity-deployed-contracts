---
title: "Trait wstx"
draft: true
---
```

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-read-only (get-name)
    (ok "Wrapped STX"))

(define-read-only (get-symbol)
    (ok "wstx"))

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-balance (who principal))
    (ok (stx-get-balance who)))

(define-read-only (get-total-supply)
    (ok stx-liquid-supply))

(define-read-only (get-token-uri)
    (ok (some u"https://memecrazy.fun")))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (stx-transfer? amount from to))
    
```
