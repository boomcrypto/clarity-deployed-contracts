(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-constant one-8 (contract-call? .math get-one))
(define-constant max-value (contract-call? .math get-max-value))

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

(define-public (set-flashloan-fee-total (asset principal) (fee uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-flashloan-fee-total asset fee)))

(define-public (set-flashloan-fee-protocol (asset principal) (fee uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-flashloan-fee-protocol asset fee)))

(define-public (set-origination-fee-prc (asset principal) (fee uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-origination-fee-prc asset fee)))

(define-read-only (get-health-factor-liquidation-threshold)
  (contract-call? .pool-reserve-data get-health-factor-liquidation-threshold-read))

(define-public (set-health-factor-liquidation-treshold (hf uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-health-factor-liquidation-threshold hf)))

    

(define-read-only (get-seconds-in-block) (contract-call? .math get-seconds-in-block))
(define-read-only (get-seconds-in-year) (contract-call? .math get-seconds-in-year))
(define-read-only (mul (x uint) (y uint)) (contract-call? .math mul x y))
(define-read-only (div (x uint) (y uint)) (contract-call? .math div x y))
(define-read-only (is-odd (x uint)) (contract-call? .math is-odd x))
(define-read-only (is-even (x uint)) (contract-call? .math is-even x))
(define-read-only (taylor-6 (x uint)) (contract-call? .math taylor-6 x))
(define-read-only (get-sb-by-sy) (contract-call? .math get-sb-by-sy))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math mul-to-fixed-precision a decimals-a b-fixed))

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math div-to-fixed-precision a decimals-a b-fixed))

(define-public (set-user-reserve-data
  (user principal)
  (reserve principal)
  (data
    (tuple
    (principal-borrow-balance uint)
    (last-variable-borrow-cumulative-index uint)
    (origination-fee uint)
    (stable-borrow-rate uint)
    (last-updated-block uint)
    (use-as-collateral bool))))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-user-reserve-data user reserve data)))

(define-public (set-user-assets
  (user principal)
  (data
    (tuple
      (assets-supplied (list 100 principal))
      (assets-borrowed (list 100 principal)))))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-user-assets user data)))

(define-data-var configurator principal tx-sender)
(define-public (set-configurator (new-configurator principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set configurator new-configurator))))
(define-read-only (is-configurator (caller principal))
  (if (is-eq caller (var-get configurator)) true false))

(define-data-var lending-pool principal .pool-borrow)
(define-public (set-lending-pool (new-lending-pool principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set lending-pool new-lending-pool))))
(define-read-only (is-lending-pool (caller principal))
  (if (is-eq caller (var-get lending-pool)) true false))

(define-data-var liquidator principal .liquidation-manager)
(define-public (set-liquidator (new-liquidator principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set liquidator new-liquidator))))
(define-read-only (is-liquidator (caller principal))
  (if (is-eq caller (var-get liquidator)) true false))

(define-data-var admin principal tx-sender)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set admin new-admin))))
(define-read-only (is-admin (caller principal))
  (if (is-eq caller (var-get admin)) true false))

(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))))

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

(define-read-only (get-flashloan-fee-total (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-flashloan-fee-total-read asset) ERR_FLASHLOAN_FEE_TOTAL_NOT_SET)))

(define-read-only (get-flashloan-fee-protocol (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-flashloan-fee-protocol-read asset) ERR_FLASHLOAN_FEE_PROTOCOL_NOT_SET)))

(define-read-only (get-origination-fee-prc (asset principal))
  (default-to u0 (contract-call? .pool-reserve-data get-origination-fee-prc-read asset)))

(define-read-only (get-user-reserve-data (who principal) (reserve principal))
  (default-to default-user-reserve-data (contract-call? .pool-reserve-data get-user-reserve-data-read who reserve))
)

(define-public (set-optimal-utilization-rate (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-optimal-utilization-rate asset rate)))

(define-public (set-base-variable-borrow-rate (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-base-variable-borrow-rate asset rate)))

(define-public (set-variable-rate-slope-1 (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-variable-rate-slope-1 asset rate)))

(define-public (set-variable-rate-slope-2 (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-variable-rate-slope-2 asset rate)))

(define-public (set-liquidation-close-factor-percent (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-liquidation-close-factor-percent asset rate)))

(define-read-only (get-optimal-utilization-rate (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-optimal-utilization-rate-read asset) ERR_OPTIMAL_UTILIZATION_RATE_NOT_SET)))
(define-read-only (get-base-variable-borrow-rate (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-base-variable-borrow-rate-read asset) ERR_BASE_VARIABLE_BORROW_RATE_NOT_SET)))
(define-read-only (get-variable-rate-slope-1 (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-variable-rate-slope-1-read asset) ERR_VARIABLE_RATE_SLOPE_1_NOT_SET)))
(define-read-only (get-variable-rate-slope-2 (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-variable-rate-slope-2-read asset) ERR_VARIABLE_RATE_SLOPE_2_NOT_SET)) )

(define-read-only (is-borroweable-isolated (asset principal))
  (match (index-of? (contract-call? .pool-reserve-data get-borroweable-isolated-read) asset)
    res true
    false))

(define-read-only (get-borroweable-isolated)
  (contract-call? .pool-reserve-data get-borroweable-isolated-read))

(define-read-only (is-isolated-type (asset principal))
  (default-to false (contract-call? .pool-reserve-data get-isolated-assets-read asset)))

(define-public (set-borroweable-isolated (new-assets (list 100 principal)))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-borroweable-isolated new-assets)))

(define-public (remove-isolated-asset (asset principal))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data delete-isolated-assets asset)))

(define-public (set-isolated-asset (asset principal))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-isolated-assets asset true)))

(define-read-only (is-borrowing-assets (user principal))
  (> (len (get assets-borrowed (get-user-assets user))) u0))

(define-read-only (is-in-isolation-mode (who principal))
  (let (
    (assets-supplied (get assets-supplied (get-user-assets who)))
    (split-assets (fold split-isolated assets-supplied { isolated: (list), non-isolated: (list) }))
    (enabled-isolated (fold count-collateral-enabled (get isolated split-assets) { who: who, enabled-count: u0, enabled-assets: (list) }))
    (enabled-isolated-n (get enabled-count enabled-isolated))
    (enabled-non-isolated-n  (get enabled-count (fold count-collateral-enabled (get non-isolated split-assets) { who: who, enabled-count: u0, enabled-assets: (list) })))
  )
    (if (is-eq enabled-non-isolated-n u0)
      (if (is-eq enabled-isolated-n u1)
        (element-at? (get enabled-assets enabled-isolated) u0)
        none
      )
      none
    )
  )
)

