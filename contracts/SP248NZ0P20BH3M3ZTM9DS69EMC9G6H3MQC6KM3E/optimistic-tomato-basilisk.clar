
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 true))

    
    
    (print {event: "execute", sender: sender})
    (ok true)
  )
)
