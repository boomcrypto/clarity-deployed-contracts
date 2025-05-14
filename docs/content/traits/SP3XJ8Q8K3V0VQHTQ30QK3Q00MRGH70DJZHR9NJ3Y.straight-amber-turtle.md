---
title: "Trait straight-amber-turtle"
draft: true
---
```
(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemeable-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)

(define-constant one-8 u100000000)
(define-constant max-value u340282366920938463463374607431768211455)
(define-constant e-mode-disabled-type 0x00)

(define-constant default-user-reserve-data
  {
    principal-borrow-balance: u0,
    last-variable-borrow-cumulative-index: u0,
    origination-fee: u0,
    stable-borrow-rate: u0,
    last-updated-block: u0,
    use-as-collateral: false,
  }
)

;; ERROR START 7000
(define-constant ERR_UNAUTHORIZED (err u7000))
(define-constant ERR_INVALID_Z_TOKEN (err u7001))
(define-constant ERR_INVALID_ORACLE (err u7002))
(define-constant ERR_NON_CORRESPONDING_ASSETS (err u7003))
(define-constant ERR_DOES_NOT_EXIST (err u7004))
(define-constant ERR_NON_ZERO (err u7005))
(define-constant ERR_OPTIMAL_UTILIZATION_RATE_NOT_SET (err u7006))
(define-constant ERR_BASE_VARIABLE_BORROW_RATE_NOT_SET (err u7007))
(define-constant ERR_VARIABLE_RATE_SLOPE_1_NOT_SET (err u7008))
(define-constant ERR_VARIABLE_RATE_SLOPE_2_NOT_SET (err u7009))
(define-constant ERR_HEALTH_FACTOR_LIQUIDATION_THRESHOLD (err u7010))
(define-constant ERR_FLASHLOAN_FEE_TOTAL_NOT_SET (err u7011))
(define-constant ERR_FLASHLOAN_FEE_PROTOCOL_NOT_SET (err u7012))
(define-constant ERR_INVALID_VALUE (err u7013))
(define-constant ERR_E_MODE_DOES_NOT_EXIST (err u7014))
(define-constant ERR_CANNOT_BORROW_DIFFERENT_E_MODE_TYPE (err u7015))

(define-public (get-user-asset-data
  (lp-token <ft>)
  (asset <ft>)
  (oracle <oracle-trait>)
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
    (reserve-data (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state (contract-of asset))))
    (is-lp-ok (asserts! (is-eq (get a-token-address reserve-data) (contract-of lp-token)) ERR_INVALID_Z_TOKEN))
    (is-oracle-ok (asserts! (is-eq (get oracle reserve-data) (contract-of oracle)) ERR_INVALID_ORACLE))
    (user-reserve-state (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-balance-reserve-data lp-token asset user oracle)))
    (reserve-unit-price (try! (contract-call? oracle get-asset-price asset)))
    (e-mode-config (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-e-mode-config user (contract-of asset))))
    ;; liquidity and collateral balance
    (liquidity-balanceUSD (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 mul-to-fixed-precision (get underlying-balance user-reserve-state) (get decimals reserve-data) reserve-unit-price))
    (supply-state
      (if (> (get underlying-balance user-reserve-state) u0)
        (if (and (get usage-as-collateral-enabled reserve-data) (get use-as-collateral user-reserve-state))
          {
            total-liquidity-balanceUSD: (+ (get total-liquidity-balanceUSD aggregate) liquidity-balanceUSD),
            total-collateral-balanceUSD: (+ (get total-collateral-balanceUSD aggregate) liquidity-balanceUSD),
            current-ltv: (+ (get current-ltv aggregate) (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 mul liquidity-balanceUSD (get ltv e-mode-config))),
            current-liquidation-threshold: (+ (get current-liquidation-threshold aggregate) (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 mul liquidity-balanceUSD (get liquidation-threshold e-mode-config)))
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
              (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 mul-to-fixed-precision (get compounded-borrow-balance user-reserve-state) (get decimals reserve-data) reserve-unit-price)
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
```
