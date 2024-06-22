---
title: "Trait traits"
draft: true
---
```
(define-trait asset-wrapper-trait
  ((transfer-in (uint) (response uint uint))
   (transfer-out (uint principal) (response uint uint))
   (get-name () (response (string-ascii 32) uint))
   (get-symbol () (response (string-ascii 32) uint))
   (get-decimals () (response uint uint))
   (get-balance (principal) (response uint uint))
   (get-underlying () (response (optional principal) uint))))

(define-trait block-height-provider-trait
  ((get-block-height () (response uint uint))))

(define-trait pair-logic-trait
  ((join (principal principal uint uint uint uint uint) (response uint uint))
   (exit (principal principal uint uint uint uint) (response {amount0: uint, amount1: uint} uint))
   (swap-given-in (principal principal uint uint uint) (response uint uint))
   (swap-given-out (principal principal uint uint uint) (response uint uint))))

```
