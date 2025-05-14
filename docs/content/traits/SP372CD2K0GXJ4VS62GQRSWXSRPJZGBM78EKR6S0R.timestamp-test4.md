---
title: "Trait timestamp-test4"
draft: true
---
```
(use-trait pyth-storage-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.wormhole-traits-v1.core-trait)

(define-data-var last-timestamp uint u0)

(define-read-only (get-last-stacks-block-time-1 (amount-blocks-back uint) )
    (match (get-stacks-block-info? time (- stacks-block-height amount-blocks-back)) timestamp
        timestamp
        u0
    )
)

(define-read-only (get-stacks-block-time (blockheight uint) )
    (match (get-stacks-block-info? time blockheight) timestamp
        timestamp
        u0
    )
)

(define-public (set-last-stacks-blocktime (amount-blocks-back uint))
    (ok (match (get-stacks-block-info? time (- stacks-block-height amount-blocks-back)) timestamp
        (var-set last-timestamp timestamp)
        false
    ))
)

(define-read-only (get-last-timestamp)
    (var-get last-timestamp)
)

(define-read-only (get-stacks-block-height)
    stacks-block-height
)

(define-read-only (get-burn-block-height)
    burn-block-height
)

(define-public (valid-oracle-timestamp 
  (price-feed-bytes (buff 8192))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  
  (let (
    (decoded-price (element-at (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2 decode-price-feeds price-feed-bytes execution-plan)) u0))
    (oracle-price (to-uint (unwrap-panic (get price decoded-price))))
    (oracle-timestamp (unwrap-panic (get publish-time decoded-price)))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    (oracle-price-feed-id (unwrap-panic (get price-identifier decoded-price)))
  )

    (print { oracle-price: oracle-price, oracle-timestamp: oracle-timestamp, block-timestamp: block-timestamp})
    (ok (>= oracle-timestamp block-timestamp))
  )
)
```
