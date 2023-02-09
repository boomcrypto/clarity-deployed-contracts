(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-trait trait-arkadiko-swap
    (   
        ( swap-x-for-y ( <ft-trait> <ft-trait> uint uint ) (response (list 2 uint) uint) )
        ( swap-y-for-x ( <ft-trait> <ft-trait> uint uint ) (response (list 2 uint) uint) )
    )
)