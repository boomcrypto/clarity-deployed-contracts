(use-trait stackswap-sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait stackswap-liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

(define-private (swap-helper-a
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (dx uint)
)
    (let
        ((swapped-amounts
            (try! (as-contract (if stackswap-inverse
                (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
                    stackswap-token-x-trait
                    stackswap-token-y-trait
                    stackswap-token-liquidity-trait
                    dx
                    u0)
                (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
                    stackswap-token-x-trait
                    stackswap-token-y-trait
                    stackswap-token-liquidity-trait
                    dx
                    u0))))))
        (ok (unwrap-panic (element-at swapped-amounts (if stackswap-inverse u0 u1))))
    )
)

(define-public (swap-help-b
    (token-a-trait <stackswap-sip-010-token>)
    (token-b-trait <stackswap-sip-010-token>)
    (token-c-trait <stackswap-sip-010-token>)
    (token-d-trait <stackswap-sip-010-token>)
    (token-e-trait <stackswap-sip-010-token>)
    (token-f-trait <stackswap-sip-010-token>)
    (liquidity-ab-trait <stackswap-liquidity-token>)
    (liquidity-cd-trait <stackswap-liquidity-token>)
    (liquidity-ef-trait <stackswap-liquidity-token>)
    (inverse-ab bool)
    (inverse-cd bool)
    (inverse-ef bool)
    (amount-in uint)
)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (stx-transfer? amount-in tx-sender (as-contract tx-sender)))

        (let
            (
                (amount-b (unwrap-panic (swap-helper-a token-a-trait token-b-trait liquidity-ab-trait inverse-ab amount-in)))
                (amount-d (unwrap-panic (swap-helper-a token-c-trait token-d-trait liquidity-cd-trait inverse-cd amount-b)))
                (amount-out (unwrap-panic (swap-helper-a token-e-trait token-f-trait liquidity-ef-trait inverse-ef amount-d)))
            )
            (asserts! (> amount-out amount-in)
                (err u101)
            )
            (try! (as-contract (stx-transfer? amount-out tx-sender contract-owner)))
            (ok amount-out)
        )
    )
)
