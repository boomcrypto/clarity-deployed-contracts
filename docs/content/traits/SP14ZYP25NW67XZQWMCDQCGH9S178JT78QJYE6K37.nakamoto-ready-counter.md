---
title: "Trait nakamoto-ready-counter"
draft: true
---
```
(define-data-var counter uint u0)

(define-read-only (get-heights)
  { bitcoin: burn-block-height, tenure: tenure-height, stacks: stacks-block-height }
)

(define-read-only (get-burnblock-info)
  (get-burn-block-info? pox-addrs burn-block-height)
)

(define-read-only (get-tenureheight-info)
  (get-tenure-info? burnchain-header-hash tenure-height)
)

(define-read-only (get-fastblocks-info)
  (get-stacks-block-info? time stacks-block-height)
)

(define-read-only (get-counter)
  (var-get counter)
)

(define-public (count-up) 
  (ok (var-set counter (+ (var-get counter) u1)))
)
```
