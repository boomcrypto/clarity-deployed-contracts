;; mint up to 20 punks
(define-public (bulk-mint (punk-ids (list 20 uint)))
  (let (
    (result (fold mint punk-ids { count: u0 }))
  )
    (ok result)
  )
)

(define-private (mint (punk-id uint) (data (tuple (count uint))))
  (begin
    (asserts!
      (is-ok (contract-call? .stacks-punks-v3 mint punk-id))
      { count: (get count data) }
    )
    { count: (+ u1 (get count data)) }
  )
)
