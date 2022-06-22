(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_INVALID_ROUTER (err u4162))
(define-constant ERR_INEFFICIENT_AMOUNT_FROM  (err u90001))
(define-constant ERR_INEFFICIENT_AMOUNT_TO  (err u90002))


(define-public (exchange-swap
  (from <sip-010-token>) 
  (to <sip-010-token>)
  (swap-lp <liquidity-token>)
  (from-type bool)
  (from-amt uint)
  (to-min-amt uint)
  (receiver principal)
)
  (let
    (
        (pre_from_amt (unwrap-panic (contract-call? from get-balance tx-sender)))
        (pre_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (asserts! (>= (unwrap-panic (contract-call? from get-balance tx-sender)) from-amt) ERR_INEFFICIENT_AMOUNT_FROM)
    (if (and from-type true)
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-x-for-y from to swap-lp from-amt to-min-amt))
        )
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-y-for-x to from swap-lp from-amt to-min-amt))
        )
    )
    (let
        (
            (after_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
            (delta_to_amt (- after_to_amt pre_to_amt))
        )
        (asserts! (> delta_to_amt u0)  ERR_INEFFICIENT_AMOUNT_TO)
        (if (is-eq tx-sender receiver)
            false
            (try! (contract-call? to transfer delta_to_amt tx-sender receiver none))
        )
        (ok {from_amt: from-amt, to_amt: delta_to_amt, receiver: receiver})
    )
  )
)

(define-public (exchange-router1
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
  (receiver principal)
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
            (asserts! (> delta_to_amt u0) ERR_INEFFICIENT_AMOUNT_TO)
            (if (is-eq tx-sender receiver)
                false
                (try! (contract-call? to transfer delta_to_amt tx-sender receiver none))
            )
            (ok {from_amt: from-amt, bridge_amt: delta_bridge_amt, to_amt: delta_to_amt, receiver: receiver})
        )
        
    )
  )
)

(define-public (exchange-router2
  (from <sip-010-token>) 
  (bridge1 <sip-010-token>)
  (bridge2 <sip-010-token>)
  (to <sip-010-token>)
  (from-lp <liquidity-token>)
  (bridge-lp <liquidity-token>)
  (to-lp <liquidity-token>)
  (from-type bool)
  (bridge-type bool)
  (to-type bool)
  (from-amt uint)
  (from-2-bridge1-min-amt uint)
  (bridge1-2-bridge2-min-amt uint)
  (bridge2-2-to-min-amt uint)
  (receiver principal)
)
  (let
    (
        (pre_from_amt (unwrap-panic (contract-call? from get-balance tx-sender)))
        (pre_bridge1_amt (unwrap-panic (contract-call? bridge1 get-balance tx-sender)))
        (pre_bridge2_amt (unwrap-panic (contract-call? bridge2 get-balance tx-sender)))
        (pre_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (asserts! (>= (unwrap-panic (contract-call? from get-balance tx-sender)) from-amt) ERR_INEFFICIENT_AMOUNT_FROM)
    (if (and from-type true)
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-x-for-y from bridge1 from-lp from-amt from-2-bridge1-min-amt))
        )
        (begin
            (try! (contract-call? .stackswap-swap-v5k swap-y-for-x bridge1 from from-lp from-amt from-2-bridge1-min-amt))
        )
    )
    (let
        (
            (after_bridge1_amt (unwrap-panic (contract-call? bridge1 get-balance tx-sender)))
            (delta_bridge1_amt (- after_bridge1_amt pre_bridge1_amt))
        )
        (if (and bridge-type true)
            (begin
                (try! (contract-call? .stackswap-swap-v5k swap-x-for-y bridge1 bridge2 bridge-lp delta_bridge1_amt bridge1-2-bridge2-min-amt))
            )
            (begin
                (try! (contract-call? .stackswap-swap-v5k swap-y-for-x bridge2 bridge1 bridge-lp delta_bridge1_amt bridge1-2-bridge2-min-amt))
            )
        )
        (let
            (
                (after_bridge2_amt (unwrap-panic (contract-call? bridge2 get-balance tx-sender)))
                (delta_bridge2_amt (- after_bridge2_amt pre_bridge2_amt))
            )
            (if (and to-type true)
                (begin
                    (try! (contract-call? .stackswap-swap-v5k swap-x-for-y bridge2 to to-lp delta_bridge2_amt bridge2-2-to-min-amt))
                )
                (begin
                    (try! (contract-call? .stackswap-swap-v5k swap-y-for-x to bridge2 to-lp delta_bridge2_amt bridge2-2-to-min-amt))
                )
            )
            (let
                (
                    (after_to_amt (unwrap-panic (contract-call? to get-balance tx-sender)))
                    (delta_to_amt (- after_to_amt pre_to_amt))
                )
                (asserts! (> delta_to_amt u0) ERR_INEFFICIENT_AMOUNT_TO)
                (if (is-eq tx-sender receiver)
                    false
                    (try! (contract-call? to transfer delta_to_amt tx-sender receiver none))
                )
                (ok {from_amt: from-amt, bridge1_amt: delta_bridge1_amt, bridge2_amt: delta_bridge2_amt, to_amt: delta_to_amt, receiver: receiver})

            )
        ) 
    )
  )
)