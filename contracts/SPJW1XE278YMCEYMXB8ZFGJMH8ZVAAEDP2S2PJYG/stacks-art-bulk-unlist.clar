(define-public (bulk-unlist (ids (list 200 uint)))
  (begin
    (map admin-unlist ids)
    (ok true)
  )
)

(define-public (admin-unlist (id uint))
  (begin
    (try!
      (contract-call? .stacks-art-open-market admin-unlist 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft id)
    )
    (ok true)
  )
)
