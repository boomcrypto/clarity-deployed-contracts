(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait trait-a-swap .trait-a-swap.trait-a-swap)

(define-trait trait-a-swap-proxy
    (   
        ( swap-x-for-y ( <trait-a-swap> <ft-trait> <ft-trait> uint uint ) (response (list 2 uint) uint) )
        ( swap-y-for-x ( <trait-a-swap> <ft-trait> <ft-trait> uint uint ) (response (list 2 uint) uint) )
    )
)