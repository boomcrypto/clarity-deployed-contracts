(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-public (redeem-auto-and-reduce-from-yield-token-pool 
    (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (auto-token-trait <ft-trait>) (percent uint))
    (let 
        (
            (expiry (try! (contract-call? .collateral-rebalancing-pool-v1 get-last-expiry (contract-of pool-token-trait))))
        ) 
        (try! (contract-call? .collateral-rebalancing-pool-v1 redeem-auto-and-reduce-from-yield-token-pool yield-token-trait token-trait pool-token-trait auto-token-trait percent))
        (contract-call? .yield-token-pool reduce-position expiry yield-token-trait token-trait pool-token-trait ONE_8)
    )
)