
(define-private (swap-x-y (input (response (list 2 uint) uint)))
    (unwrap-panic (element-at (unwrap-panic input) u1))
)

(define-private (swap-y-x (input (response (list 2 uint) uint)))
    (unwrap-panic (element-at (unwrap-panic input) u0))
)

(define-public (test (amount uint) (swaps (list 30 uint)))
    (begin
        (asserts! (< amount (fold magic swaps amount)) (err u999999))
        (ok true)
    )
)

(define-private (magic (swapId uint) (amount uint))
    (begin
        (asserts! (> swapId u1) (arkadiko-stx-diko-x-y amount))
        (asserts! (> swapId u2) (arkadiko-stx-diko-y-x amount))
        (asserts! (> swapId u3) (arkadiko-stx-usda-x-y amount))
        (asserts! (> swapId u4) (arkadiko-stx-usda-y-x amount))
        (asserts! (> swapId u5) (arkadiko-diko-usda-x-y amount))
        (asserts! (> swapId u6) (arkadiko-diko-usda-y-x amount))
        (asserts! (> swapId u7) (stackswap-stx-usda-x-y amount))
        (asserts! (> swapId u8) (stackswap-stx-usda-y-x amount))
        (asserts! (> swapId u9) (stackswap-stx-diko-x-y amount))
        (asserts! (> swapId u10) (stackswap-stx-diko-y-x amount))
        u0
    )
)

;; ID = 1
(define-private (arkadiko-stx-diko-x-y (amount uint))
    (swap-x-y    
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            amount
            u1
        )
    )
)

;; ID = 2
(define-private (arkadiko-stx-diko-y-x (amount uint))
    (swap-y-x
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            amount
            u1
        )
    )
)

;; ID = 3
(define-private (arkadiko-stx-usda-x-y (amount uint))
    (swap-x-y
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            amount
            u1
        )
    )
)

;; ID = 4
(define-private (arkadiko-stx-usda-y-x (amount uint))
    (swap-y-x
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            amount
            u1
        )
    )
)

;; ID = 5
(define-private (arkadiko-diko-usda-x-y (amount uint))
    (swap-x-y
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            amount
            u1
        )
    )
)

;; ID = 6
(define-private (arkadiko-diko-usda-y-x (amount uint))
    (swap-y-x
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            amount
            u1
        )
    )
)

;; ID = 7
(define-private (stackswap-stx-usda-x-y (amount uint))
    (swap-x-y
        (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
            amount
            u1
        )
    )
)

;; ;; ID = 8
(define-private (stackswap-stx-usda-y-x (amount uint))
    (swap-y-x
        (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
            amount
            u1
        )
    )
)

;; ;; ID = 9
(define-private (stackswap-stx-diko-x-y (amount uint))
    (swap-x-y
        (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
            amount
            u1
        )
    )
)

;; ;; ID = 10
(define-private (stackswap-stx-diko-y-x (amount uint))
    (swap-y-x
        (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
            amount
            u1
        )
    )
)