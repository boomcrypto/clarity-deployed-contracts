---
title: "Trait homely-salmon-owl"
draft: true
---
```
(impl-trait 'STTCSBVXZ6KNV7JEMHAV7KJM9183VAP310X4M53G.nft-trait.nft-trait)

(define-constant CONTRACT-OWNER tx-sender)
;; (define-data-var rec 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

(define-non-fungible-token test uint)


(define-data-var last-token-id uint u0)

(define-read-only (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok none)
)

(define-public (mint)
    (nft-mint? test u1 tx-sender)
)

(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? test token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))

(nft-transfer? test token-id sender recipient)

)
```
