(define-public (burn-bulk (ids (list 200 uint)))
  (begin
    (map burn-panda ids)
    (ok true)
  )
)

(define-public (burn-panda (id uint))
  (contract-call? .stacks-giantpandas burn id)
)
