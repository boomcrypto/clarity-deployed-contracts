(define-public (bulk-unlist (ids (list 200 uint)))
  (begin
    (map admin-unlist ids)
    (ok true)
  )
)

(define-public (admin-unlist (id uint))
  (begin
    (try!
      (contract-call? .stacks-art-market admin-unlist 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops u2 id)
    )
    (ok true)
  )
)
