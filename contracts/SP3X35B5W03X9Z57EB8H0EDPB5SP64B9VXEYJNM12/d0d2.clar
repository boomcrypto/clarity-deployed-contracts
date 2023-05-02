(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (swap-x-for-y (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy uint))
    (contract-call?
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
        swap-x-for-y
        token-x-trait
        token-y-trait
        dx
        min-dy
    )
)