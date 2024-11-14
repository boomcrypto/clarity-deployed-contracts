---
title: "Trait arb-finalv3"
draft: true
---
```
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-pool (err u101))

(define-public (get-reserve-values)
    (let (
        (pool-data (unwrap! (contract-call? .arb-pricev3 call-me) err-invalid-pool))
        (prices (unwrap! (contract-call? .arb-calc-p3 get-prices) err-invalid-pool))
        (pools (get pools pool-data))
        (supplies (get supplies pool-data))
        (welsh-price (get welsh prices))
        (pepe-price (get pepe prices))
        (iouwelsh-price (get iouwelsh prices))
        (cha-price (get cha prices))
        (synstx-price (get synstx prices))
        (stx-price u1000000)
        (stx-syn-r0-val (* (get reserve05 pools) stx-price))
        (stx-syn-r1-val (* (get reserve15 pools) synstx-price))
        (stx-syn-total (+ stx-syn-r0-val stx-syn-r1-val))
        (stx-syn-lp-price (/ stx-syn-total (get wstx-synstx supplies)))
        (cha-welsh-r0-val (* (get reserve02 pools) cha-price))
        (cha-welsh-r1-val (* (get reserve12 pools) welsh-price))
        (cha-welsh-total (+ cha-welsh-r0-val cha-welsh-r1-val))
        (cha-welsh-lp-price (/ cha-welsh-total (get cha-welsh supplies)))
        (welsh-iou-r0-val (* (get reserve01 pools) welsh-price))
        (welsh-iou-r1-val (* (get reserve11 pools) iouwelsh-price))
        (welsh-iou-total (+ welsh-iou-r0-val welsh-iou-r1-val))
        (welsh-iou-lp-price (/ welsh-iou-total (get welsh-iou supplies)))
        (s-w-r0 (* (get reserve00 pools) welsh-price))
        (s-w-r1 (* (get reserve10 pools) stx-price))
        (s-w-diff (* (- s-w-r0 s-w-r1) (- s-w-r0 s-w-r1)))
        (w-iw-r0 (* (get reserve01 pools) welsh-price))
        (w-iw-r1 (* (get reserve11 pools) iouwelsh-price))
        (w-iw-diff (* (- w-iw-r0 w-iw-r1) (- w-iw-r0 w-iw-r1)))
        (c-w-r0 (* (get reserve02 pools) cha-price))
        (c-w-r1 (* (get reserve12 pools) welsh-price))
        (c-w-diff (* (- c-w-r0 c-w-r1) (- c-w-r0 c-w-r1)))
        (c-iw-r0 (* (get reserve03 pools) cha-price))
        (c-iw-r1 (* (get reserve13 pools) iouwelsh-price))
        (c-iw-diff (* (- c-iw-r0 c-iw-r1) (- c-iw-r0 c-iw-r1)))
        (s-c-r0 (* (get reserve04 pools) stx-price))
        (s-c-r1 (* (get reserve14 pools) cha-price))
        (s-c-diff (* (- s-c-r0 s-c-r1) (- s-c-r0 s-c-r1)))
        (s-ss-r0 (* (get reserve05 pools) stx-price))
        (s-ss-r1 (* (get reserve15 pools) synstx-price))
        (s-ss-diff (* (- s-ss-r0 s-ss-r1) (- s-ss-r0 s-ss-r1)))
        (s-p-r0 (* (get reserve06 pools) stx-price))
        (s-p-r1 (* (get reserve16 pools) pepe-price))
        (s-p-diff (* (- s-p-r0 s-p-r1) (- s-p-r0 s-p-r1)))
        (c-p-r0 (* (get reserve07 pools) cha-price))
        (c-p-r1 (* (get reserve17 pools) pepe-price))
        (c-p-diff (* (- c-p-r0 c-p-r1) (- c-p-r0 c-p-r1)))
        (s-ss-c-w-r0 (* (get reserve08 pools) stx-syn-lp-price))
        (s-ss-c-w-r1 (* (get reserve18 pools) cha-welsh-lp-price))
        (s-ss-c-w-diff (* (- s-ss-c-w-r0 s-ss-c-w-r1) (- s-ss-c-w-r0 s-ss-c-w-r1)))
        (c-w-iw-r0 (* (get reserve09 pools) cha-price))
        (c-w-iw-r1 (* (get reserve19 pools) welsh-iou-lp-price))
        (c-w-iw-diff (* (- c-w-iw-r0 c-w-iw-r1) (- c-w-iw-r0 c-w-iw-r1)))
    )
    (ok {
        stx-welsh: {reserve0: s-w-r0, reserve1: s-w-r1, difference: s-w-diff},
        welsh-iou: {reserve0: w-iw-r0, reserve1: w-iw-r1, difference: w-iw-diff},
        cha-welsh: {reserve0: c-w-r0, reserve1: c-w-r1, difference: c-w-diff},
        cha-iou: {reserve0: c-iw-r0, reserve1: c-iw-r1, difference: c-iw-diff},
        stx-cha: {reserve0: s-c-r0, reserve1: s-c-r1, difference: s-c-diff},
        stx-syn: {reserve0: s-ss-r0, reserve1: s-ss-r1, difference: s-ss-diff},
        stx-pepe: {reserve0: s-p-r0, reserve1: s-p-r1, difference: s-p-diff},
        cha-pepe: {reserve0: c-p-r0, reserve1: c-p-r1, difference: c-p-diff},
        syn-cha-welsh: {reserve0: s-ss-c-w-r0, reserve1: s-ss-c-w-r1, difference: s-ss-c-w-diff},
        cha-welsh-iou: {reserve0: c-w-iw-r0, reserve1: c-w-iw-r1, difference: c-w-iw-diff},
        lp-prices: {
            stx-synstx: stx-syn-lp-price,
            cha-welsh: cha-welsh-lp-price,
            welsh-iouwelsh: welsh-iou-lp-price
        }
    })))
```
