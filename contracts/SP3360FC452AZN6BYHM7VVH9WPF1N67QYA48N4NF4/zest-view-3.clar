(define-read-only (get-user-borrow-positions (user principal))
  (let (
    (assets-data (get-user-assets user))
    (assets-borrowed (get assets-borrowed (default-to { assets-supplied: (list), assets-borrowed: (list) } assets-data)))
  )
    (ok (fold acc-borrow assets-borrowed { user: user, res: (list) }))
  )
)

(define-private (acc-borrow
  (asset principal)
  (ctx { user: principal, res: (list 100 { asset: principal, principal-balance: uint, compounded-balance: uint, balance-increase: uint }) }))
  (let (
    (debt (get-user-borrow-balance (get user ctx) asset))
  )
    { user: (get user ctx),
      res: (unwrap-panic (as-max-len?
              (append (get res ctx) (merge { asset: asset } debt))
              u100)) }
  )
)

(define-read-only (get-user-assets (user principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-user-assets-read user)
)

(define-read-only (get-user-borrow-balance (user principal) (reserve principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-read get-user-borrow-balance user reserve)
)