
;; Type: Social
;; Author: SPR7GA14THRPZZDRSWBYAY5QBMVED8VKQYAS3SS3
;; Title: MDP-006
;; Description: I propose that the DAO is closed and we return to the glory days of the Cult of Mrk. 

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
