(define-public (claim-and-transfer (targetCycle uint) (dest principal))
  (begin
    (if (is-ok (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-core-v1 claim-stacking-reward targetCycle))  ;; check error, or ignore
      (print "success")
      (print "error")
    )
    (stx-transfer? (stx-get-balance tx-sender) tx-sender dest)
  )
)