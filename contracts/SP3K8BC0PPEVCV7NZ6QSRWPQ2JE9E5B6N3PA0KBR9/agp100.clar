(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant END_CYCLE u108)
(define-constant CURRENT_CYCLE u74)
(define-constant TOKEN_LIST 
    (list 
        .age000-governance-token
        .fwp-wstx-alex-50-50-v1-01
        .fwp-wstx-wbtc-50-50-v1-01
        .fwp-wstx-wxusd-50-50-v1-01
        .fwp-alex-usda
        .fwp-alex-wban
    )
)
(define-constant extra-rewards u15298921106538)
(define-public (execute (sender principal))
    (begin  
        (try! (contract-call? .age000-governance-token mint-fixed extra-rewards 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66))
        (try! (contract-call? .auto-alex set-end-cycle END_CYCLE))
        (try! (contract-call? .alex-reserve-pool set-token-halving-cycle END_CYCLE))
        (try! (fold set-coinbase-iter TOKEN_LIST (ok true)))
        (ok true)
    )
)
(define-private (set-coinbase-iter (token principal) (previous-response (response bool uint)))
    (match previous-response 
        prev-ok 
        (contract-call? .alex-reserve-pool set-coinbase-amount token (contract-call? .alex-reserve-pool get-coinbase-amount-or-default token CURRENT_CYCLE) u0 u0 u0 u0)
        prev-err
        previous-response
    )
)