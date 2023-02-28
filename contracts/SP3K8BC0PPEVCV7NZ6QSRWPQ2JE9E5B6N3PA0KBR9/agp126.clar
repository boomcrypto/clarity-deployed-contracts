(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant amount u147054)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .token-wdiko transfer-fixed (* amount ONE_8) tx-sender 'SPSHEY24MHYHTNNZDSFV1YX18M8VH7GZSD5NS60G none))
        (ok true)
    )
)