(define-read-only (get-assets-used-as-collateral (who principal))
  (let ((assets-supplied (get assets-supplied (get-user-assets who))))
    (fold count-collateral-enabled assets-supplied { who: who, enabled-count: u0, enabled-assets: (list) })
  )
)

;; only functions property if user is in isolated mode
(define-read-only (get-isolated-asset (who principal))
  (let (
    (assets-supplied (get assets-supplied (get-user-assets who)))
    (split-assets (fold split-isolated assets-supplied { isolated: (list), non-isolated: (list) }))
  )
    (unwrap-panic (element-at (get enabled-assets (fold count-collateral-enabled (get isolated split-assets) { who: who, enabled-count: u0, enabled-assets: (list) })) u0))
  )
)

;; util function
(define-read-only (split-isolated (asset principal) (ret { isolated: (list 100 principal), non-isolated: (list 100 principal) }))
  (if (is-isolated-type asset)
    {
      isolated: (unwrap-panic (as-max-len? (append (get isolated ret) asset) u100)) ,
      non-isolated: (get non-isolated ret)
    }
    {
      isolated: (get isolated ret),
      non-isolated: (unwrap-panic (as-max-len? (append (get non-isolated ret) asset) u100))
    }
  )
)

;; util function
(define-read-only (count-collateral-enabled (asset principal) (ret { who: principal, enabled-count: uint, enabled-assets: (list 100 principal) }))
  (if (get use-as-collateral (get-user-reserve-data (get who ret) asset))
    (merge ret {
        enabled-count: (+ (get enabled-count ret) u1),
        enabled-assets: (unwrap-panic (as-max-len? (append (get enabled-assets ret) asset) u100))
      })
    ret
  )
)

(define-public (add-supplied-asset-ztoken (who principal) (asset principal))
  (let ((reserve-data (try! (get-reserve-state asset))))
    (if (is-eq contract-caller (get a-token-address reserve-data))
      true
      (try! (is-approved-contract contract-caller)))
    (add-supplied-asset who asset)
  )
)

(define-private (add-supplied-asset (who principal) (asset principal))
  (let ((assets-data (get-user-assets who)))
    (if (is-none (index-of? (get assets-supplied assets-data) asset))
      (contract-call? .pool-reserve-data 
        set-user-assets
        who
        {
          assets-supplied: (unwrap-panic (as-max-len? (append (get assets-supplied assets-data) asset) u100)),
          assets-borrowed: (get assets-borrowed assets-data)
        })
      (ok true)
    )
  )
)

(define-public (remove-supplied-asset-ztoken (who principal) (asset principal))
  (let ((reserve-data (try! (get-reserve-state asset))))
    (if (is-eq contract-caller (get a-token-address reserve-data))
      true
      (try! (is-approved-contract contract-caller)))
    (remove-supplied-asset who asset)
  )
)

(define-private (remove-supplied-asset (who principal) (asset principal))
  (let ((assets-data (get-user-assets who)))
    (contract-call? .pool-reserve-data
      set-user-assets
      who
      {
        assets-supplied: (get agg (fold filter-asset (get assets-supplied assets-data) { filter-by: asset, agg: (list) })),
        assets-borrowed: (get assets-borrowed assets-data)
      }
    )
  )
)

(define-private (add-borrowed-asset (who principal) (asset principal))
  (let ((assets-data (get-user-assets who)))
    (if (is-none (index-of? (get assets-borrowed assets-data) asset))
      ;; if not there, add it
      (contract-call? .pool-reserve-data
        set-user-assets
        who
        {
          assets-supplied: (get assets-supplied assets-data),
          assets-borrowed: (unwrap-panic (as-max-len? (append (get assets-borrowed assets-data) asset) u100)),
        }
      )
      ;; if already there, do nothing
      (ok true)
    )
  )
)

(define-private (remove-borrowed-asset (who principal) (asset principal))
  (let ((assets-data (get-user-assets who)))
    (contract-call? .pool-reserve-data
      set-user-assets
      who
      {
        assets-supplied: (get assets-supplied assets-data),
        assets-borrowed: (get agg (fold filter-asset (get assets-borrowed assets-data) { filter-by: asset, agg: (list) }))
      }
    )
  )
)

(define-read-only (filter-asset (asset principal) (ret { filter-by: principal, agg: (list 100 principal) }))
  (if (is-eq asset (get filter-by ret))
    ;; ignore, do not add
    ret
    ;; add back to list
    { filter-by: (get filter-by ret), agg: (unwrap-panic (as-max-len? (append (get agg ret) asset) u100)) }
  )
)

(define-read-only (get-user-assets (who principal))
  (default-to
    { assets-supplied: (list), assets-borrowed: (list) }
    (contract-call? .pool-reserve-data get-user-assets-read who)))

(define-read-only (get-user-origination-fee (who principal) (asset <ft>))
  (let (
    (user-data (get-user-reserve-data who (contract-of asset))))
    (get origination-fee user-data)
  )
)

(define-public (get-reserve-available-liquidity (asset <ft>))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
  )
    (ok (- (try! (contract-call? asset get-balance (get-reserve-vault asset))) (get accrued-to-treasury reserve-data) ))
  )
)

(define-read-only (get-user-index (who principal) (asset principal))
  (ok (default-to (get last-liquidity-cumulative-index (try! (get-reserve-state asset))) (contract-call? .pool-reserve-data get-user-index-read who asset))))

(define-read-only (get-reserve-state (asset principal))
  (ok (unwrap! (contract-call? .pool-reserve-data get-reserve-state-read asset) ERR_DOES_NOT_EXIST)))

(define-read-only (get-reserve-factor (asset principal))
  (default-to u0 (contract-call? .pool-reserve-data get-reserve-factor-read asset))
)

(define-read-only (get-reserve-state-optional (asset principal))
  (contract-call? .pool-reserve-data get-reserve-state-read asset))

(define-read-only (get-assets)
  (contract-call? .pool-reserve-data get-assets-read))

