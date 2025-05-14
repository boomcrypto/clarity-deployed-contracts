(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait a-token .a-token-trait.a-token-trait)
(use-trait flash-loan .flash-loan-trait.flash-loan-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)
(use-trait redeemeable-trait .redeemeable-trait-v1-2.redeemeable-trait)

(define-constant max-value (contract-call? .math-v2-0 get-max-value))
(define-constant one-8 (contract-call? .math-v2-0 get-one))

(define-constant ERR_UNAUTHORIZED (err u30000))
(define-constant ERR_BORROW_TOO_SMALL (err u30001))
(define-constant ERR_NOT_ZERO (err u30002))
(define-constant ERR_NOT_ENOUGH_COLLATERAL (err u30003))
(define-constant ERR_EXCEED_BORROW_CAP (err u30004))
(define-constant ERR_EXCEED_DEBT_CEIL (err u30005))
(define-constant ERR_BORROWING_DISABLED (err u30006))
(define-constant ERR_EXCEEDED_LIQ (err u30007))
(define-constant ERR_NOT_SILOED_ASSET (err u30008))
(define-constant ERR_INVALID_Z_TOKEN (err u30009))
(define-constant ERR_INVALID_ORACLE (err u30010))
(define-constant ERR_BORROWING_SUPPLIED_ASSET (err u30011))
(define-constant ERR_INACTIVE (err u30012))
(define-constant ERR_FROZEN (err u30013))
(define-constant ERR_SUPPLYING_BORROWED_ASSET (err u30014))
(define-constant ERR_FLASHLOAN_DISABLED (err u30015))
(define-constant ERR_MUST_BORROW_E_MODE_TYPE (err u30016))
(define-constant ERR_REPAY_BEFORE_DISABLING (err u30017))
(define-constant ERR_INVALID_DECREASE (err u30018))
(define-constant ERR_MUST_DISABLE_ISOLATED_ASSET (err u30019))
(define-constant ERR_EXCEED_SUPPLY_CAP (err u30020))
(define-constant ERR_COLLATERAL_DISABLED (err u30021))
(define-constant ERR_CANNOT_ENABLE_ISOLATED_ASSET (err u30022))
(define-constant ERR_PANIC (err u30023))
(define-constant ERR_INVALID_ASSETS (err u30024))
(define-constant ERR_NON_CORRESPONDING_ASSETS (err u30025))
(define-constant ERR_INVALID_AMOUNT (err u30026))
(define-constant ERR_NOT_IN_ISOLATED_MODE (err u30027))
(define-constant ERR_HEALTH_FACTOR_LIQUIDATION_THRESHOLD (err u30028))


(define-map users-id uint principal)

(define-data-var last-user-id uint u0)

(define-read-only (get-user (id uint))
  (map-get? users-id id)
)

(define-read-only (get-last-user-id)
  (var-get last-user-id)
)

(define-public (supply
  (lp <redeemeable-trait>)
  (pool-reserve principal)
  (asset <ft>)
  (amount uint)
  (owner principal)
  )
  (let (
    (supplied-asset-principal (contract-of asset))
    (reserve-state (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state supplied-asset-principal)))
  )
    (asserts! (> amount u0) ERR_NOT_ZERO)
    (asserts! (get is-active reserve-state) ERR_INACTIVE)
    (asserts! (not (get is-frozen reserve-state)) ERR_FROZEN)
    (asserts! (is-eq (contract-of lp) (get a-token-address reserve-state)) ERR_INVALID_Z_TOKEN)
    (asserts! (is-eq owner tx-sender) ERR_UNAUTHORIZED)
    (let (
      (current-balance (try! (contract-call? lp get-balance owner)))
      (current-available-liquidity (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-available-liquidity asset)))
      (user-assets (contract-call? .pool-0-reserve-v2-0 get-user-assets owner))
      (isolated-asset (contract-call? .pool-0-reserve-v2-0 is-in-isolation-mode owner))
      (assets-used-as-collateral (contract-call? .pool-0-reserve-v2-0 get-assets-used-as-collateral owner)))
      (try! (is-approved-contract contract-caller))
      (asserts! (>= (get supply-cap reserve-state) (+ amount current-available-liquidity (get total-borrows-variable reserve-state))) ERR_EXCEED_SUPPLY_CAP)

      (map-insert users-id (var-get last-user-id) owner)
      (var-set last-user-id (+ u1 (var-get last-user-id)))

      ;; if first supply
      (if (is-eq current-balance u0)
        ;; additional checks for first supply and if it's isolation mode
        (if (and (get usage-as-collateral-enabled reserve-state)
            (unwrap-panic
              (validate-use-as-collateral
                isolated-asset
                ;; we only use base ltv, no need to fetch in case of e-mode
                (get base-ltv-as-collateral reserve-state)
                (get enabled-assets assets-used-as-collateral)
                supplied-asset-principal
                owner
                (get debt-ceiling reserve-state)
              ))
              )
          (try! (contract-call? .pool-0-reserve-v2-0 set-user-reserve-as-collateral owner asset true))
          false
        )
        false
      )

      (try! (contract-call? lp cumulate-balance owner))
      (try! (contract-call? .pool-0-reserve-v2-0 update-state-on-deposit asset owner amount (is-eq current-balance u0)))
      (try! (contract-call? lp mint amount owner))
      (try! (contract-call? .pool-0-reserve-v2-0 transfer-to-reserve asset owner amount))

      (print { type: "supply", payload: { key: owner, data: { amount: amount, lp: lp, asset: asset } } })
      (ok true)
    )
  )
)

