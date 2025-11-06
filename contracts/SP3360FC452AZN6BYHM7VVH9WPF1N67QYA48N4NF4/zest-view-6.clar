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
    (debt (get-user-borrow-balance-safe (get user ctx) asset))
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

(define-read-only (get-user-borrow-balance-safe (user principal) (reserve principal))
  (match (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-user-reserve-data-read user reserve)
    user-data
      (match (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read reserve)
        reserve-data
          (if (is-eq (get principal-borrow-balance user-data) u0)
            { principal-balance: u0, compounded-balance: u0, balance-increase: u0 }
            (let (
              (principal (get principal-borrow-balance user-data))
              (compounded-balance 
                (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-compounded-borrow-balance
                  (get principal-borrow-balance user-data)
                  (get decimals reserve-data)
                  (get stable-borrow-rate user-data)
                  (get last-updated-block user-data)
                  (get last-variable-borrow-cumulative-index user-data)
                  (get current-variable-borrow-rate reserve-data)
                  (get last-variable-borrow-cumulative-index reserve-data)
                  (get last-updated-block reserve-data)
                )
              )
            )
              { 
                principal-balance: principal,
                compounded-balance: compounded-balance,
                balance-increase: (- compounded-balance principal)
              }
            )
          )
        { principal-balance: u0, compounded-balance: u0, balance-increase: u0 }
      )
    { principal-balance: u0, compounded-balance: u0, balance-increase: u0 }
  )
)