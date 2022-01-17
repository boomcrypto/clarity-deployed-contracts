;; transfer up to 10 punks you own to a specified address
(define-public (bulk-transfer (punk-ids (list 10 uint)) (address principal))
  (let (
    (result (fold transfer punk-ids { address: address, count: u0 }))
  )
    (ok result)
  )
)

(define-private (transfer (punk-id uint) (data (tuple (address principal) (count uint))))
  (begin
    (asserts!
      (is-ok (contract-call? .stacks-punks-v3 transfer punk-id tx-sender (get address data)))
      { address: (get address data), count: (get count data) }
    )
    { address: (get address data), count: (+ u1 (get count data)) }
  )
)
