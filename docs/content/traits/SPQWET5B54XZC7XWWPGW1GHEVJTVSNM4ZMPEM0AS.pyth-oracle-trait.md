---
title: "Trait pyth-oracle-trait"
draft: true
---
```
(use-trait pyth-storage-trait .pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait .pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait .wormhole-traits-v1.core-trait)

(define-trait pyth-oracle-trait
  (
    (decode-price-feeds ((buff 8192) {
      pyth-storage-contract: <pyth-storage-trait>,
      pyth-decoder-contract: <pyth-decoder-trait>,
      wormhole-core-contract: <wormhole-core-trait>
    }) (response (list 64 {
      price-identifier: (buff 32),
      price: int,
      conf: uint,
      expo: int,
      ema-price: int,
      ema-conf: uint,
      publish-time: uint,
      prev-publish-time: uint,
    }) uint))
  )
)
```
