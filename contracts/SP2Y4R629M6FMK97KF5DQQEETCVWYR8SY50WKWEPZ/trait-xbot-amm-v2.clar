(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-trait amm-pool-v2-01-trait
    (
        (swap-helper (<ft-trait> <ft-trait> uint uint (optional uint)) (response uint uint))

        (swap-helper-a (<ft-trait> <ft-trait> <ft-trait> uint uint uint (optional uint)) (response uint uint))

        (swap-helper-b (<ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint (optional uint)) (response uint uint))

        (swap-helper-c (<ft-trait> <ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint uint (optional uint)) (response uint uint))

        (swap-x-for-y (<ft-trait> <ft-trait> uint uint (optional uint)) (response (tuple (dx uint) (dy uint)) uint))

        (swap-y-for-x (<ft-trait> <ft-trait> uint uint (optional uint)) (response (tuple (dx uint) (dy uint)) uint))
    )
)