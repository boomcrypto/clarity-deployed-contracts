
;; Type: Social
;; Author: SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68
;; Title: SDP-001
;; Description: Testing

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
