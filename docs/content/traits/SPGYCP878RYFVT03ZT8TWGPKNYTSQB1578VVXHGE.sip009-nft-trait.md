---
title: "Trait sip009-nft-trait"
draft: true
---
```
;; SIP009 NFT trait
(define-trait nft-trait
    (
        (get-owner (uint) (response (optional principal) uint))
        (transfer (uint principal principal) (response bool uint))
    )
) 
```
