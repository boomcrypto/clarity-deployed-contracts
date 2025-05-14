---
title: "Trait constants-v1"
draft: true
---
```
;; Contract to hold the constants

(define-constant SCALING-FACTOR u100000000)

(define-read-only (get-scaling-factor) SCALING-FACTOR)

(define-constant MARKET-TOKEN-DECIMALS u8)

(define-read-only (get-market-token-decimals) MARKET-TOKEN-DECIMALS)

(define-constant STACKS_BLOCK_TIME u5)

(define-read-only (get-stacks-block-time) STACKS_BLOCK_TIME)

```
