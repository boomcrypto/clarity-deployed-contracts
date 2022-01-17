(define-public (bulk-remove-bid (ids (list 100 (tuple (collection-id uint) (item-id uint)))))
  (begin
    (map admin-remove-bid ids)
    (ok true)
  )
)

(define-public (admin-remove-bid (bid (tuple (collection-id uint) (item-id uint))))
  (begin
    (try! (contract-call? .stacks-art-market-v2 admin-remove-bid (get collection-id bid) (get item-id bid)))
    (ok true)
  )
)