(define-read-only (validate-use-as-collateral
  (isolated-asset (optional principal))
  (base-ltv-as-collateral uint)
  (assets-enabled-as-collateral (list 100 principal))
  (asset-address principal)
  (who principal)
  (debt-ceiling uint)
  )
    (if (is-eq base-ltv-as-collateral u0)
      (ok false)
      ;; not any as collateral
      (if (is-eq (len assets-enabled-as-collateral) u0)
        (ok true)
        ;; if it's in isolation mode
        (match isolated-asset
          ;; if user is in isolation mode, cannot enable anything
          isolated-asset-ok (ok false)
          ;; if user is not isolation mode, can set any asset to use as collateral that is not an isolated type
          (ok (not (contract-call? .pool-0-reserve-v2-0 is-isolated-type asset-address)))
        )
      )
    )
)

(define-public (withdraw
  (pool-reserve principal)
  (asset <ft>)
  (lp <redeemeable-trait>)
  (oracle <oracle-trait>)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (amount uint)
  (owner principal)
)
  (let (
    (reserve-state (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset))))
  )
    (try! (is-approved-contract contract-caller))
    (try! (validate-assets assets))
    (asserts! (is-eq (contract-of lp) (get a-token-address reserve-state)) ERR_INVALID_Z_TOKEN)
    (asserts! (is-eq (contract-of oracle) (get oracle reserve-state)) ERR_INVALID_ORACLE)
    (asserts! (is-eq owner tx-sender) ERR_UNAUTHORIZED)
    (let (
      (balances-ret (try! (contract-call? lp cumulate-balance owner)))
      (current-balance (get current-balance balances-ret))
      (amount-to-redeem (if (is-eq amount max-value) current-balance amount))
      (redeems-everything (>= amount-to-redeem current-balance))
      (current-available-liquidity (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-available-liquidity asset)))
    )
      (asserts! (> amount-to-redeem u0) ERR_NOT_ZERO)
      (asserts! (>= current-balance amount-to-redeem) ERR_INVALID_AMOUNT)
      (asserts! (not (get is-frozen reserve-state)) ERR_FROZEN)
      (asserts! (>= current-available-liquidity amount-to-redeem) ERR_EXCEEDED_LIQ)
      (asserts! (try! (contract-call? .pool-0-reserve-v2-0 check-balance-decrease-allowed asset oracle amount-to-redeem owner assets)) ERR_INVALID_DECREASE)

      (try! (contract-call? lp burn amount-to-redeem owner))

      (if (is-eq current-balance amount-to-redeem)
        (begin
          (try! (contract-call? .pool-0-reserve-v2-0 set-user-reserve-as-collateral owner asset false))
          (try! (contract-call? .pool-0-reserve-v2-0 remove-supplied-asset-ztoken owner (contract-of asset)))
          (try! (contract-call? .pool-0-reserve-v2-0 reset-user-index owner (contract-of asset)))
        )
        false
      )

      (try! (contract-call? .pool-0-reserve-v2-0 update-state-on-redeem asset owner amount-to-redeem redeems-everything))
      (try! (contract-call? .pool-0-reserve-v2-0 transfer-to-user asset owner amount-to-redeem))

      (print { type: "withdraw", payload: { key: owner, data: { amount: amount-to-redeem, asset: asset } } })
      (ok amount-to-redeem)
    )
  )
)

