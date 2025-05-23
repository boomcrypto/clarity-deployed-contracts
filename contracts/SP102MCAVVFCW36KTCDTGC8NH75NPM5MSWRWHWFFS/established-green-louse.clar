(use-trait oracle-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)

(define-private (calculate-user-global-data
  (user principal)
  (assets-to-calculate (list 100 {
        asset: <ft>, lp-token: <ft>, oracle: <oracle-trait>, last-price: uint
        })))
  (begin
    (let (
      (aggregate (try!
          (fold
            aggregate-user-data
            assets-to-calculate
            (ok
              {
                total-liquidity-balanceUSD: u0,
                total-collateral-balanceUSD: u0,
                total-borrow-balanceUSD: u0,
                user-total-feesUSD: u0,
                current-ltv: u0,
                current-liquidation-threshold: u0,
                user: user
              }))))
      (total-collateral-balanceUSD (get total-collateral-balanceUSD aggregate))
      (current-ltv
        (if (> total-collateral-balanceUSD u0)
          (div (get current-ltv aggregate) total-collateral-balanceUSD)
          u0))
      (current-liquidation-threshold
        (if (> total-collateral-balanceUSD u0)
          (div (get current-liquidation-threshold aggregate) total-collateral-balanceUSD)
          u0))
      (health-factor
        (calculate-health-factor-from-balances
          (get total-collateral-balanceUSD aggregate)
          (get total-borrow-balanceUSD aggregate)
          (get user-total-feesUSD aggregate)
          current-liquidation-threshold))
      (is-health-factor-below-treshold (< health-factor (get-health-factor-liquidation-threshold))))
      (ok {
        total-liquidity-balanceUSD: (get total-liquidity-balanceUSD aggregate),
        total-collateral-balanceUSD: total-collateral-balanceUSD,
        total-borrow-balanceUSD: (get total-borrow-balanceUSD aggregate),
        user-total-feesUSD: (get user-total-feesUSD aggregate),
        current-ltv: current-ltv,
        current-liquidation-threshold: current-liquidation-threshold,
        health-factor: health-factor,
        is-health-factor-below-treshold: is-health-factor-below-treshold
      })
    )
  )
)

(define-private (aggregate-user-data
  (reserve { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait>, last-price: uint })
  (total
    (response
      (tuple
        (total-liquidity-balanceUSD uint)
        (total-collateral-balanceUSD uint)
        (total-borrow-balanceUSD uint)
        (user-total-feesUSD uint)
        (user principal)
        (current-ltv uint)
        (current-liquidation-threshold uint)
      )
      uint
    )))
  (let (
    (result (try! total)))
    (get-user-basic-reserve-data
      (get lp-token reserve)
      (get asset reserve)
      (get oracle reserve)
      (get last-price reserve)
      result )))

(define-private (get-user-basic-reserve-data
  (lp-token <ft>)
  (asset <ft>)
  (oracle <oracle-trait>)
  (last-price uint)
  (aggregate {
    total-liquidity-balanceUSD: uint,
    total-collateral-balanceUSD: uint,
    total-borrow-balanceUSD: uint,
    user-total-feesUSD: uint,
    current-ltv: uint,
    current-liquidation-threshold: uint,
    user: principal
  })
  )
  (let (
    (user (get user aggregate))
    (user-reserve-state (get-user-reserve-data user (contract-of asset)))
    (reserve-data (get-reserve-state (contract-of asset)))
    (default-reserve-value
      {
        total-liquidity-balanceUSD: (get total-liquidity-balanceUSD aggregate),
        total-collateral-balanceUSD: (get total-collateral-balanceUSD aggregate),
        total-borrow-balanceUSD: (get total-borrow-balanceUSD aggregate),
        user-total-feesUSD: (get user-total-feesUSD aggregate),
        current-ltv: (get current-ltv aggregate),
        current-liquidation-threshold: (get current-liquidation-threshold aggregate),
        user: user
      }
    )
  )
    (if (or (> (get principal-borrow-balance user-reserve-state) u0) (get use-as-collateral user-reserve-state))
      ;; if borrowing or using as collateral
      (get-user-asset-data lp-token asset oracle last-price aggregate)
      ;; add nothing
      (ok default-reserve-value)
    )
  )
)

