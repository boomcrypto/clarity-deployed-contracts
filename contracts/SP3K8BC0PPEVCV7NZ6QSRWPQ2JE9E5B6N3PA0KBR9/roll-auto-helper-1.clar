(define-public (roll-auto-helper-1 (amount uint))
    (begin 
        (try! (contract-call? .swap-helper-v1-03 swap-helper .age000-governance-token .auto-alex amount none))
        (contract-call? .collateral-rebalancing-pool-v1 roll-auto 
            .ytp-alex-v1
            .age000-governance-token
            .auto-alex
            .yield-alex-v1
            .key-alex-autoalex-v1
            .auto-ytp-alex
            .auto-key-alex-autoalex
        )
    )
)