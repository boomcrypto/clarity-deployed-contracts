(use-trait executor-trait .traits.executor-trait)

(define-public (execute-multi
    (s1 <executor-trait>) 
    (in1 uint)
    (mout1 uint)
    (s2 <executor-trait>) 
    (in2 uint)
    (mout2 uint)
)
 (ok (list 
        (unwrap-panic (contract-call? s1 execute in1 mout1))
        (unwrap-panic (contract-call? s2 execute in2 mout2))
    ))
)