(define-public (borrow
  (pool-reserve principal)
  (oracle <oracle-trait>)
  (asset-to-borrow <ft>)
  (lp <ft>)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (amount-to-be-borrowed uint)
  (fee-calculator principal)
  (interest-rate-mode uint)
  (owner principal))
  (let (
    (asset (contract-of asset-to-borrow))
    (reserve-state (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset)))
  )
    (try! (is-approved-contract contract-caller))
    (try! (validate-assets assets))
    (asserts! (is-eq tx-sender owner) ERR_UNAUTHORIZED)

    (asserts! (is-eq (get a-token-address reserve-state) (contract-of lp)) ERR_INVALID_Z_TOKEN)
    (asserts! (is-eq (get oracle reserve-state) (contract-of oracle)) ERR_INVALID_ORACLE)

    (asserts! (get borrowing-enabled reserve-state) ERR_BORROWING_DISABLED)
    (asserts! (get is-active reserve-state) ERR_FROZEN)
    (asserts! (not (get is-frozen reserve-state)) ERR_FROZEN)
    (asserts! (> amount-to-be-borrowed u0) ERR_NOT_ZERO)

    (let (
      (available-liquidity (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-available-liquidity asset-to-borrow)))
      (is-in-isolation-mode (contract-call? .pool-0-reserve-v2-0 is-in-isolation-mode owner))
      (user-assets (contract-call? .pool-0-reserve-v2-0 get-user-assets owner))
    )
      (asserts! (>= available-liquidity amount-to-be-borrowed) ERR_EXCEEDED_LIQ)

      (match is-in-isolation-mode
        isolated-asset (begin
          (try! (validate-borrow-in-isolated-mode
              isolated-asset
              asset
              amount-to-be-borrowed
              oracle
              (contract-call? .pool-0-reserve-v2-0 mul-to-fixed-precision
                  amount-to-be-borrowed
                  (get decimals reserve-state)
                  (try! (contract-call? oracle get-asset-price asset-to-borrow)))
              assets))
        )
        true
      )

      (if (is-in-e-mode owner)
        ;; if in e-mode, check that the user is borrowing same e-mode type
        (asserts! (is-eq (get-asset-e-mode-type asset) (get-user-e-mode owner)) ERR_MUST_BORROW_E_MODE_TYPE)
        ;; nothing to check
        true
      )

      (let (
        (user-global-data (try! (contract-call? .pool-0-reserve-v2-0 calculate-user-global-data owner assets)))
        (borrow-balance (try! (contract-call? .pool-0-reserve-v2-0 get-user-balance-reserve-data lp asset-to-borrow owner oracle)))
        (amount-collateral-needed
          (contract-call? .pool-0-reserve-v2-0 calculate-collateral-needed-in-USD
            asset-to-borrow
            amount-to-be-borrowed
            (get decimals reserve-state)
            (try! (contract-call? oracle get-asset-price asset-to-borrow))
            u0
            (get total-borrow-balanceUSD user-global-data)
            (get user-total-feesUSD user-global-data)
            (get current-ltv user-global-data)))
        )
        (asserts! (> (get total-collateral-balanceUSD user-global-data) u0) ERR_NOT_ZERO)
        (asserts! (<= (get collateral-needed-in-USD amount-collateral-needed) (get total-collateral-balanceUSD user-global-data)) ERR_NOT_ENOUGH_COLLATERAL)
        (asserts! (>= (get borrow-cap reserve-state) (+ (get total-borrows-variable reserve-state) u0 amount-to-be-borrowed)) ERR_EXCEED_BORROW_CAP)

        ;; conditions passed, can borrow
        (try! (contract-call? .pool-0-reserve-v2-0 update-state-on-borrow asset-to-borrow owner amount-to-be-borrowed u0))
        (try! (contract-call? .pool-0-reserve-v2-0 transfer-to-user asset-to-borrow owner amount-to-be-borrowed))

        (print { type: "borrow", payload: { key: owner, data: { amount-to-be-borrowed: amount-to-be-borrowed, asset-to-borrow: asset-to-borrow, lp: lp } } })

        (ok amount-to-be-borrowed)
      )
    )
  )
)

