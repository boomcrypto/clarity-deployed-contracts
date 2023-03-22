(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant amount u3000000)
(define-constant fwp-usda-coinbase-1 (* u2000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-usda-coinbase-2 (* u1000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-usda-coinbase-3 (* u500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-usda-coinbase-4 (* u250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-usda-coinbase-5 (* u125 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-public (execute (sender principal))
    (begin  
        (try! (contract-call? .age000-governance-token mint-fixed (* amount ONE_8) 'SP22PCWZ9EJMHV4PHVS0C8H3B3E4Q079ZHY6CXDS1))
        (try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-alex-usda fwp-usda-coinbase-1 fwp-usda-coinbase-2 fwp-usda-coinbase-3 fwp-usda-coinbase-4 fwp-usda-coinbase-5))
        
        (ok true)
    )
)