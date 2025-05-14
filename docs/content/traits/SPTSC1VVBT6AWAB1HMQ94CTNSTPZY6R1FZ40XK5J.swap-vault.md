---
title: "Trait swap-vault"
draft: true
---
```

    (use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

    (define-constant OWNER tx-sender)
    (define-constant VAULT-CA (as-contract tx-sender))
    (define-data-var TRANSFER-AUTHORITY principal 'SPTSC1VVBT6AWAB1HMQ94CTNSTPZY6R1FZ40XK5J.swap-core)

    (define-constant err-not-contract-owner (err u1001))
    (define-constant err-not-transfer-authority (err u5001))

    (define-read-only (get-transfer-authority) (var-get TRANSFER-AUTHORITY))

    (define-public (vault-stx-out (amount uint) (recipient principal))
        (begin
            (asserts! (is-eq tx-sender (var-get TRANSFER-AUTHORITY)) err-not-transfer-authority) 
            (try! (as-contract (stx-transfer? amount VAULT-CA recipient)))
            (ok true)
        )
    )

    (define-public (vault-token-out (token-contract <sip-010>) (amount uint) (recipient principal))
        (begin
            (asserts! (is-eq tx-sender (var-get TRANSFER-AUTHORITY)) err-not-transfer-authority) 
            (try! (as-contract (contract-call? token-contract transfer amount VAULT-CA recipient none)))
            (ok true)
        )
    )

    (define-public (set-transfer-authority (authority principal))
        (begin
            (asserts! (is-eq tx-sender OWNER) err-not-contract-owner) 
            (var-set TRANSFER-AUTHORITY authority)
            (ok true)
        )
    )
    
```
