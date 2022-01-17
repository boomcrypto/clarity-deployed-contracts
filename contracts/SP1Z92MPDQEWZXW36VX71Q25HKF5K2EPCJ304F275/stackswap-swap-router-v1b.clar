(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_INVALID_ROUTER (err u4162))
(define-constant ERR_INEFFICIENT_AMOUNT_FROM  (err u90001))
(define-constant ERR_INEFFICIENT_AMOUNT_BRIDGE  (err u90002))
(define-constant ERR_INEFFICIENT_AMOUNT_TO  (err u90003))

(define-public (router-swap
  (from <sip-010-token>) 
  (bridge <sip-010-token>)
  (to <sip-010-token>)
  (from-lp <liquidity-token>)
  (to-lp <liquidity-token>)
  (from-type bool)
  (to-type bool)
  (from-amt uint)
  (from-2-bridge-min-amt uint)
  (bridge-2-to-min-amt uint)
)
  (let
    (
        (pre_from_amt (unwrap-panic (contract-call? from get-balance tx-sender)))
        (pre_bridge_amt (unwrap-panic (contract-call? bridge get-balance tx-sender)))
        (pre_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (asserts! (>= (unwrap-panic (contract-call? from get-balance tx-sender)) from-amt) ERR_INEFFICIENT_AMOUNT_FROM)
    (if (and from-type true)
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-x-for-y from bridge from-lp from-amt from-2-bridge-min-amt))
        )
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-y-for-x bridge from from-lp from-amt from-2-bridge-min-amt))
        )
    )
    (let
        (
            (after_bridge_amt (unwrap-panic (contract-call? bridge get-balance tx-sender)))
            (delta_bridge_amt (- after_bridge_amt pre_bridge_amt))
        )
        (if (and to-type true)
            (begin
                (try! (contract-call? .stackswap-swap-v5k swap-x-for-y bridge to to-lp delta_bridge_amt bridge-2-to-min-amt))
            )
            (begin
                (try! (contract-call? .stackswap-swap-v5k swap-y-for-x to bridge to-lp delta_bridge_amt bridge-2-to-min-amt))
            )
        )
        (let
            (
                (after_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
                (delta_to_amt (- after_to_amt pre_to_amt))
            )

            (ok (list from-amt delta_bridge_amt delta_to_amt))
        )
        
    )
  )
)