(define-private (get-user-asset-data
  (lp-token <ft>)
  (asset <ft>)
  (oracle <oracle-trait>)
  (last-price uint)
  (aggregate {
    total-liquidity-balanceUSD: uint,
    total-collateral-balanceUSD: uint,
    total-borrow-balanceUSD: uint,
    user-total-feesUSD: uint,
    current-ltv: uint,
    current-liquidation-threshold: uint,
    user: principal
  })
  )
  (let (
    (user (get user aggregate))
    (reserve-data (get-reserve-state (contract-of asset)))
    (user-reserve-state (try! (get-user-balance-reserve-data lp-token asset user oracle)))
    ;; TODO: GET THE PRICE FROM THE ARGS
    (reserve-unit-price (try! (contract-call? oracle get-asset-price asset)))
    ;; liquidity and collateral balance
    (liquidity-balanceUSD (mul-to-fixed-precision (get underlying-balance user-reserve-state) (get decimals reserve-data) reserve-unit-price))
    (supply-state
      (if (> (get underlying-balance user-reserve-state) u0)
        (if (and (get usage-as-collateral-enabled reserve-data) (get use-as-collateral user-reserve-state))
          {
            total-liquidity-balanceUSD: (+ (get total-liquidity-balanceUSD aggregate) liquidity-balanceUSD),
            total-collateral-balanceUSD: (+ (get total-collateral-balanceUSD aggregate) liquidity-balanceUSD),
            current-ltv: (+ (get current-ltv aggregate) (mul liquidity-balanceUSD (get base-ltv-as-collateral reserve-data))),
            current-liquidation-threshold: (+ (get current-liquidation-threshold aggregate) (mul liquidity-balanceUSD (get liquidation-threshold reserve-data)))
          }
          {
            total-liquidity-balanceUSD: (get total-liquidity-balanceUSD aggregate),
            total-collateral-balanceUSD: (get total-collateral-balanceUSD aggregate),
            current-ltv: (get current-ltv aggregate),
            current-liquidation-threshold: (get current-liquidation-threshold aggregate)
          }
        )
        {
          total-liquidity-balanceUSD: (get total-liquidity-balanceUSD aggregate),
          total-collateral-balanceUSD: (get total-collateral-balanceUSD aggregate),
          current-ltv: (get current-ltv aggregate),
          current-liquidation-threshold: (get current-liquidation-threshold aggregate)
        }
      )
    )
    (borrow-state
      (if (> (get compounded-borrow-balance user-reserve-state) u0)
        {
          total-borrow-balanceUSD:
            (+ 
              (get total-borrow-balanceUSD aggregate)
              (mul-to-fixed-precision (get compounded-borrow-balance user-reserve-state) (get decimals reserve-data) reserve-unit-price)
            ),
          user-total-feesUSD: u0
        }
        {
          total-borrow-balanceUSD: (get total-borrow-balanceUSD aggregate),
          user-total-feesUSD: (get user-total-feesUSD aggregate)
        }
      )
    )
  )
    (ok
      (merge
        (merge
          supply-state
          borrow-state
        )
        { user: user }
      )
    )
  )
)

(define-private (get-user-balance-reserve-data
  (lp-token <ft>)
  (asset <ft>)
  (user principal)
  (oracle <oracle-trait>)
  )
  (let (
    (user-data (get-user-reserve-data user (contract-of asset)))
    (reserve-data (get-reserve-state (contract-of asset)))
    (underlying-balance (try! (get-user-underlying-asset-balance lp-token asset user)))
    (compounded-borrow-balance
      (get-compounded-borrow-balance
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
    (if (is-eq (get principal-borrow-balance user-data) u0)
      (ok {
        underlying-balance: underlying-balance,
        compounded-borrow-balance: u0,
        origination-fee: u0,
        use-as-collateral: (get use-as-collateral user-data)
      })
      (ok {
        underlying-balance: underlying-balance,
        compounded-borrow-balance: compounded-borrow-balance,
        origination-fee: u0,
        use-as-collateral: (get use-as-collateral user-data)
      })
    )
  )
)

(define-private (get-user-underlying-asset-balance
  (lp-token <ft>)
  (asset <ft>)
  (user principal)
  )
  (let (
    (user-data (get-user-reserve-data user (contract-of asset)))
    (reserve-data (get-reserve-state (contract-of asset)))
    (underlying-balance (try! (contract-call? lp-token get-balance user))))
    (ok underlying-balance)))

(define-read-only (get-health-factor-liquidation-threshold)
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-health-factor-liquidation-threshold-read))

(define-read-only (calculate-health-factor-from-balances
  (total-collateral-balanceUSD uint)
  (total-borrow-balanceUSD uint)
  (total-feesUSD uint)
  (current-liquidation-threshold uint))
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 calculate-health-factor-from-balances
        total-collateral-balanceUSD
        total-borrow-balanceUSD
        total-feesUSD
        current-liquidation-threshold
    )
)

(define-read-only (get-compounded-borrow-balance
    ;; user-data
    (principal-borrow-balance uint)
    (decimals uint)
    (stable-borrow-rate uint)
    (last-updated-block uint)
    (last-variable-borrow-cumulative-index uint)
    ;; reserve-data
    (current-variable-borrow-rate uint)
    (last-variable-borrow-cumulative-index-reserve uint)
    (last-updated-block-reserve uint)
  )
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-compounded-borrow-balance
    principal-borrow-balance
    decimals
    stable-borrow-rate
    last-updated-block
    last-variable-borrow-cumulative-index
    current-variable-borrow-rate
    last-variable-borrow-cumulative-index-reserve last-updated-block-reserve))


(define-read-only (mul (x uint) (y uint))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.math-v2-0 mul x y))

(define-read-only (div (x uint) (y uint))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.math-v2-0 div x y))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.math-v2-0 mul-to-fixed-precision a decimals-a b-fixed))

(define-read-only (get-user-reserve-data (who principal) (reserve principal))
  (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-user-reserve-data-read who reserve)))

(define-read-only (get-reserve-state (asset principal))
  (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read asset)))
