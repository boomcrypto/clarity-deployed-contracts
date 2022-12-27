
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    
    (try! (contract-call? 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68.religious-jade-catfish withdraw-stx u1000000 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68))
    (print {event: "execute", sender: sender})
    (ok true)
  )
)