(define-private (validate-borrow-in-isolated-mode
  (isolated-asset principal)
  (borrowed-asset principal)
  (amount-to-be-borrowed uint)
  (oracle <oracle-trait>)
  (amount-to-be-borrowed-in-base-currency uint)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
)
  (let (
    (isolated-reserve (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state isolated-asset)))
    (total-isolated-debt (try! (contract-call? .pool-0-reserve-v2-0 sum-total-debt-in-base-currency assets)))
  )
    (asserts! (contract-call? .pool-0-reserve-v2-0 is-borroweable-isolated borrowed-asset) ERR_NOT_SILOED_ASSET)
    (if (> (get debt-ceiling isolated-reserve) u0)
      (begin
        (asserts! (<= (+ amount-to-be-borrowed-in-base-currency total-isolated-debt) (get debt-ceiling isolated-reserve)) ERR_EXCEED_DEBT_CEIL)
        (ok true)
      )
      (ok true)
    )
  )
)

(define-public (repay
  (asset <ft>)
  (amount-to-repay uint)
  (on-behalf-of principal)
  (payer principal)
  )
  (let (
    (reserve-state (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset))))
    (ret (try! (contract-call? .pool-0-reserve-v2-0 get-user-borrow-balance on-behalf-of asset)))
    (amount-due (get compounded-balance ret))
    (payback-amount
      (if (is-eq amount-to-repay max-value)
        amount-due
        (if (> amount-to-repay amount-due)
          amount-due
          amount-to-repay ))))
    (try! (is-approved-contract contract-caller))
    (asserts! (> (get compounded-balance ret) u0) ERR_NOT_ZERO)
    (asserts! (not (get is-frozen reserve-state)) ERR_FROZEN)
    (asserts! (> amount-to-repay u0) ERR_NOT_ZERO)
    (asserts! (is-eq payer tx-sender) ERR_UNAUTHORIZED)

    ;; paying back the balance
    (begin
      (try!
        (contract-call? .pool-0-reserve-v2-0 update-state-on-repay
          asset
          on-behalf-of
          payback-amount
          u0
          (get balance-increase ret)
          (is-eq (get compounded-balance ret) payback-amount)
        )
      )
      (try! (contract-call? .pool-0-reserve-v2-0 transfer-to-reserve asset payer payback-amount))

      (print { type: "repay", payload: { key: on-behalf-of, data: { payback-amount: payback-amount, asset: asset } } })
      (ok payback-amount)
    )
  )
)

(define-public (liquidation-call
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (collateral-lp <a-token>)
  (collateral-to-liquidate <ft>)
  (debt-asset <ft>)
  (collateral-oracle <oracle-trait>)
  (debt-oracle <oracle-trait>)
  (liquidated-user principal)
  (debt-amount uint)
  (to-receive-atoken bool))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of debt-asset))))
    (collateral-data (try! (get-reserve-state (contract-of collateral-to-liquidate))))
  )
    (try! (is-approved-contract contract-caller))
    ;; only disabled in emergency mode
    (asserts! (not (get is-frozen collateral-data)) ERR_FROZEN)
    (asserts! (not (get is-frozen reserve-data)) ERR_FROZEN)
    (asserts! (is-eq (contract-of collateral-lp) (get a-token-address collateral-data)) ERR_INVALID_Z_TOKEN)
    (asserts! (is-eq (contract-of collateral-oracle) (get oracle collateral-data)) ERR_INVALID_ORACLE)
    (asserts! (is-eq (contract-of debt-oracle) (get oracle reserve-data)) ERR_INVALID_ORACLE)

    (try! (validate-assets assets))
    
    (print { type: "liquidation-call", payload: { key: liquidated-user, data: {
      collateral-to-liquidate: collateral-to-liquidate, debt-asset: debt-asset, liquidated-user: liquidated-user, debt-amount: debt-amount  } } })

    (contract-call? .liquidation-manager-v2-0-1 liquidation-call
      assets
      collateral-lp
      collateral-to-liquidate
      debt-asset
      collateral-oracle
      debt-oracle
      liquidated-user
      debt-amount
      to-receive-atoken
    )
  )
)


(define-read-only (get-assets)
  (contract-call? .pool-reserve-data get-assets-read))

