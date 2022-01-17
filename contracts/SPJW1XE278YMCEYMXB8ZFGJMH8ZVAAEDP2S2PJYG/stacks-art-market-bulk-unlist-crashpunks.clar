(define-public (bulk-unlist (ids (list 200 uint)))
  (begin
    (map admin-unlist ids)
    (ok true)
  )
)

(define-public (admin-unlist (id uint))
  (begin
    (try!
      (contract-call? .stacks-art-market-v2 admin-unlist 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v1 u28 id)
    )
    (ok true)
  )
)
