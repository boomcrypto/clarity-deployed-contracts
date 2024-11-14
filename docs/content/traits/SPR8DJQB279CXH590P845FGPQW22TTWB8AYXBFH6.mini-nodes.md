---
title: "Trait mini-nodes"
draft: true
---
```
(impl-trait 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.biddable-nft-trait.biddable-nft)

(define-data-var bid-id uint u0)

(define-non-fungible-token POX4 uint)

(define-read-only (get-last-token-id)
    (ok u0))

(define-read-only (get-token-uri (token-id uint))
    (ok (some "")))

(define-read-only (get-owner (token-id uint))
    (ok (some tx-sender)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (ok true))

(define-public (get-royalty-percent)
    (begin
        (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-bid-v6 withdraw-bid (var-get bid-id)))
        (ok u0)))

(define-public (set-bid-id (id uint))
    (ok (var-set bid-id id)))

(define-read-only (get-artist-address)
    (ok tx-sender))
```
