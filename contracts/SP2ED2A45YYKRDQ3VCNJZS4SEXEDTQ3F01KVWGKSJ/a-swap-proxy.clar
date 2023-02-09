(use-trait trait-a-swap-proxy .trait-a-swap-proxy.trait-a-swap-proxy)
(use-trait trait-a-swap .trait-a-swap.trait-a-swap)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public 
    (swap-x-for-y
        (trait-proxy <trait-a-swap-proxy>)
        (trait <trait-a-swap>)
        (token-x <ft-trait>)
        (token-y <ft-trait>)
        (dx uint)
        (min-dy uint)
    )

    (ok (try! (contract-call? trait-proxy swap-x-for-y trait token-x token-y dx min-dy)))
)

(define-public 
    (swap-y-for-x
        (trait-proxy <trait-a-swap-proxy>)
        (trait <trait-a-swap>)
        (token-x <ft-trait>)
        (token-y <ft-trait>)
        (dy uint)
        (min-dx uint)
    )

    (ok (try! (contract-call? trait-proxy swap-y-for-x trait token-x token-y dy min-dx)))
)
