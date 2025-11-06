
  (define-public (multi-send (recipients (list 200 {to: principal, amount: uint})))
    (begin
        (map send-stx recipients)
        (ok true)
    )
  )

  (define-private (send-stx (entry {to: principal, amount: uint}))
      (stx-transfer? (get amount entry) tx-sender (get to entry))
  )