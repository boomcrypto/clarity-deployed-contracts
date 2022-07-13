;; Type: Social
;; Author: SPV0WDJQHWJVR2XD59H5NGX9AMNNTP4Q92XV77JD
;; Title: MDP-005
;; Description: If MDP-001 is Approved, this proposal nominates JAKE.STX(SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A) as new CEO.


(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-constant ERR_RIP_JAKE (err u42069))

(define-public (execute (sender principal))
  (if 
  (is-some (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-dao executed-at 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A.MDP-001))
  (begin
    (print {event: "execute", sender: sender})
    (ok true)
  )
  (begin
    (print "Poor Jakey :(. Maybe you should buy 69 CrashPunks off the floor LMAO")
    (err u42069)
  )))