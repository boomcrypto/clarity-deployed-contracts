(define-read-only (get-user-borrow-positions (user principal))
  (let (
    (assets-data (get-user-assets user))
    (assets-borrowed (get assets-borrowed (default-to { assets-supplied: (list), assets-borrowed: (list) } assets-data)))
  )
    (ok (fold acc-borrow assets-borrowed { user: user, res: (list) }))
  )
)

(define-read-only (get-user-supply-positions (user principal))
  (let (
    (assets-data (get-user-assets user))
    (assets-supplied (get assets-supplied (default-to { assets-supplied: (list), assets-borrowed: (list) } assets-data)))
  )
    (ok (fold acc-supply assets-supplied { user: user, res: (list) }))
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

(define-private (acc-supply
  (asset principal)
  (ctx { user: principal, res: (list 100 { asset: principal, a-token-address: principal, balance: uint, matched: bool }) }))
  (match (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read asset)
    reserve-data
      (let (
        (a-token-addr (get a-token-address reserve-data))
        (balance-result (get-a-token-balance a-token-addr (get user ctx)))
        (balance (match balance-result ok-val ok-val err-val u0))
        (matched (is-ok balance-result))
      )
        { user: (get user ctx),
          res: (unwrap-panic (as-max-len?
                  (append (get res ctx) { 
                    asset: asset, 
                    a-token-address: a-token-addr,
                    balance: balance,
                    matched: matched
                  })
                  u100)) }
      )
    ctx
  )
)

(define-read-only (get-a-token-balance (a-token-address principal) (user principal))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2_v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2_v2-0 get-balance user) (err u0)))
  (if (is-eq a-token-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0)
    (ok (unwrap! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0 get-balance user) (err u0)))
    (err u404) ;; Unknown token - caller should query a-token-address directly
  )))))))))))
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