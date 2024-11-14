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
        (w-iw-r0 (* (get reserve01 pools) welsh-price))
        (w-iw-r1 (* (get reserve11 pools) iouwelsh-price))
        (c-w-r0 (* (get reserve02 pools) cha-price))
        (c-w-r1 (* (get reserve12 pools) welsh-price))
        (c-iw-r0 (* (get reserve03 pools) cha-price))
        (c-iw-r1 (* (get reserve13 pools) iouwelsh-price))
        (s-c-r0 (* (get reserve04 pools) stx-price))
        (s-c-r1 (* (get reserve14 pools) cha-price))
        (s-ss-r0 (* (get reserve05 pools) stx-price))
        (s-ss-r1 (* (get reserve15 pools) synstx-price))
        (s-p-r0 (* (get reserve06 pools) stx-price))
        (s-p-r1 (* (get reserve16 pools) pepe-price))
        (c-p-r0 (* (get reserve07 pools) cha-price))
        (c-p-r1 (* (get reserve17 pools) pepe-price))
        (s-ss-c-w-r0 (* (get reserve08 pools) stx-syn-lp-price))
        (s-ss-c-w-r1 (* (get reserve18 pools) cha-welsh-lp-price))
        (c-w-iw-r0 (* (get reserve09 pools) cha-price))
        (c-w-iw-r1 (* (get reserve19 pools) welsh-iou-lp-price))
    )
    (ok {
        stx-welsh: {reserve0: s-w-r0, reserve1: s-w-r1},
        welsh-iou: {reserve0: w-iw-r0, reserve1: w-iw-r1},
        cha-welsh: {reserve0: c-w-r0, reserve1: c-w-r1},
        cha-iou: {reserve0: c-iw-r0, reserve1: c-iw-r1},
        stx-cha: {reserve0: s-c-r0, reserve1: s-c-r1},
        stx-syn: {reserve0: s-ss-r0, reserve1: s-ss-r1},
        stx-pepe: {reserve0: s-p-r0, reserve1: s-p-r1},
        cha-pepe: {reserve0: c-p-r0, reserve1: c-p-r1},
        syn-cha-welsh: {reserve0: s-ss-c-w-r0, reserve1: s-ss-c-w-r1},
        cha-welsh-iou: {reserve0: c-w-iw-r0, reserve1: c-w-iw-r1},
        lp-prices: {
            stx-synstx: stx-syn-lp-price,
            cha-welsh: cha-welsh-lp-price,
            welsh-iouwelsh: welsh-iou-lp-price
        }
    })))