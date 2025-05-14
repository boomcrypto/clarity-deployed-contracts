---
title: "Trait sip-010-trait"
draft: true
---
```
(define-trait sip-010-trait
    (
        ;; Transfer from the caller to a new principal
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))

        ;; Get the token balance of the specified principal
        (get-balance (principal) (response uint uint))

        ;; Get the total number of tokens
        (get-total-supply () (response uint uint))

        ;; Get the token decimals
        (get-decimals () (response uint uint))

        ;; Get human-readable name of the token
        (get-name () (response (string-ascii 32) uint))

        ;; Get the symbol/ticker of the token
        (get-symbol () (response (string-ascii 32) uint))

        ;; Optional URI for token metadata
        (get-token-uri () (response (optional (string-utf8 256)) uint))
    )
)

```