(define-read-only (validate-assets
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (let ((assets-used (get-assets)))
    (asserts! (is-eq (len assets-used) (len assets-to-calculate)) ERR_INVALID_ASSETS)
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

(define-public (flashloan
  (receiver principal)
  (asset <ft>)
  (amount uint)
  (flashloan <flash-loan>))
  (let  (
    (available-liquidity-before (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-available-liquidity asset)))
    (total-fee-bps (try! (contract-call? .pool-0-reserve-v2-0 get-flashloan-fee-total (contract-of asset))))
    (protocol-fee-bps (try! (contract-call? .pool-0-reserve-v2-0 get-flashloan-fee-protocol (contract-of asset))))
    (amount-fee (/ (* amount total-fee-bps) u10000))
    (protocol-fee (/ (* amount-fee protocol-fee-bps) u10000))
    (reserve-data (try! (get-reserve-state (contract-of asset))))
  )
    (try! (is-approved-contract contract-caller))
    (asserts! (>= available-liquidity-before amount) ERR_EXCEEDED_LIQ)
    (asserts! (and (> amount-fee u0) (> protocol-fee u0)) ERR_NOT_ZERO)
    (asserts! (get flashloan-enabled reserve-data) ERR_FLASHLOAN_DISABLED)
    (asserts! (get is-active reserve-data) ERR_INACTIVE)
    (asserts! (not (get is-frozen reserve-data)) ERR_FROZEN)

    (try! (contract-call? .pool-0-reserve-v2-0 transfer-to-user asset receiver amount))
    (try! (contract-call? flashloan execute asset receiver amount))
    ;; force transfer of assets to vault
    (try!
      (contract-call? asset transfer
        (+ amount amount-fee)
        receiver
        .pool-vault
        none
      )
    )

    (try!
      (contract-call? .pool-0-reserve-v2-0 update-state-on-flash-loan
        receiver
        asset
        available-liquidity-before
        (- amount-fee protocol-fee)
        protocol-fee
      )
    )

    (print { type: "flashloan", payload: { key: receiver, data: { amount: amount, amount-fee: amount-fee, protocol-fee: protocol-fee } } })
    (ok u0)
  )
)

(define-data-var configurator principal tx-sender)

(define-public (set-configurator (new-configurator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get configurator)) ERR_UNAUTHORIZED)
    (ok (var-set configurator new-configurator))))

(define-read-only (is-configurator (caller principal))
  (if (is-eq caller (var-get configurator))
    true
    false))

