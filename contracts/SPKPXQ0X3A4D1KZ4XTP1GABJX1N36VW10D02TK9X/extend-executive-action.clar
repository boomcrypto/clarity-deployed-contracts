(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    ;; Increase emergency proposal sunset to an additional ~12 months
    (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-proposals set-emergency-team-sunset-height (+ block-height u52560)))
    (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-emergency-execute set-executive-team-sunset-height (+ block-height u52560)))
    (ok true)
  )
)