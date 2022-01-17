(define-public (claim-and-transfer (targetCycle uint) (dest principal))
  (begin
    (if (is-ok (print (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-core-v1 claim-stacking-reward targetCycle)))
      (print "ok 1")
      (print "error 1")
    )
    (if (is-ok (print (stx-transfer? (print (stx-get-balance tx-sender)) tx-sender dest)))
      (print "ok 2")
      (print "error 2")
    )
    (if (is-ok (print
      (contract-call?
        'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token
        transfer
        (unwrap! (print (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token get-balance tx-sender)) (err u10))
        tx-sender
        dest
        none
      )
    ))
      (print "ok 3")
      (print "error 3")
    )
    (ok true)
  )
)