(define-public (add-asset (asset principal))
  (let (
    (prev-assets (get-assets))
  )
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-assets (unwrap-panic (as-max-len? (append prev-assets asset) u100)))
  )
)

(define-public (remove-asset (asset principal))
  (let (
    (prev-assets (get-assets))
  )
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-assets (get agg (fold filter-asset prev-assets { filter-by: asset, agg: (list) })))
  )
)

(define-public (set-reserve
  (asset principal)
  (state
    (tuple
      (last-liquidity-cumulative-index uint)
      (current-liquidity-rate uint)
      (total-borrows-stable uint)
      (total-borrows-variable uint)
      (current-variable-borrow-rate uint)
      (current-stable-borrow-rate uint)
      (current-average-stable-borrow-rate uint)
      (last-variable-borrow-cumulative-index uint)
      (base-ltv-as-collateral uint)
      (liquidation-threshold uint)
      (liquidation-bonus uint)
      (decimals uint)
      (a-token-address principal)
      (oracle principal)
      (interest-rate-strategy-address principal)
      (flashloan-enabled bool)
      (last-updated-block uint)
      (borrowing-enabled bool)
      (usage-as-collateral-enabled bool)
      (is-stable-borrow-rate-enabled bool)
      (supply-cap uint)
      (borrow-cap uint)
      (debt-ceiling uint)
      (accrued-to-treasury uint)
      (is-active bool)
      (is-frozen bool)
    )))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-reserve-state asset state)
  )
)

(define-private (set-reserve-internal
  (asset principal)
  (state
    (tuple
      (last-liquidity-cumulative-index uint)
      (current-liquidity-rate uint)
      (total-borrows-stable uint)
      (total-borrows-variable uint)
      (current-variable-borrow-rate uint)
      (current-stable-borrow-rate uint)
      (current-average-stable-borrow-rate uint)
      (last-variable-borrow-cumulative-index uint)
      (base-ltv-as-collateral uint)
      (liquidation-threshold uint)
      (liquidation-bonus uint)
      (decimals uint)
      (a-token-address principal)
      (oracle principal)
      (interest-rate-strategy-address principal)
      (flashloan-enabled bool)
      (last-updated-block uint)
      (borrowing-enabled bool)
      (usage-as-collateral-enabled bool)
      (is-stable-borrow-rate-enabled bool)
      (supply-cap uint)
      (borrow-cap uint)
      (debt-ceiling uint)
      (accrued-to-treasury uint)
      (is-active bool)
      (is-frozen bool)
    )))
  (contract-call? .pool-reserve-data set-reserve-state asset state)
)

(define-public (set-user-reserve
  (user principal)
  (asset principal)
  (state
    (tuple
    (principal-borrow-balance uint)
    (last-variable-borrow-cumulative-index uint)
    (origination-fee uint)
    (stable-borrow-rate uint)
    (last-updated-block uint)
    (use-as-collateral bool)
  )
    ))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-user-reserve-data user asset state)
  )
)

;; @desc The function updates cumulative indexes, reserve interest rates, and the timestamp.
(define-public (update-state-on-deposit
  (asset <ft>)
  (who principal)
  (amount-deposited uint)
  (is-first-deposit bool)
  )
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (let (
      (indexes (try! (update-cumulative-indexes (contract-of asset))))
    )
      (try! 
        (accrue-to-treasury
          (get curr-variable-borrow-cumulative-index indexes)
          (get next-variable-borrow-cumulative-index indexes)
          (get next-liquidity-cumulative-index indexes)
          (contract-of asset)))
      (try! (update-reserve-interest-rates-and-timestamp asset amount-deposited u0))

      (if is-first-deposit
        (add-supplied-asset who (contract-of asset))
        (ok true)
      )
    )
  )
)

;; @desc after a flash loan is executed. It includes transferring the protocol fee, updating cumulative 
;; indexes, and adjusting the liquidity index based on the income generated from the flash loan.
(define-public (update-state-on-flash-loan
  (receiver principal)
  (asset <ft>)
  (available-liquidity-before uint)
  (income uint)
  (protocol-fee uint)
  )
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (indexes (try! (update-cumulative-indexes (contract-of asset))))
  )
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (try!
      (accrue-to-treasury
        (get curr-variable-borrow-cumulative-index indexes)
        (get next-variable-borrow-cumulative-index indexes)
        (get next-liquidity-cumulative-index indexes)
        (contract-of asset)))
    (try! (transfer-fee-to-collection asset receiver protocol-fee (get-collection-address)))

    (try! (cumulate-to-liquidity-index
        (+ available-liquidity-before (get total-borrows-variable reserve-data))
        income
        (contract-of asset)
      )
    )

    (try! (update-reserve-interest-rates-and-timestamp asset income u0))
    (ok u0)
  )
)

;; @desc Update the liquidity index of a specific asset's reserve.
;; cumulate additional amounts to the reserve's liquidity index.
(define-private (cumulate-to-liquidity-index
  (total-liquidity uint)
  (amount uint)
  (asset principal))
  (let (
    (reserve-data (try! (get-reserve-state asset)))
    (amount-to-liquidity-ratio (div-precision-to-fixed amount total-liquidity (get decimals reserve-data)))
    (cumulated-liquidity (+ amount-to-liquidity-ratio one-8)))
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data
      set-reserve-state
      asset
      (merge
        reserve-data
        { last-liquidity-cumulative-index: (mul cumulated-liquidity (get last-liquidity-cumulative-index reserve-data)) }))))

;; @desc handles the updating of cumulative indexes, reserve state, user state, and reserve interest rates
(define-public (update-state-on-repay
  (asset <ft>)
  (who principal)
  (payback-amount-minus-fees uint)
  (origination-fee-repaid uint)
  (balance-increase uint)
  (repaid-whole-loan bool))
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (let (
      (indexes (try! (update-cumulative-indexes (contract-of asset))))
    )
      (try!
        (accrue-to-treasury
          (get curr-variable-borrow-cumulative-index indexes)
          (get next-variable-borrow-cumulative-index indexes)
          (get next-liquidity-cumulative-index indexes)
          (contract-of asset))) 
      (try! (update-reserve-state-on-repay who payback-amount-minus-fees balance-increase asset))
      (try! (update-user-state-on-repay asset who payback-amount-minus-fees u0 balance-increase repaid-whole-loan))

      (try! (update-reserve-interest-rates-and-timestamp asset payback-amount-minus-fees u0))
      (ok true)
    )
  )
)

