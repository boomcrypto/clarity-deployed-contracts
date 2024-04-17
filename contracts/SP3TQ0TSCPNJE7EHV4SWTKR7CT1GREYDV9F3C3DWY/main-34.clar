(use-trait executor-trait 'SP10JN8QXCYEXMPN9S13MGAXKADEJ3MD4P6FP7J60.traits.executor-trait)

(define-public (execute-multi
    (s1 <executor-trait>) 
    (in1 uint)
    (mout1 uint)
    (s2 <executor-trait>) 
    (in2 uint)
    (mout2 uint)
    (s3 <executor-trait>) 
    (in3 uint)
    (mout3 uint)
)
 (ok (list 
       (contract-call? s1 execute in1 mout1)
       (contract-call? s2 execute in2 mout2)
       (contract-call? s3 execute in3 mout3)
    ))
)