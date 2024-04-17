

(define-public (run-update
  (asset principal)
  (last-liquidity-cumulative-index (optional uint))
  (current-liquidity-rate (optional uint))
  (total-borrows-stable (optional uint))
  (total-borrows-variable (optional uint))
  (current-variable-borrow-rate (optional uint))
  (current-stable-borrow-rate (optional uint))
  (current-average-stable-borrow-rate (optional uint))
  (last-variable-borrow-cumulative-index (optional uint))
  (base-ltv-as-collateral (optional uint))
  (liquidation-threshold (optional uint))
  (liquidation-bonus (optional uint))
  (decimals (optional uint))
  (a-token-address (optional principal))
  (oracle (optional principal))
  (interest-rate-strategy-address (optional principal))
  (flashloan-enabled (optional bool))
  (last-updated-block (optional uint))
  (borrowing-enabled (optional bool))
  (usage-as-collateral-enabled (optional bool))
  (is-stable-borrow-rate-enabled (optional bool))
  (supply-cap (optional uint))
  (borrow-cap (optional uint))
  (debt-ceiling (optional uint))
  (accrued-to-treasury (optional uint))
  (is-active (optional bool))
  (is-frozen (optional bool))
  )
  (let (
    (reserve-data (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read asset)))
  )
    (print reserve-data)
    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow
        set-reserve
        asset
        (merge reserve-data
          {
            last-liquidity-cumulative-index: (default-to (get last-liquidity-cumulative-index reserve-data) last-liquidity-cumulative-index),
            current-liquidity-rate: (default-to (get current-liquidity-rate reserve-data) current-liquidity-rate),
            total-borrows-stable: (default-to (get total-borrows-stable reserve-data) total-borrows-stable),
            total-borrows-variable: (default-to (get total-borrows-variable reserve-data) total-borrows-variable),
            current-variable-borrow-rate: (default-to (get current-variable-borrow-rate reserve-data) current-variable-borrow-rate),
            current-stable-borrow-rate: (default-to (get current-stable-borrow-rate reserve-data) current-stable-borrow-rate),
            current-average-stable-borrow-rate: (default-to (get current-average-stable-borrow-rate reserve-data) current-average-stable-borrow-rate),
            last-variable-borrow-cumulative-index: (default-to (get last-variable-borrow-cumulative-index reserve-data) last-variable-borrow-cumulative-index),
            base-ltv-as-collateral: (default-to (get base-ltv-as-collateral reserve-data) base-ltv-as-collateral),
            liquidation-threshold: (default-to (get liquidation-threshold reserve-data) liquidation-threshold),
            liquidation-bonus: (default-to (get liquidation-bonus reserve-data) liquidation-bonus),
            decimals: (default-to (get decimals reserve-data) decimals),
            a-token-address: (default-to (get a-token-address reserve-data) a-token-address),
            oracle: (default-to (get oracle reserve-data) oracle),
            interest-rate-strategy-address: (default-to (get interest-rate-strategy-address reserve-data) interest-rate-strategy-address),
            flashloan-enabled: (default-to (get flashloan-enabled reserve-data) flashloan-enabled),
            last-updated-block: (default-to (get last-updated-block reserve-data) last-updated-block),
            borrowing-enabled: (default-to (get borrowing-enabled reserve-data) borrowing-enabled),
            supply-cap: (default-to (get supply-cap reserve-data) supply-cap),
            borrow-cap: (default-to (get borrow-cap reserve-data) borrow-cap),
            debt-ceiling: (default-to (get debt-ceiling reserve-data) debt-ceiling),
            accrued-to-treasury: (default-to (get accrued-to-treasury reserve-data) accrued-to-treasury),
            usage-as-collateral-enabled: (default-to (get usage-as-collateral-enabled reserve-data) usage-as-collateral-enabled),
            is-stable-borrow-rate-enabled: (default-to (get is-stable-borrow-rate-enabled reserve-data) is-stable-borrow-rate-enabled),
            is-active: (default-to (get is-active reserve-data) is-active),
            is-frozen: (default-to (get is-frozen reserve-data) is-frozen)
          }
        )
      )
    )
    (ok true)
  )
)