(define-public (set-e-mode
  (user principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (new-e-mode-type (buff 1))
  )
  (begin
    (asserts! (is-eq tx-sender user) ERR_UNAUTHORIZED)
    (try! (is-approved-contract contract-caller))
    (try! (validate-assets assets))

    ;; if from default state
    (try! (can-enable-e-mode user new-e-mode-type))
    (try! (set-user-e-mode user new-e-mode-type))
    ;; check health, or revert
    (let (
      (user-global-data (try! (calculate-user-global-data user assets)))
    )
      ;; check health factor does not go below threshold with new e-mode
      (asserts! (not (get is-health-factor-below-treshold user-global-data)) ERR_HEALTH_FACTOR_LIQUIDATION_THRESHOLD)
      (ok new-e-mode-type)
    )
  )
)

(define-read-only (can-enable-e-mode (user principal) (e-mode-type (buff 1)))
  (contract-call? .pool-0-reserve-v2-0 can-enable-e-mode user e-mode-type))

(define-private (set-user-e-mode (who principal) (e-mode-type (buff 1)))
  (contract-call? .pool-reserve-data-2 set-user-e-mode who e-mode-type))

(define-private (calculate-user-global-data
  (user principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (contract-call? .pool-0-reserve-v2-0 calculate-user-global-data user assets))

(define-public (set-user-use-reserve-as-collateral
  (who principal)
  (lp-token <ft>)
  (asset <ft>)
  (enable-as-collateral bool)
  (oracle <oracle-trait>)
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (let (
    (reserve-data (try! (get-reserve-state (contract-of asset))))
    (user-data (get-user-reserve-data who (contract-of asset)))
    )
    (try! (validate-assets assets-to-calculate))
    (try! (is-approved-contract contract-caller))

    (asserts! (is-eq tx-sender who) ERR_UNAUTHORIZED)
    (asserts! (get is-active reserve-data) ERR_INACTIVE)
    (asserts! (not (get is-frozen reserve-data)) ERR_FROZEN)
    (asserts! (get usage-as-collateral-enabled reserve-data) ERR_COLLATERAL_DISABLED)
    (asserts! (is-eq (contract-of lp-token) (get a-token-address reserve-data)) ERR_INVALID_Z_TOKEN)
    (asserts! (is-eq (get oracle reserve-data) (contract-of oracle)) ERR_INVALID_ORACLE)

    (let (
      (underlying-balance (try! (contract-call? lp-token get-balance who)))
      (isolation-mode-asset (contract-call? .pool-0-reserve-v2-0 is-in-isolation-mode who))
      (user-global-data (try! (contract-call? .pool-0-reserve-v2-0 calculate-user-global-data who assets-to-calculate))))

      (asserts! (> underlying-balance u0) ERR_NOT_ZERO)

      (print { type: "set-user-use-reserve-as-collateral", payload: { key: who, data: { lp-token: lp-token, asset: asset, enable-as-collateral: enable-as-collateral } } })
      ;; if in isolation mode, can only disable isolated asset
      (match isolation-mode-asset
        isolated-asset (begin
          ;; repay before changing
          (asserts! (is-eq (get total-borrow-balanceUSD user-global-data) u0) ERR_REPAY_BEFORE_DISABLING)
          ;; if repaid, must be updating the isolated collateral asset
          (asserts! (is-eq isolated-asset (contract-of asset)) ERR_MUST_DISABLE_ISOLATED_ASSET)
          ;; if isolated asset is enabled, can only disable it
          (contract-call? .pool-0-reserve-v2-0 set-user-reserve-data who (contract-of asset) (merge user-data { use-as-collateral: false }))
        )
        (begin
          (if (not enable-as-collateral)
            ;; if disabling as collateral, check user is not using deposited collateral
            (asserts! (try! (contract-call? .pool-0-reserve-v2-0 check-balance-decrease-allowed asset oracle underlying-balance who assets-to-calculate)) ERR_INVALID_DECREASE)
            (if (> (get total-collateral-balanceUSD user-global-data) u0)
              ;; if using anything else as collateral, check it's not enabling an isolated asset
              (asserts! (not (contract-call? .pool-0-reserve-v2-0 is-isolated-type (contract-of asset))) ERR_CANNOT_ENABLE_ISOLATED_ASSET)
              ;; if enabling an asset as collateral and not using anything else as collateral, can enable any asset
              true
            )
          )
          (contract-call? .pool-0-reserve-v2-0 set-user-reserve-data who (contract-of asset) (merge user-data { use-as-collateral: enable-as-collateral }))
        )
      )
    )
  )
)

(define-read-only (get-asset-e-mode-type (asset principal))
  (contract-call? .pool-0-reserve-v2-0 get-asset-e-mode-type asset))

(define-read-only (get-user-e-mode (user principal))
  (contract-call? .pool-0-reserve-v2-0 get-user-e-mode user))

(define-read-only (is-in-e-mode (user principal))
  (contract-call? .pool-0-reserve-v2-0 is-in-e-mode user))

(define-public (init
  (a-token-address principal)
  (asset principal)
  (decimals uint)
  (supply-cap uint)
  (borrow-cap uint)
  (oracle principal)
  (interest-rate-strategy-address principal))
  (begin
    (asserts! (is-configurator tx-sender) (err u9))
    (contract-call? .pool-0-reserve-v2-0 set-reserve
      asset
      {
        last-liquidity-cumulative-index: one-8,
        current-liquidity-rate: u0,
        total-borrows-stable: u0,
        total-borrows-variable: u0,
        current-variable-borrow-rate: u0,
        current-stable-borrow-rate: u0,
        current-average-stable-borrow-rate: u0,
        last-variable-borrow-cumulative-index: one-8,
        base-ltv-as-collateral: u0,
        liquidation-threshold: u0,
        liquidation-bonus: u0,
        decimals: decimals,
        a-token-address: a-token-address,
        oracle: oracle,
        interest-rate-strategy-address: interest-rate-strategy-address,
        flashloan-enabled: false,
        last-updated-block: u0,
        borrowing-enabled: false,
        supply-cap: supply-cap,
        borrow-cap: borrow-cap,
        debt-ceiling: u0,
        accrued-to-treasury: u0,
        usage-as-collateral-enabled: false,
        is-stable-borrow-rate-enabled: false,
        is-active: true,
        is-frozen: false
      }
    )
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
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data set-reserve-state asset state)
  )
)

(define-public (set-borrowing-enabled (asset principal) (enabled bool))
  (let ((reserve-data (try! (get-reserve-state asset))))
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-0-reserve-v2-0 set-reserve asset (merge reserve-data { borrowing-enabled: enabled }))))

(define-read-only (get-reserve-state (asset principal))
  (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset))

(define-read-only (get-user-reserve-data (user principal) (asset principal))
  (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data user asset))

(define-read-only (get-borroweable-isolated)
  (contract-call? .pool-0-reserve-v2-0 get-borroweable-isolated))

(define-public (set-usage-as-collateral-enabled
  (asset principal)
  (enabled bool)
  (base-ltv-as-collateral uint)
  (liquidation-threshold uint)
  (liquidation-bonus uint))
  (let (
    (reserve-data (try! (get-reserve-state asset))))
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)

    (contract-call? .pool-0-reserve-v2-0 set-reserve
      asset
      (merge
        reserve-data
        {
          usage-as-collateral-enabled: enabled,
          base-ltv-as-collateral: base-ltv-as-collateral,
          liquidation-threshold: liquidation-threshold,
          liquidation-bonus: liquidation-bonus }))))

(define-public (add-isolated-asset (asset principal) (debt-ceiling uint))
  (let ((reserve-data (try! (get-reserve-state asset))))
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (try! (contract-call? .pool-0-reserve-v2-0 set-isolated-asset asset))
    (contract-call? .pool-0-reserve-v2-0 set-reserve asset (merge reserve-data { debt-ceiling: debt-ceiling }))
  )
)

(define-public (add-asset (asset principal))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-0-reserve-v2-0 add-asset asset)))

