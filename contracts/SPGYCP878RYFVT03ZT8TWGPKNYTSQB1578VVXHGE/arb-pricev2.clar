(define-read-only (reserves)
    (let (
        (s-w (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u27)) ;; velar stx-welsh
        (s-p (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u11)) ;; velar stx-pepe
        (w-iw (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u1)) ;; chadex welsh-iouwelsh
        (c-w (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u3)) ;; chadex cha-welsh
        (c-iw (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u5)) ;; chadex cha-iouwelsh
        (s-c (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u4)) ;; chadex stx-cha
        (s-ss (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u10)) ;; chadex stx-synstx
        (c-p (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u12)) ;; chadex cha-pepe
        (s-ss-c-w (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u13)) ;; chadex s-ss-c-w
        (c-w-iw (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool u11)) ;; chadex c-w-iw
    )
    {
        reserve00: (get reserve0 s-w),
        reserve10: (get reserve1 s-w),
        reserve01: (get reserve0 w-iw),
        reserve11: (get reserve1 w-iw),
        reserve02: (get reserve0 c-w),
        reserve12: (get reserve1 c-w),
        reserve03: (get reserve0 c-iw),
        reserve13: (get reserve1 c-iw),
        reserve04: (get reserve0 s-c),
        reserve14: (get reserve1 s-c),
        reserve05: (get reserve0 s-ss),
        reserve15: (get reserve1 s-ss),
        reserve06: (get reserve0 s-p),
        reserve16: (get reserve1 s-p),
        reserve07: (get reserve0 c-p),
        reserve17: (get reserve1 c-p),
        reserve08: (get reserve0 s-ss-c-w),
        reserve18: (get reserve1 s-ss-c-w),
        reserve09: (get reserve0 c-w-iw),
        reserve19: (get reserve1 c-w-iw)
    })
)
(define-read-only (supplies)
    (let (
        (c-w-sup (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-welsh get-total-supply))
        (w-iw-sup (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.welsh-iouwelsh get-total-supply))
        (s-ss-sup (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-synstx get-total-supply))
    )
    {
        cha-welsh: c-w-sup,
        welsh-iou: w-iw-sup,
        wstx-synstx: s-ss-sup
    })
)
(define-public (call-me)
    (let (
        (pool-reserves (reserves))
        (sups (supplies))
    )
    (ok {
        pools: {
            reserve00: (get reserve00 pool-reserves),
            reserve10: (get reserve10 pool-reserves),
            reserve01: (get reserve01 pool-reserves),
            reserve11: (get reserve11 pool-reserves),
            reserve02: (get reserve02 pool-reserves),
            reserve12: (get reserve12 pool-reserves),
            reserve03: (get reserve03 pool-reserves),
            reserve13: (get reserve13 pool-reserves),
            reserve04: (get reserve04 pool-reserves),
            reserve14: (get reserve14 pool-reserves),
            reserve05: (get reserve05 pool-reserves),
            reserve15: (get reserve15 pool-reserves),
            reserve06: (get reserve06 pool-reserves),
            reserve16: (get reserve16 pool-reserves),
            reserve07: (get reserve07 pool-reserves),
            reserve17: (get reserve17 pool-reserves),
            reserve08: (get reserve08 pool-reserves),
            reserve18: (get reserve18 pool-reserves),
            reserve09: (get reserve09 pool-reserves),
            reserve19: (get reserve19 pool-reserves)
        },
        supplies: {
            cha-welsh: (get cha-welsh sups),
            welsh-iou: (get welsh-iou sups),
            wstx-synstx: (get wstx-synstx sups)
        }
    }))
)