;; @desc called when a user redeems their deposited assets. Updates the cumulative indexes, reserve interest rates
;; for the specific asset. if the user has redeemed their entire 
;; balance of the asset, it resets their data and updates their collateral status.
(define-public (update-state-on-redeem
  (asset <ft>)
  (who principal)
  (amount-claimed uint)
  (user-redeemed-everything bool)
  )
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (let (
      (indexes (try! (update-cumulative-indexes (contract-of asset))))
    )
      (try!
        (accrue-to-treasury
          (get curr-variable-borrow-cumulative-index indexes)
          (get next-variable-borrow-cumulative-index indexes)
          (get next-liquidity-cumulative-index indexes)
          (contract-of asset)))
      (try! (update-reserve-interest-rates-and-timestamp asset u0 amount-claimed))

      (if user-redeemed-everything
        (remove-supplied-asset who (contract-of asset))
        (ok true)
      )
    )
  )
)

;; @desc invoked after the liquidation process. It updates the states of both the principal 
;; and collateral reserves involved in the liquidation. Handle the changes in reserve states 
;; and user states due to the liquidation of a borrower's position. It ensures the proper accounting of the 
;; principal amount liquidated, fees, and the collateral affected.
(define-public (update-state-on-liquidation
  (principal-reserve <ft>)
  (collateral-reserve <ft>)
  (borrower principal)
  (liquidator-addr principal)
  (principal-amount-to-liquidate uint)
  (collateral-to-liquidate uint)
  (fee-liquidated uint)
  (liquidated-collateral-for-fee uint)
  (balance-increase uint)
  (purchased-all-collateral bool)
  (liquidator-receives-aToken bool))
  (begin
    (asserts! (is-liquidator contract-caller) ERR_UNAUTHORIZED)
    (let (
      (principal-indexes (try! (update-cumulative-indexes (contract-of principal-reserve))))
    )
      (try! (update-principal-reserve-state-on-liquidation principal-reserve borrower principal-amount-to-liquidate balance-increase))
      (try!
        (accrue-to-treasury
          (get curr-variable-borrow-cumulative-index principal-indexes)
          (get next-variable-borrow-cumulative-index principal-indexes)
          (get next-liquidity-cumulative-index principal-indexes)
          (contract-of principal-reserve)))

      (try! (update-user-state-on-liquidation principal-reserve borrower principal-amount-to-liquidate
        ;; fee-liquidated
        u0
        balance-increase))
      (try! (update-reserve-interest-rates-and-timestamp principal-reserve principal-amount-to-liquidate u0))

      (if purchased-all-collateral
        (try! (remove-supplied-asset borrower (contract-of collateral-reserve)))
        false)

      (if (not liquidator-receives-aToken)
        (let (
          (indexes-collateral (try! (update-cumulative-indexes (contract-of collateral-reserve))))
        )
          (try!
            (accrue-to-treasury
              (get curr-variable-borrow-cumulative-index indexes-collateral)
              (get next-variable-borrow-cumulative-index indexes-collateral)
              (get next-liquidity-cumulative-index indexes-collateral)
              (contract-of collateral-reserve)))
          (update-reserve-interest-rates-and-timestamp collateral-reserve u0 (+ collateral-to-liquidate liquidated-collateral-for-fee))
        )
        (begin
          (try! (add-supplied-asset liquidator-addr (contract-of collateral-reserve)))
          (ok false)
        )
      )
    )

  )
)

;; @desc update the state of the principal reserve during a liquidation event.
;; It adjusts the total variable borrows in the principal reserve, accounting for the amount liquidated and any balance increase.
;; The function is called as part of the liquidation process to ensure accurate tracking of borrow amounts in the reserve after liquidation.
(define-private (update-principal-reserve-state-on-liquidation
  (principal-reserve <ft>)
  (user principal)
  (amount-to-liquidate uint)
  (balance-increase uint)
  )
  (let (
    (reserve-data (try! (get-reserve-state (contract-of principal-reserve))))
    (user-data (get-user-reserve-data user (contract-of principal-reserve))))
    (asserts! (is-liquidator contract-caller) ERR_UNAUTHORIZED)
    (try! (update-cumulative-indexes (contract-of principal-reserve)))

    (contract-call? .pool-reserve-data
      set-reserve-state
      (contract-of principal-reserve)
      (merge
        reserve-data
        { total-borrows-variable: (- (+ balance-increase (get total-borrows-variable reserve-data)) amount-to-liquidate) }))))

;; @desc manages the update of a user's state in the reserve during a liquidation process.
;; It adjusts the user's borrow balance by accounting for the liquidated amount, any accrued balance increase,
;; and the fees liquidated. This function ensures that the user's borrow balance and related parameters are accurately
;; updated post-liquidation, reflecting changes in their debt and fee obligations within the reserve.
(define-private (update-user-state-on-liquidation
  (reserve <ft>)
  (user principal)
  (amount-to-liquidate uint)
  (fee-liquidated uint)
  (balance-increase uint))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of reserve))))
    (user-data (get-user-reserve-data user (contract-of reserve)))
    (principal-borrow-balance
      (-
        (+ (get principal-borrow-balance user-data) balance-increase)
        amount-to-liquidate
      )
    )
    (last-variable-borrow-cumulative-index (get last-variable-borrow-cumulative-index reserve-data))
    (origination-fee u0))
    (asserts! (is-liquidator contract-caller) ERR_UNAUTHORIZED)
    ;; if purchased entire borrowed balance
    (if (is-eq principal-borrow-balance u0)
      (try! (remove-borrowed-asset user (contract-of reserve)))
      true
    )

    (contract-call? .pool-reserve-data
      set-user-reserve-data
      user (contract-of reserve)
      (merge
        user-data
        {
          principal-borrow-balance: principal-borrow-balance,
          last-variable-borrow-cumulative-index: last-variable-borrow-cumulative-index,
          ;; origination-fee: origination-fee,
          last-updated-block: burn-block-height }))))

(define-private (reset-data-on-zero-balance-internal (who principal) (asset principal))
  (contract-call? .pool-reserve-data delete-user-reserve-data who asset))