(define-public (remove-asset (asset principal))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-0-reserve-v2-0 remove-asset asset)))

(define-public (remove-isolated-asset (asset principal))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-0-reserve-v2-0 remove-isolated-asset asset)))

(define-public (set-borroweable-isolated (asset principal))
  (let (
    (reserve-data (get-reserve-state asset))
    (borroweable-assets (get-borroweable-isolated)))
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-0-reserve-v2-0 set-borroweable-isolated
      (unwrap-panic (as-max-len? (append borroweable-assets asset) u100)))
  )
)

(define-public (remove-borroweable-isolated (asset principal))
  (let ((borroweable-assets (get-borroweable-isolated)))
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (ok
      (contract-call? .pool-0-reserve-v2-0 set-borroweable-isolated
        (get agg (fold filter-asset borroweable-assets { filter-by: asset, agg: (list) }))))))

(define-read-only (filter-asset (asset principal) (ret { filter-by: principal, agg: (list 100 principal) }))
  (if (is-eq asset (get filter-by ret))
    ret
    { filter-by: (get filter-by ret), agg: (unwrap-panic (as-max-len? (append (get agg ret) asset) u100)) }))

(define-public (set-freeze-end-block (asset principal) (end-block uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-1 set-freeze-end-block asset end-block)
  )
)

(define-public (set-grace-period-time (asset principal) (time uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-1 set-grace-period-time asset time)
  )
)

(define-public (set-grace-period-enabled (asset principal) (enabled bool))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-1 set-grace-period-enabled asset enabled)
  )
)

(define-public (set-e-mode-type-enabled (e-mode-type (buff 1)) (enabled bool))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-2 set-e-mode-type-enabled e-mode-type enabled)
  )
)

(define-public (set-e-mode-type-config (e-mode-type (buff 1)) (ltv uint) (liquidation-threshold uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-2 set-e-mode-type-config e-mode-type {
      ltv: ltv,
      liquidation-threshold: liquidation-threshold
    })
  )
)

(define-public (set-asset-e-mode-type (asset principal) (e-mode-type (buff 1)))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-2 set-asset-e-mode-type asset e-mode-type)
  )
)


(define-public (set-base-supply-rate (asset principal) (rate uint))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (contract-call? .pool-reserve-data-2 set-base-supply-rate asset rate)
  )
)


;; for helper interface
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-configurator tx-sender) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))
  )
)

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))