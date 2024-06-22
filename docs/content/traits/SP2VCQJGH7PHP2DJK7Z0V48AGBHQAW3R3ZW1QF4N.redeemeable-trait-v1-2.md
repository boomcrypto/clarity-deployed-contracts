---
title: "Trait redeemeable-trait-v1-2"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait a-token .a-token-trait.a-token-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-trait redeemeable-trait
	(
    ;; redeemeable signatures
		(cumulate-balance
      (principal)
      (response (tuple
        (previous-user-balance uint)
        (current-balance uint)
        (balance-increase uint)
        (index uint))
        uint))
    ;; mint/burn
    (mint (uint principal) (response bool uint))
    (burn (uint principal) (response bool uint))

    ;; sip-010
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
	)
)

```
