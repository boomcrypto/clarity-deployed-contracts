(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (begin
    (print {action: "list-in-ustx", id: id})
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (print {action: "unlist-in-ustx", id: id})
    (ok true)
  )
)

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (begin 
    (try! (as-contract (stx-transfer? u10000000 tx-sender 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A)))
    (print {action: "buy-in-ustx", id: id})
    (ok true)
  )
)