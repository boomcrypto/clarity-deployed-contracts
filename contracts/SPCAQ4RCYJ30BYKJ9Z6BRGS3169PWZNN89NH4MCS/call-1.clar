(define-trait trait ((claim () (response uint uint))))

(define-constant OWNER tx-sender)
(define-public (call (ref <trait>) (buff (buff 100)))
     (ok (fold proxy buff ref))
)

(define-private (proxy (in (buff 1)) (ref <trait>))
     (match (contract-call? ref claim) x ref y ref)
)