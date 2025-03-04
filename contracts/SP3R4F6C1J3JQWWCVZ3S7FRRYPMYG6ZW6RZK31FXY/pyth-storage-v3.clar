;; Title: pyth-storage
;; Version: v3
;; Check for latest version: https://github.com/Trust-Machines/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/Trust-Machines/stacks-pyth-bridge/issues

(impl-trait .pyth-traits-v1.storage-trait)

(define-constant ERR_NEWER_PRICE_AVAILABLE (err u5001))
(define-constant ERR_STALE_PRICE (err u5002))
(define-constant ERR_RESTRICTED_TO_TESTNET (err u5003))
(define-constant ERR_PRICE_FEED_NOT_FOUND (err u5004))

(define-constant STACKS_BLOCK_TIME u5)

(define-map prices (buff 32) {
  price: int,
  conf: uint,
  expo: int,
  ema-price: int,
  ema-conf: uint,
  publish-time: uint,
  prev-publish-time: uint,
})

(define-map timestamps (buff 32) uint)

(define-public (set-price-testnet
  (data {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint,
  }))
  (begin
    (asserts! (not is-in-mainnet) ERR_RESTRICTED_TO_TESTNET)
    (ok (write-batch-entry data))
  )
)

(define-public (read (price-identifier (buff 32)))
  (let ((entry (unwrap! (map-get? prices price-identifier) ERR_PRICE_FEED_NOT_FOUND)))
    (ok entry)))

(define-read-only (get-price (price-identifier (buff 32)))
  (let ((entry (unwrap! (map-get? prices price-identifier) ERR_PRICE_FEED_NOT_FOUND)))
    (ok entry)))

(define-read-only (read-price-with-staleness-check (price-identifier (buff 32)))
  (let (
      (entry (unwrap! (map-get? prices price-identifier) ERR_PRICE_FEED_NOT_FOUND))
      (stale-price-threshold (contract-call? .pyth-governance-v2 get-stale-price-threshold))
      (latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STALE_PRICE))
    )
    (asserts! (>= (get publish-time entry) (+ (- latest-stacks-timestamp stale-price-threshold) STACKS_BLOCK_TIME)) ERR_STALE_PRICE)
    (ok entry)))

(define-public (write (batch-updates (list 64 {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint,
  })))
  (let ((successful-updates (map unwrapped-entry (filter only-ok-entry (map write-batch-entry batch-updates)))))
    ;; Ensure that updates are always coming from the right contract
    (try! (contract-call? .pyth-governance-v2 check-execution-flow contract-caller none))
    (ok successful-updates)))

(define-private (write-batch-entry (entry {
      price-identifier: (buff 32),
      price: int,
      conf: uint,
      expo: int,
      ema-price: int,
      ema-conf: uint,
      publish-time: uint,
      prev-publish-time: uint,
    }))
    (let ((stale-price-threshold (contract-call? .pyth-governance-v2 get-stale-price-threshold))
          (latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STALE_PRICE))
          (publish-time (get publish-time entry)))
      ;; Ensure that we have not processed a newer price
      (asserts! (is-price-update-more-recent (get price-identifier entry) publish-time) ERR_NEWER_PRICE_AVAILABLE)
      ;; Ensure that price is not stale
      (asserts! (>= publish-time (+ (- latest-stacks-timestamp stale-price-threshold) STACKS_BLOCK_TIME)) ERR_STALE_PRICE)
      ;; Update storage
      (map-set prices 
        (get price-identifier entry) 
        {
          price: (get price entry),
          conf: (get conf entry),
          expo: (get expo entry),
          ema-price: (get ema-price entry),
          ema-conf: (get ema-conf entry),
          publish-time: publish-time,
          prev-publish-time: (get prev-publish-time entry)
        })
      ;; Emit event
      (print {
        type: "price-feed", 
        action: "updated", 
        data: entry
      })
      ;; Update timestamps tracking
      (map-set timestamps (get price-identifier entry) (get publish-time entry))
      (ok entry)))

(define-private (only-ok-entry (entry (response {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint,
  } uint))) (is-ok entry))

(define-private (unwrapped-entry (entry (response {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint,
  } uint))) (unwrap-panic entry))

(define-private (is-price-update-more-recent (price-identifier (buff 32)) (publish-time uint))
  (> publish-time (default-to u0 (map-get? timestamps price-identifier))))
