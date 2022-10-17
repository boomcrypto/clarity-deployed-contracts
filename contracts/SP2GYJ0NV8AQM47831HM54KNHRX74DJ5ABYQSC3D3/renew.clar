(define-trait renew-trait
  (
    (renew (uint bool) (response bool int))
  )
)

(define-public (renew_one (fee uint) (bfee bool) (c <renew-trait>))
  (begin
    (contract-call? c renew fee bfee)
  )
)

(define-public (renew_five (fee uint) (bfee bool) (c1 <renew-trait>) (c2 <renew-trait>) (c3 <renew-trait>) (c4 <renew-trait>) (c5 <renew-trait>))
  (begin
    (try! (contract-call? c1 renew fee bfee))
    (try! (contract-call? c2 renew fee bfee))
    (try! (contract-call? c3 renew fee bfee))
    (try! (contract-call? c4 renew fee bfee))
    (try! (contract-call? c5 renew fee bfee))
    (ok true)
  )
)

(define-public (renew_ten (fee uint) (bfee bool) (c1 <renew-trait>) (c2 <renew-trait>) (c3 <renew-trait>) (c4 <renew-trait>) (c5 <renew-trait>) (c6 <renew-trait>) (c7 <renew-trait>) (c8 <renew-trait>) (c9 <renew-trait>) (c10 <renew-trait>))
  (begin
    (try! (contract-call? c1 renew fee bfee))
    (try! (contract-call? c2 renew fee bfee))
    (try! (contract-call? c3 renew fee bfee))
    (try! (contract-call? c4 renew fee bfee))
    (try! (contract-call? c5 renew fee bfee))
    (try! (contract-call? c6 renew fee bfee))
    (try! (contract-call? c7 renew fee bfee))
    (try! (contract-call? c8 renew fee bfee))
    (try! (contract-call? c9 renew fee bfee))
    (try! (contract-call? c10 renew fee bfee))
    (ok true)
  )
)