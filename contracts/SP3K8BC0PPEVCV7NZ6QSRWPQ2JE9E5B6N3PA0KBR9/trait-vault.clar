(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait flash-loan-user-trait .trait-flash-loan-user.flash-loan-user-trait)

(define-trait vault-trait
    (   
        ;; returns the balance of token
        (get-balance (<ft-trait>) (response uint uint))

        ;; flash loan currently supports single token loan
        (flash-loan (<flash-loan-user-trait> <ft-trait> uint (optional (buff 16))) (response uint uint))
    )
)