(define-public (reset-user-index (who principal) (asset principal))
  (let ((reserve-data (try! (get-reserve-state asset))))
    (if (is-eq contract-caller (get a-token-address reserve-data))
      true
      (try! (is-approved-contract contract-caller)))
    (contract-call? .pool-reserve-data delete-user-index who asset)
  )
)

;; @desc updates the state of the reserve from which the assets are borrowed,
(define-public (update-state-on-borrow
  (asset <ft>)
  (who principal)
  (amount-borrowed uint)
  (borrow-fee uint))
  (let (
    (ret (try! (get-user-borrow-balance who asset))))
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (try!
      (update-reserve-state-on-borrow
        (get principal ret)
        (get balance-increase ret)
        amount-borrowed
        (contract-of asset)))
    (try!
      (update-user-state-on-borrow
        who
        asset
        amount-borrowed
        (get balance-increase ret)
        borrow-fee))
    (try! (update-reserve-interest-rates-and-timestamp asset u0 amount-borrowed))
    (try! (add-borrowed-asset who (contract-of asset)))

    (ok {
      balance-increase: (get balance-increase ret)
    })
  )
)

;; @desc updates the user's reserve data upon repayment of a loan. It adjusts the user's 
;; principal borrow balance, accounting for the repayment amount, fees paid, and any accrued interest.
(define-private (update-user-state-on-repay
  (asset <ft>)
  (who principal)
  (payback-amount-minus-fees uint)
  (origination-fee-repaid uint)
  (balance-increase uint)
  (repaid-whole-loan bool))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (user-data (get-user-reserve-data who (contract-of asset)))
    (principal-borrow-balance
      (- (+ (get principal-borrow-balance user-data) balance-increase) payback-amount-minus-fees))
    (last-variable-borrow-cumulative-index
      (if repaid-whole-loan
        u0
        (get last-variable-borrow-cumulative-index reserve-data)
      )
    )
    (last-updated-block burn-block-height))

  (try! (contract-call? .pool-reserve-data set-user-reserve-data
    who (contract-of asset)
    (merge
      user-data
      {
        principal-borrow-balance: principal-borrow-balance,
        last-variable-borrow-cumulative-index: last-variable-borrow-cumulative-index,
        ;; origination-fee: origination-fee,
        last-updated-block: last-updated-block
      })))
  (if repaid-whole-loan
    (try! (remove-borrowed-asset who (contract-of asset)))
    false
  )
  (ok true)
  )
)

;; @desc manages the update of the reserve's state when a loan repayment is made.
;; It adjusts the total variable borrows in the reserve, taking into account the repaid amount,
;; and any balance increase due to accrued interest.
(define-private (update-reserve-state-on-repay
  (who principal)
  (payback-amount-minus-fees uint)
  (balance-increase uint)
  (asset <ft>))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (user-data (get-user-reserve-data who (contract-of asset))))
    (contract-call? .pool-reserve-data
      set-reserve-state
      (contract-of asset)
      (merge
        reserve-data
        { total-borrows-variable: (- (+ (get total-borrows-variable reserve-data) balance-increase) payback-amount-minus-fees) }))))

;; @desc updates a user's borrowing state in the system when they take out a new loan.
;; It modifies the user's principal borrow balance, incorporating the borrowed amount, any accrued balance increase,
;; and the origination fee.
(define-private (update-user-state-on-borrow
  (who principal)
  (asset <ft>)
  (amount-borrowed uint)
  (balance-increase uint)
  (fee uint))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (user-data (get-user-reserve-data who (contract-of asset)))
    (new-user-data {
      stable-borrow-rate: u0,
      last-variable-borrow-cumulative-index: (get last-variable-borrow-cumulative-index reserve-data),
      principal-borrow-balance: (+ (get principal-borrow-balance user-data) amount-borrowed balance-increase),
      last-updated-block: burn-block-height }))
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    
    (contract-call? .pool-reserve-data set-user-reserve-data who (contract-of asset) (merge user-data new-user-data))
  )
)

(define-public (update-reserve-state-on-borrow
  (principal-borrow-balance uint)
  (balance-increase uint)
  (amount-borrowed uint)
  (asset principal)
  )
  (begin
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (try! (update-cumulative-indexes asset))
    (try! (update-reserve-total-borrows-by-rate-mode
      principal-borrow-balance
      balance-increase
      amount-borrowed
      asset
    ))
    (ok u0)
  )
)

(define-public (update-reserve-total-borrows-by-rate-mode
  (principal-balance uint)
  (balance-increase uint)
  (amount-borrowed uint)
  (asset principal)
  )
  (let (
    (reserve-data (try! (get-reserve-state asset)))
    (new-principal-amount (+ principal-balance balance-increase amount-borrowed))
  )
    (asserts! (is-lending-pool contract-caller) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data
      set-reserve-state
      asset
      (merge
        reserve-data
        {
          total-borrows-variable: (+ (get total-borrows-variable reserve-data) balance-increase amount-borrowed)
        }
      )
    )
  )
)

