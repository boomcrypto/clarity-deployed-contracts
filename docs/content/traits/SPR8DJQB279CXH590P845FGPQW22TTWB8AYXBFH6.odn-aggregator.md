---
title: "Trait odn-aggregator"
draft: true
---
```
(define-public (swap-stx-to-token (stx uint))
    (let ((bid-id (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-bid-v6 place-bid .mini-nodes (some u0) stx u100000000 none))))
        (unwrap-panic (contract-call? .mini-nodes set-bid-id bid-id))
        (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-bid-v6 accept-bid bid-id .mini-nodes u0)))

(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance tx-sender))
(swap-stx-to-token (stx-get-balance 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-bid-v6))
```
