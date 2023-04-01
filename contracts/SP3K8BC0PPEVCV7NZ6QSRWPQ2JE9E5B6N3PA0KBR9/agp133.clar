(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant fwp-alex-dual-multiplier-in-fixed u265000000) ;; 5300 / 2000
(define-public (execute (sender principal))
    (begin  
        (try! (contract-call? .dual-farming-pool set-multiplier-in-fixed .fwp-alex-usda fwp-alex-dual-multiplier-in-fixed))
        
        (ok true)
    )
)