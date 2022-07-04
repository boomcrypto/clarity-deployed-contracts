(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait loan-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-flash-loan-user.flash-loan-user-trait)
(use-trait vault-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-vault.vault-trait)

(define-public (hic (vault <vault-trait>) (loan1 <loan-trait>) (ft1 <ft-trait>) (amount1 uint) (loan2 <loan-trait>) (ft2 <ft-trait>) (amount2 uint))
    (ok (list 
        (contract-call? vault flash-loan loan1 ft1 amount1 none)
        (contract-call? vault flash-loan loan2 ft2 amount2 none)
    ))
)