(define-read-only (get-user-borrow-balance
  (who principal)
  (asset <ft>)
)
  (let (
    (user-data (get-user-reserve-data who (contract-of asset)))
    (reserve-data (try! (get-reserve-state (contract-of asset))))
  )
    (if (is-eq (get principal-borrow-balance user-data) u0)
      (ok {
          principal: u0,
          compounded-balance: u0,
          balance-increase: u0,
        })
      (let (
        (principal (get principal-borrow-balance user-data))
        (compounded-balance 
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
        (ok {
            principal: principal,
            compounded-balance: compounded-balance,
            balance-increase: (- compounded-balance principal),
          })
      )
    )
  )
)


(define-public (sum-total-debt-in-base-currency
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (begin
    (try! (validate-assets-order assets-to-calculate))
    (fold aggregate-debt
      assets-to-calculate
      (ok u0)
    )
  )
)

(define-public (aggregate-debt
  (reserve { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })
  (total (response uint uint)))
  (let (
    (result (try! total))
    (asset (get asset reserve))
    (reserve-state (try! (get-reserve-state (contract-of asset)))))
    (if (and (is-borroweable-isolated (contract-of asset)))
      ;; add up debt
      (let (
        (oracle (get oracle reserve))
        (curr-total-variable-debt
          (mul-precision-with-factor
            (get total-borrows-variable reserve-state)
            (get decimals reserve-state)
            (get last-variable-borrow-cumulative-index reserve-state)))
        (debt-in-base-currency (mul-to-fixed-precision curr-total-variable-debt (get decimals reserve-state) (try! (contract-call? oracle get-asset-price asset))))
      )
        (ok (+ debt-in-base-currency result))
      )
      (ok result)
    )
  )
)

;; check if balance decrease sets position health factor under 1e8
(define-public (check-balance-decrease-allowed
  (asset <ft>)
  (oracle <oracle-trait>)
  (amount uint)
  (user principal)
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  )
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (user-data (get-user-reserve-data user (contract-of asset)))
  )
    (try! (validate-assets-order assets-to-calculate))
    (if (or (not (get usage-as-collateral-enabled reserve-data)) (not (get use-as-collateral user-data)))
      ;; do nothing
      (ok true) ;; if reserve is not used as collaeteral, allow the transfer
      (let (
        (user-global-data (try! (calculate-user-global-data user assets-to-calculate)))
      )
        (if (is-eq (get total-borrow-balanceUSD user-global-data) u0)
          (ok true) ;; not borrowing anything, no reason to block
          (let (
            (collateral-balance-in-base-currency (get total-collateral-balanceUSD user-global-data))
            (amount-to-decrease-in-base-currency (mul-to-fixed-precision amount (get decimals reserve-data) (try! (contract-call? oracle get-asset-price asset))))
            (collateral-balance-after-decrease
              (if (<= (get total-collateral-balanceUSD user-global-data) amount-to-decrease-in-base-currency)
                u0
                (- (get total-collateral-balanceUSD user-global-data) amount-to-decrease-in-base-currency)
              )
            )
          )
            (if (is-eq collateral-balance-after-decrease u0)
              (ok false)
              (let (
                  (liquidation-treshold-after-decrease
                    (div
                      (-
                        (mul collateral-balance-in-base-currency (get current-liquidation-threshold user-global-data))
                        (mul amount-to-decrease-in-base-currency (get liquidation-threshold reserve-data))
                      )
                      collateral-balance-after-decrease
                    )
                  )
                  (health-factor-after-decrease
                    (calculate-health-factor-from-balances
                      collateral-balance-after-decrease
                      (get total-borrow-balanceUSD user-global-data)
                      (get user-total-feesUSD user-global-data)
                      liquidation-treshold-after-decrease
                    )
                  )
                )
                (ok (> health-factor-after-decrease (get-health-factor-liquidation-threshold)))
              )
            )
          )
        )
      )
    )
  )
)

(define-public (transfer-fee-to-collection
  (asset <ft>)
  (who principal)
  (amount uint)
  (destination principal))
  (begin
    (try! (contract-call? asset transfer amount who destination none))
    (ok amount)
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
  (let (
    (user-cumulative-index
      (if (is-eq last-variable-borrow-cumulative-index u0)
        last-variable-borrow-cumulative-index-reserve
        last-variable-borrow-cumulative-index
      )
    )
    (cumulated-interest
      (if (> stable-borrow-rate u0)
        u0
        (div
          (mul
            (calculate-compounded-interest
              current-variable-borrow-rate
              (- burn-block-height last-updated-block-reserve))
            last-variable-borrow-cumulative-index-reserve)
          user-cumulative-index)
      ))
    (compounded-balance (mul-precision-with-factor principal-borrow-balance decimals cumulated-interest)))
    (if (is-eq compounded-balance principal-borrow-balance)
      ;; add 1 in case of rounding down
      (if (not (is-eq last-updated-block burn-block-height))
        (+ principal-borrow-balance u1)
        compounded-balance
      )
      compounded-balance
    )
  )
)

(define-public (transfer-to-user
  (asset <ft>)
  (who principal)
  (amount uint)
  )
  (begin
    (asserts! (or
      (is-lending-pool tx-sender)
      (is-lending-pool contract-caller)
      (is-liquidator tx-sender)
      (is-liquidator contract-caller)
      ) ERR_UNAUTHORIZED)
    (try! (get-reserve-state (contract-of asset)))
    (try! (as-contract (contract-call? .pool-vault transfer amount who asset)))
    (ok u0)
  )
)

(define-private (set-user-reserve-as-collateral-internal (user principal) (asset <ft>) (use-as-collateral bool))
  (let (
    (user-data (get-user-reserve-data user (contract-of asset)))
  )
    (contract-call? .pool-reserve-data 
      set-user-reserve-data
      user (contract-of asset)
      (merge user-data { use-as-collateral: use-as-collateral })
    )
  )
)

(define-public (set-user-reserve-as-collateral (user principal) (asset <ft>) (use-as-collateral bool))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset)))))
    (asserts! (or (is-eq contract-caller (get a-token-address reserve-data)) (is-lending-pool contract-caller)) ERR_UNAUTHORIZED)
    (set-user-reserve-as-collateral-internal user asset use-as-collateral)
  )
)

(define-public (mint-to-treasury
  (lp <ft-mint-trait>)
  (pool-reserve principal)
  (asset <ft>)
  )
  (let (
    (asset-principal (contract-of asset))
    (reserve-state (try! (get-reserve-state asset-principal)))
    (collection-principal (get-collection-address))
    (normalized-income (get-normalized-income
        (get current-liquidity-rate reserve-state)
        (get last-updated-block reserve-state)
        (get last-liquidity-cumulative-index reserve-state)))
    (amount-to-mint
      (mul-precision-with-factor
        (get accrued-to-treasury reserve-state)
        (get decimals reserve-state)
        normalized-income
      )
    )
    )
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (asserts! (> amount-to-mint u0) ERR_NON_ZERO)
    (try! (contract-call? lp mint amount-to-mint collection-principal))
    (try! (contract-call? .pool-reserve-data set-reserve-state (contract-of asset) (merge reserve-state { accrued-to-treasury: u0 })))

    (print { type: "mint-to-treasury", payload: { key: collection-principal, data: { amount: amount-to-mint } } })
    (ok amount-to-mint)
  )
)

