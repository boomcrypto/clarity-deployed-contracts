---
title: "Trait gl-oracle"
draft: true
---
```
;; Offchain-signed oracle prices.
;;
;; https://github.com/Trust-Machines/stacks-pyth-bridge?tab=readme-ov-file
;;

(impl-trait .gl-oracle-trait-pyth.oracle-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-permissions (err u500))
(define-constant err-price       (err u501))
(define-constant err-extraction  (err u502))
(define-constant err-invariants  (err u599))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-private
  (INTERNAL)
  (begin
   (asserts! (is-eq contract-caller .gl-api) err-permissions)
   (ok true)))

(define-data-var deployer principal tx-sender)
(define-data-var extractor principal tx-sender)

(define-private (DEPLOYER)
  (ok (asserts! (is-eq tx-sender (var-get deployer)) err-permissions)))

(define-public (set-deployer (deployer_ principal))
 (begin
    (try! (DEPLOYER))
    (ok (var-set deployer deployer_))))

(define-public (set-extractor (extractor_ principal))
 (begin
    (try! (DEPLOYER))
    (ok (var-set extractor extractor_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; state
(define-map prices
  uint ;;block
  uint ;;price
  )

(define-data-var TIMESTAMP uint u0)
(define-data-var DECIMALS uint u8)
(define-data-var FEED-ID (buff 32) 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)

(define-public (set-decimals (decimals_ uint))
  (begin
    (try! (DEPLOYER))
    (ok (var-set DECIMALS decimals_))))

(define-public (set-feed-id (feed-id_ (buff 32)))
  (begin
    (try! (DEPLOYER))
    (ok (var-set FEED-ID feed-id_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; price
(define-read-only (check-slippage (current uint) (desired uint) (slippage uint))
  (if (> current desired)
      (<= (- current desired) slippage)
      (<= (- desired current) slippage)))

(define-read-only (check-price (p uint))
  (> p u0))

(define-private (get-or-set-block-price (current uint))
  (let ((block-price (default-to u0 (map-get? prices stacks-block-height))))
    (if (is-eq block-price u0)
      (begin
        (map-set prices stacks-block-height current)
        current
      )
      block-price)))

(define-public
  (price
    (quote-decimals uint)
    (desired        uint)
    (slippage       uint)
    (identifier     (buff 32))
    (message        (buff 8192)) )
      (let ((price0     (try! (extract-price quote-decimals identifier message)))
            (price1     (get-or-set-block-price price0))
            (acceptable (check-slippage price1 desired slippage))
            (valid      (check-price price1))
            )
      (try! (INTERNAL))
      (asserts! acceptable err-price)
      (asserts! valid      err-price)
      (ok price1) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public
  (extract-price
    (qd          uint)
    (identifier (buff 32))
    (message    (buff 8192))
    ;; (ctx        { identifier: (buff 32), message: (buff 8192) })
  )
  (let ((res0 (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3
                              verify-and-update-price-feeds
                              message
                              {
                                pyth-storage-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3,
                                pyth-decoder-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2,
                                wormhole-core-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3
                              })))
        (res    (unwrap-panic (element-at? res0 u0)))
        (id     (get price-identifier res))
        (price0 (to-uint (get price res))) ;; !!
        (ts     (get publish-time res))
        (newer  (>= ts (var-get TIMESTAMP)))
        (pd     (var-get DECIMALS))
        (s      (>= pd qd))
        (n      (if s (- pd qd) (- qd pd)))
        (m      (pow u10 n))
        (price_ (if s (/ price0 m) (* price0 m)))
        )

    (asserts! (is-eq id identifier) (err u888))
    (asserts! newer err-extraction)
    (asserts! (is-eq identifier (var-get FEED-ID)) err-extraction)
    (var-set TIMESTAMP ts)
    (ok price_))
)

;;; eof

```
