(use-trait executor-trait 'SP10JN8QXCYEXMPN9S13MGAXKADEJ3MD4P6FP7J60.traits.executor-trait)

(define-public (execute-multi
    (s1 <executor-trait>) 
    (in1 uint)
    (mout1 uint)
)
 (ok (list 
       (contract-call? s1 execute in1 mout1)
    ))
)