(define-private (update-reserve-interest-rates-and-timestamp
  (asset <ft>)
  (liquidity-added uint)
  (liquidity-taken uint)
  )
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (ret
      (try! 
        (calculate-interest-rates
          (- (+ (try! (get-reserve-available-liquidity asset)) liquidity-added) liquidity-taken)
          (get total-borrows-stable reserve-data)
          (get total-borrows-variable reserve-data)
          (get current-average-stable-borrow-rate reserve-data)
          (contract-of asset)
          (get decimals reserve-data)
        )
      )
    )
    (new-reserve-state
      (merge
        reserve-data
        {
          last-updated-block: burn-block-height,
          current-liquidity-rate: (get current-liquidity-rate ret),
          current-variable-borrow-rate: (get current-variable-borrow-rate ret)
        }
      )
    )
  )
    (contract-call? .pool-reserve-data set-reserve-state (contract-of asset) new-reserve-state)
  )
)

(define-public (transfer-to-reserve
  (asset <ft>)
  (who principal)
  (amount uint)
  )
  (begin
    (try! (contract-call? asset transfer amount who (get-reserve-vault asset) none))
    (ok u0)
  )
)

(define-read-only (get-reserve-vault (asset <ft>))
  (contract-call? .pool-reserve-data get-reserve-vault-read)
)

(define-public (set-user-index (who principal) (asset principal) (new-user-index uint))
  (let (
    (reserve-data (try! (get-reserve-state asset))))
    (if (is-eq contract-caller (get a-token-address reserve-data))
      true
      (try! (is-approved-contract contract-caller))
    )
    (contract-call? .pool-reserve-data set-user-index who asset new-user-index)
  )
)

(define-private (set-user-index-internal (who principal) (asset principal) (new-user-index uint))
  (contract-call? .pool-reserve-data set-user-index who asset new-user-index))

(define-read-only (calculate-cumulated-balance
  (who principal)
  (lp-decimals uint)
  (asset <ft>)
  (asset-balance uint)
  (asset-decimals uint))
  (let (
    (asset-principal (contract-of asset))
    (reserve-data (try! (get-reserve-state asset-principal)))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data))))
      (ok 
        (mul-precision-with-factor
          asset-balance
          asset-decimals
          (div reserve-normalized-income (try! (get-user-index who asset-principal))))
      )
  )
)

(define-private (update-cumulative-indexes (asset principal))
  (let (
    (reserve-data (try! (get-reserve-state asset)))
    (total-borrows (get total-borrows-variable reserve-data))
  )
    (if (> total-borrows u0)
      (let (
        (cumulated-liquidity-interest
          (calculate-linear-interest
            (get current-liquidity-rate reserve-data)
            (- burn-block-height (get last-updated-block reserve-data))
          )
        )
        (new-last-liquidity-cumulative-index
          (mul
            cumulated-liquidity-interest
            (get last-liquidity-cumulative-index reserve-data)
          )
        )
        (cumulated-variable-borrow-interest
          (calculate-compounded-interest
            (get current-variable-borrow-rate reserve-data)
            (- burn-block-height (get last-updated-block reserve-data))
          )
        )
        (new-last-variable-borrow-liquidity-cumulative-index
          (mul
            cumulated-variable-borrow-interest
            (get last-variable-borrow-cumulative-index reserve-data)
          )
        )
      )
        (try! (contract-call? .pool-reserve-data
          set-reserve-state
          asset
          (merge
            reserve-data
            {
              last-liquidity-cumulative-index: new-last-liquidity-cumulative-index,
              last-variable-borrow-cumulative-index: new-last-variable-borrow-liquidity-cumulative-index
            }
          )
        ))
        (ok
          {
            curr-liquidity-cumulative-index: (get last-liquidity-cumulative-index reserve-data),
            next-liquidity-cumulative-index: new-last-liquidity-cumulative-index,
            curr-variable-borrow-cumulative-index: (get last-variable-borrow-cumulative-index reserve-data),
            next-variable-borrow-cumulative-index: new-last-variable-borrow-liquidity-cumulative-index
          }
        )
      )
      (ok
        {
          curr-liquidity-cumulative-index: (get last-liquidity-cumulative-index reserve-data),
          next-liquidity-cumulative-index: (get last-liquidity-cumulative-index reserve-data),
          curr-variable-borrow-cumulative-index: (get last-variable-borrow-cumulative-index reserve-data),
          next-variable-borrow-cumulative-index: (get last-variable-borrow-cumulative-index reserve-data)
        }
      )
    )
  )
)

(define-read-only (get-normalized-income
  (current-liquidity-rate uint)
  (last-updated-block uint)
  (last-liquidity-cumulative-index uint))
  (let (
    (cumulated 
      (calculate-linear-interest
        current-liquidity-rate
        (- burn-block-height last-updated-block))))
    (mul cumulated last-liquidity-cumulative-index)
  )
)

