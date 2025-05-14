---
title: "Trait bsd-trait-vpv-3"
draft: true
---
```
(define-trait bsd-trait
  (
    (protocol-mint (principal uint) (response bool uint))
    (protocol-transfer (uint principal principal) (response bool uint))
    (protocol-burn (principal uint) (response bool uint))
  )
) 
```
