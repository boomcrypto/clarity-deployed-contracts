---
title: "Trait visible-azure-snail"
draft: true
---
```
(define-read-only (get-last-block-time)
  (ok (get-stacks-block-info? time stacks-block-height))
)

(define-read-only (get-block-time (height uint))
  (ok (get-stacks-block-info? time height))
)

(define-read-only (get-last-block-height) 
  (ok stacks-block-height)
)

  
```
