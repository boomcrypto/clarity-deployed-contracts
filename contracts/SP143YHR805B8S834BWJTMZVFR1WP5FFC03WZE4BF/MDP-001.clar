
;; Type: Social
;; Author: SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF
;; Title: MDP-001
;; Description: I got 99 problems, but a DAO aint one

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