(define-public (get-user-balance-reserve-data
  (lp-token <ft>)
  (asset <ft>)
  (user principal)
  (oracle <oracle-trait>)
  )
  (let (
    (user-data (get-user-reserve-data user (contract-of asset)))
    (reserve-data (try! (get-reserve-state (contract-of asset))))
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

(define-public (get-user-underlying-asset-balance
  (lp-token <ft>)
  (asset <ft>)
  (user principal)
  )
  (let (
    (user-data (get-user-reserve-data user (contract-of asset)))
    (reserve-data (get-reserve-state (contract-of asset)))
    (underlying-balance (try! (contract-call? lp-token get-balance user))))
    (ok underlying-balance)))

(define-public (aggregate-user-data
  (reserve { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })
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
      result )))

(define-public (get-user-basic-reserve-data
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
    (user-reserve-state (get-user-reserve-data user (contract-of asset)))
    (reserve-data (try! (get-reserve-state (contract-of asset))))
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
      (get-user-asset-data lp-token asset oracle aggregate)
      ;; add nothing
      (ok default-reserve-value)
    )
  )
)

(define-private (get-user-asset-data
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
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (is-lp-ok (asserts! (is-eq (get a-token-address reserve-data) (contract-of lp-token)) ERR_INVALID_Z_TOKEN))
    (is-oracle-ok (asserts! (is-eq (get oracle reserve-data) (contract-of oracle)) ERR_INVALID_ORACLE))
    (user-reserve-state (try! (get-user-balance-reserve-data lp-token asset user oracle)))
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

(define-read-only (get-assets-used-by (who principal))
  (let (
    (ret (get-user-assets who)))
    (unwrap-panic (as-max-len? (concat (get assets-supplied ret) (get assets-borrowed ret)) u100))))

(define-read-only (validate-assets-order
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (let ((assets-used (get-assets)))
    (fold check-assets assets-used (ok { idx: u0, assets: assets-to-calculate }))
  )
)

(define-read-only (check-assets
  (asset-to-validate principal)
  (ret (response { idx: uint, assets: (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })} uint)))
  (let (
    (agg (try! ret))
    (asset-principal (get asset (unwrap! (element-at? (get assets agg) (get idx agg)) ERR_NON_CORRESPONDING_ASSETS))))
    (asserts! (is-eq asset-to-validate (contract-of asset-principal)) ERR_NON_CORRESPONDING_ASSETS)
    
    (ok { idx: (+ u1 (get idx agg)), assets: (get assets agg) })
  )
)

(define-public (calculate-user-global-data
  (user principal)
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (begin
    (try! (validate-assets-order assets-to-calculate))
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

(define-read-only (calculate-collateral-needed-in-USD
  (borrowing-asset <ft>)
  (amount uint)
  (decimals uint)
  (asset-price uint)
  (borrow-fee uint)
  (current-user-borrow-balance-USD uint)
  (current-fees-USD uint)
  (current-ltv uint)
  )
  (let (
    (requested-borrow-amount-USD (mul-to-fixed-precision (+ amount u0) decimals asset-price))
    (collateral-needed-in-USD
      (div
        (+ current-user-borrow-balance-USD u0 requested-borrow-amount-USD)
        current-ltv))
    )
    {
      collateral-needed-in-USD: collateral-needed-in-USD,
      requested-borrow-amount-USD: requested-borrow-amount-USD,
    }
  )
)

(define-read-only (from-fixed-to-precision (a uint) (decimals-a uint))
  (contract-call? .math from-fixed-to-precision a decimals-a))

(define-read-only (calculate-health-factor-from-balances
  (total-collateral-balanceUSD uint)
  (total-borrow-balanceUSD uint)
  (total-feesUSD uint)
  (current-liquidation-threshold uint))
  (if (is-eq total-borrow-balanceUSD u0)
    max-value
    (div
      (mul
        total-collateral-balanceUSD
        current-liquidation-threshold
      )
      (+ total-borrow-balanceUSD u0)
    )
  )
)

(define-read-only (calculate-compounded-interest
  (current-liquidity-rate uint)
  (delta uint))
  (taylor-6 (get-rt-by-block current-liquidity-rate delta))
)

(define-read-only (get-rt-by-block (rate uint) (blocks uint))
  (contract-call? .math get-rt-by-block rate blocks)
)

(define-read-only (calculate-linear-interest
  (current-liquidity-rate uint)
  (delta uint))
  (let (
    (rate (get-rt-by-block current-liquidity-rate delta))
  )
    (+ one-8 rate)
  )
)


(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math mul-precision-with-factor a decimals-a b-fixed))

(define-read-only (div-precision-to-fixed (a uint) (b uint) (decimals uint))
  (contract-call? .math div-precision-to-fixed a b decimals))

;; returns current liquidity rate
(define-read-only (calculate-interest-rates
    (available-liquidity uint)
    (total-borrows-stable uint)
    (total-borrows-variable uint)
    (average-stable-borrow-rate uint)
    (asset principal)
    (decimals uint)
  )
  (let (
    (total-borrows total-borrows-variable)
    (optimal-utilization-rate (try! (get-optimal-utilization-rate asset)))
    (utilization-rate
      (if (is-eq total-borrows u0)
        u0
        (div-precision-to-fixed total-borrows (+ total-borrows available-liquidity) decimals))))
    (if (> utilization-rate optimal-utilization-rate)
      (let (
        (excess-utilization-rate-ratio (div (- utilization-rate optimal-utilization-rate) (- one-8 optimal-utilization-rate)))
        (new-variable-borrow-rate
          (+
            (+ (try! (get-base-variable-borrow-rate asset)) (try! (get-variable-rate-slope-1 asset)))
            (mul (try! (get-variable-rate-slope-2 asset)) excess-utilization-rate-ratio))
          ))
          (ok 
            {
              current-liquidity-rate:
              (mul
                new-variable-borrow-rate
                utilization-rate
              ),
              current-variable-borrow-rate: new-variable-borrow-rate,
              utilization-rate: utilization-rate,
            }
          )
      )
      (let (
        (new-variable-borrow-rate
          (+
            (try! (get-base-variable-borrow-rate asset))
            (mul
              (div utilization-rate optimal-utilization-rate)
              (try! (get-variable-rate-slope-1 asset))
            ))))
          (ok 
            {
              current-liquidity-rate:
                (mul
                  (mul 
                    new-variable-borrow-rate
                    utilization-rate
                  )
                  (- one-8 (get-reserve-factor asset))
                ),
              current-variable-borrow-rate: new-variable-borrow-rate,
              utilization-rate: utilization-rate,
            }
          )
      )
    )
  )
)

(define-private (accrue-to-treasury
  (current-variable-borrow-cumulative-index uint)
  (next-variable-borrow-cumulative-index uint)
  (new-last-liquidity-cumulative-index uint)
  (asset principal)
  )
  (let (
    (reserve-data (try! (get-reserve-state asset)))
    (reserve-factor (get-reserve-factor asset))
    (decimals (get decimals reserve-data))
    (prev-total-variable-debt
      (mul-precision-with-factor
        (get total-borrows-variable reserve-data)
        decimals
        current-variable-borrow-cumulative-index))
    (curr-total-variable-debt
      (mul-precision-with-factor
        (get total-borrows-variable reserve-data)
        decimals
        next-variable-borrow-cumulative-index))
    (debt-accrued (- curr-total-variable-debt prev-total-variable-debt))
    (amount-to-mint (mul-precision-with-factor debt-accrued decimals (div reserve-factor new-last-liquidity-cumulative-index)))
  )
    (if (> amount-to-mint u0)
      (begin
        (try! (set-reserve-internal asset (merge reserve-data { accrued-to-treasury: (+ amount-to-mint (get accrued-to-treasury reserve-data)) })))
        (ok amount-to-mint)
      )
      (ok u0)
    )
  )
)

(define-read-only (get-collection-address)
  (contract-call? .pool-reserve-data get-protocol-treasury-addr-read))

