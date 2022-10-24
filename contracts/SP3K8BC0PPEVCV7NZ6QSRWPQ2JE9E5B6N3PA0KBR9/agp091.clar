(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
    (let 
        (
            (apower-bal (unwrap-panic (contract-call? .token-apower get-balance-fixed tx-sender)))
        )
	    (try! (contract-call? .executor-dao set-extension .age009-token-lock true))
        (try! (contract-call? .token-apower mint-fixed apower-bal 'SPSHEY24MHYHTNNZDSFV1YX18M8VH7GZSD5NS60G))
        (try! (contract-call? .token-apower burn-fixed apower-bal tx-sender))
        
        (ok true)
    )
)