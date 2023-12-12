;; Title: pyth-traits
;; Version: v1
;; Check for latest version: https://github.com/hirosystems/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/hirosystems/stacks-pyth-bridge/issues

(use-trait wormhole-core-trait .wormhole-traits-v1.core-trait)

(define-trait decoder-trait
  (
    (decode-and-verify-price-feeds ((buff 8192) <wormhole-core-trait>) (response (list 64 {
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

(define-trait storage-trait
  (
    (read ((buff 32)) (response {
      price: int,
      conf: uint,
      expo: int,
      ema-price: int,
      ema-conf: uint,
      publish-time: uint,
      prev-publish-time: uint,
    } uint))

    (write ((list 64 {
      price-identifier: (buff 32),
      price: int,
      conf: uint,
      expo: int,
      ema-price: int,
      ema-conf: uint,
      publish-time: uint,
      prev-publish-time: uint,
    })) (response (list 64 {
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

(define-trait proxy-trait
  (
    (read-price-feed ((buff 32)) (response {
      price: int,
      conf: uint,
      expo: int,
      ema-price: int,
      ema-conf: uint,
      publish-time: uint,
      prev-publish-time: uint,
    } uint))

    (verify-and-update-price-feeds ((buff 8192) <wormhole-core-trait>) (response (list 64 {
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
