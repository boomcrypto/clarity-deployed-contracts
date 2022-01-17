(define-public (burn-bulk (ids (list 200 uint)))
  (begin
    (map burn-skater ids)
    (ok true)
  )
)

(define-public (burn-skater (id uint))
  (contract-call? .stacks-skaters burn id)
)
