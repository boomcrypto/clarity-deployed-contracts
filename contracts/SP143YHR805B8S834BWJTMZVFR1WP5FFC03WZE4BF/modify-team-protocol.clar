(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.royal-chocolate-gorilla set-signals-required u2))
    (print {event: "execute", sender: sender})
    (ok true)
  )
)