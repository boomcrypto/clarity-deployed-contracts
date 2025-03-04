(use-trait ft-trait .alex-trait-sip-010.sip-010-trait)

(define-trait pool-trait
    (
        (swap-helper (<ft-trait> <ft-trait> uint uint (optional uint)) (response uint uint))
        (swap-helper-a (<ft-trait> <ft-trait> <ft-trait> uint uint uint (optional uint)) (response uint uint))
        (swap-helper-b (<ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint (optional uint)) (response uint uint))
        (swap-helper-c (<ft-trait> <ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint uint (optional uint)) (response uint uint))
    )
)