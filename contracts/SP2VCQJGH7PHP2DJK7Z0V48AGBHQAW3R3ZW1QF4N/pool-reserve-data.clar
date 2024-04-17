(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-constant one-8 (contract-call? .math get-one))
(define-constant max-value (contract-call? .math get-max-value))

(define-constant ERR_UNAUTHORIZED (err u7000))

(define-map flashloan-fee-total principal uint)
(define-public (set-flashloan-fee-total (asset principal) (fee uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-flashloan-fee-total", payload: { key: asset, data: { fee: fee } } })
    (ok (map-set flashloan-fee-total asset fee))))

(define-public (get-flashloan-fee-total (asset principal))
  (ok (map-get? flashloan-fee-total asset)))
(define-read-only (get-flashloan-fee-total-read (asset principal))
  (map-get? flashloan-fee-total asset))

(define-map flashloan-fee-protocol principal uint)
(define-public (set-flashloan-fee-protocol (asset principal) (fee uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-flashloan-fee-protocol", payload: { key: asset, data: { fee: fee } } })
    (ok (map-set flashloan-fee-protocol asset fee))))

(define-public (get-flashloan-fee-protocol (asset principal))
  (ok (map-get? flashloan-fee-protocol asset)))
(define-read-only (get-flashloan-fee-protocol-read (asset principal))
  (map-get? flashloan-fee-protocol asset))

(define-data-var health-factor-liquidation-threshold uint u100000000)
(define-public (set-health-factor-liquidation-threshold (hf uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-health-factor-liquidation-threshold", payload: { key: "hf", data: { hf: hf } } })
    (ok (var-set health-factor-liquidation-threshold hf))))

(define-public (get-health-factor-liquidation-threshold)
  (ok (var-get health-factor-liquidation-threshold)))
(define-read-only (get-health-factor-liquidation-threshold-read)
  (var-get health-factor-liquidation-threshold))

;; (define-data-var protocol-treasury-addr principal 'ST2ZW2EKBWATT2Z7FZ2XY9KYYVFBYBDCZBRZMFNR9)
(define-data-var protocol-treasury-addr principal 'SP1ZRM218P3CVZ94YNRBY375AG4VWAY2J1RHZH8BW)

(define-public (set-protocol-treasury-addr (protocol-treasury principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-protocol-treasury-addr", payload: { key: "protocol-treasury", data: { protocol-treasury: protocol-treasury } } })
    (ok (var-set protocol-treasury-addr protocol-treasury))))

(define-public (get-protocol-treasury-addr)
  (ok (var-get protocol-treasury-addr)))
(define-read-only (get-protocol-treasury-addr-read)
  (var-get protocol-treasury-addr))

(define-data-var reserve-vault principal .pool-vault)
(define-public (set-reserve-vault (new-reserve-vault principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-reserve-vault", payload: { key: "reserve-vault", data: { new-reserve-vault: new-reserve-vault } } })
    (ok (var-set reserve-vault new-reserve-vault))))

(define-public (get-reserve-vault)
  (ok (var-get reserve-vault)))
(define-read-only (get-reserve-vault-read)
  (var-get reserve-vault))

(define-map user-reserve-data
  { user: principal, reserve: principal}
  (tuple
    (principal-borrow-balance uint)
    (last-variable-borrow-cumulative-index uint)
    (origination-fee uint)
    (stable-borrow-rate uint)
    (last-updated-block uint)
    (use-as-collateral bool)))

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
    (try! (is-approved-contract contract-caller))
    (print { type: "set-user-reserve-data", payload: { key: { user: user, reserve: reserve }, data: data } })
    (ok (map-set user-reserve-data { user:user, reserve: reserve } data))))

(define-public (delete-user-reserve-data
  (user principal)
  (reserve principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "delete-user-reserve-data", payload: { key: { user: user, reserve: reserve }, data: none } })
    (ok (map-delete user-reserve-data { user:user, reserve: reserve }))))

(define-read-only (get-user-reserve-data
  (user principal)
  (reserve principal))
  (ok (map-get? user-reserve-data { user: user, reserve: reserve }))
)
(define-read-only (get-user-reserve-data-read
  (user principal)
  (reserve principal))
  (map-get? user-reserve-data { user: user, reserve: reserve }))

(define-map user-assets principal
  { assets-supplied: (list 100 principal), assets-borrowed: (list 100 principal)})
(define-public (set-user-assets
  (user principal)
  (data
    (tuple 
      (assets-supplied (list 100 principal))
      (assets-borrowed (list 100 principal)))))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-user-assets", payload: { key: user, data: data } })
    (ok (map-set user-assets user data))))
(define-public (delete-user-assets
  (user principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "delete-user-assets", payload: { key: user, data: none } })
    (ok (map-delete user-assets user))))

(define-public (get-user-assets
  (user principal))
  (ok (map-get? user-assets user)))
(define-read-only (get-user-assets-read
  (user principal))
  (map-get? user-assets user))

(define-map reserve-state
  principal
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
    (is-frozen bool)))

(define-public (set-reserve-state
  (reserve principal)
  (data
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
    (is-frozen bool))))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-reserve-state", payload: { key: reserve, data: data } })
    (ok (map-set reserve-state reserve data))))

(define-public (delete-reserve-state
  (reserve principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "delete-reserve-state", payload: { key: reserve, data: none } })
    (ok (map-delete reserve-state reserve))))

(define-public (get-reserve-state
  (reserve principal))
  (ok (map-get? reserve-state reserve)))
(define-read-only (get-reserve-state-read
  (reserve principal))
  (map-get? reserve-state reserve))

(define-map user-index { user: principal, asset: principal } uint)
(define-public (set-user-index
  (user principal)
  (asset principal)
  (data uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-user-index", payload: { key: user, data: data } })
    (ok (map-set user-index { user: user, asset: asset } data))))
(define-public (delete-user-index
  (user principal)
  (asset principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "delete-user-index", payload: { key: user, data: none } })
    (ok (map-delete user-index { user: user, asset: asset }))))

(define-public (get-user-index
  (user principal)
  (asset principal)
  )
    (ok (map-get? user-index { user: user, asset: asset })))
(define-read-only (get-user-index-read
  (user principal)
  (asset principal))
  (map-get? user-index { user: user, asset: asset }))

(define-data-var assets (list 100 principal) (list))
(define-public (set-assets
  (data (list 100 principal)))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-assets", payload: { key: "assets", data: data } })
    (ok (var-set assets data))))

(define-public (get-assets)
    (ok (var-get assets)))
(define-read-only (get-assets-read)
    (var-get assets))

(define-map isolated-assets principal bool)
(define-public (set-isolated-assets
  (reserve principal)
  (data bool))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-isolated-assets", payload: { key: reserve, data: data } })
    (ok (map-set isolated-assets reserve data))))
(define-public (delete-isolated-assets
  (reserve principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "delete-isolated-assets", payload: { key: reserve, data: none } })
    (ok (map-delete isolated-assets reserve))))

(define-public (get-isolated-assets
  (reserve principal))
  (ok (map-get? isolated-assets reserve)))
(define-read-only (get-isolated-assets-read
  (reserve principal))
  (map-get? isolated-assets reserve))

;; Assets that can be borrowed using isolated assets as collateral
(define-data-var borroweable-isolated (list 100 principal) (list))
(define-public (set-borroweable-isolated
  (data (list 100 principal)))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-borroweable-isolated", payload: { key: "borroweable-isolated", data: data } })
    (ok (var-set borroweable-isolated data))))

(define-public (get-borroweable-isolated)
    (ok (var-get borroweable-isolated)))
(define-read-only (get-borroweable-isolated-read)
    (var-get borroweable-isolated))


(define-map optimal-utilization-rates principal uint)
(define-public (set-optimal-utilization-rate (asset principal) (rate uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-optimal-utilization-rate", payload: { key: asset, data: rate } })
    (ok (map-set optimal-utilization-rates asset rate))))

(define-public (get-optimal-utilization-rate (asset principal))
  (ok (map-get? optimal-utilization-rates asset)))
(define-read-only (get-optimal-utilization-rate-read (asset principal))
  (map-get? optimal-utilization-rates asset))

(define-map base-variable-borrow-rates principal uint)
(define-public (set-base-variable-borrow-rate (asset principal) (rate uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-base-variable-borrow-rate", payload: { key: asset, data: rate } })
    (ok (map-set base-variable-borrow-rates asset rate))))

(define-public (get-base-variable-borrow-rate (asset principal))
  (ok (map-get? base-variable-borrow-rates asset)))
(define-read-only (get-base-variable-borrow-rate-read (asset principal))
  (map-get? base-variable-borrow-rates asset))

(define-map variable-rate-slopes-1 principal uint)
(define-public (set-variable-rate-slope-1 (asset principal) (rate uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-variable-rate-slope-1", payload: { key: asset, data: rate } })
    (ok (map-set variable-rate-slopes-1 asset rate))))

(define-public (get-variable-rate-slope-1 (asset principal))
  (ok (map-get? variable-rate-slopes-1 asset)))
(define-read-only (get-variable-rate-slope-1-read (asset principal))
  (map-get? variable-rate-slopes-1 asset))

(define-map variable-rate-slopes-2 principal uint)
(define-public (set-variable-rate-slope-2 (asset principal) (rate uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-variable-rate-slope-2", payload: { key: asset, data: rate } })
    (ok (map-set variable-rate-slopes-2 asset rate))))

(define-public (get-variable-rate-slope-2 (asset principal))
  (ok (map-get? variable-rate-slopes-2 asset)))
(define-read-only (get-variable-rate-slope-2-read (asset principal))
  (map-get? variable-rate-slopes-2 asset))

(define-map liquidation-close-factor-percent principal uint)
(define-public (set-liquidation-close-factor-percent (asset principal) (rate uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-liquidation-close-factor-percent", payload: { key: asset, data: rate } })
    (ok (map-set liquidation-close-factor-percent asset rate))))

(define-public (get-liquidation-close-factor-percent (asset principal))
  (ok (map-get? liquidation-close-factor-percent asset)))
(define-read-only (get-liquidation-close-factor-percent-read (asset principal))
  (map-get? liquidation-close-factor-percent asset))

(define-map origination-fee-prc principal uint)
(define-public (set-origination-fee-prc (asset principal) (prc uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-origination-fee-prc", payload: { key: asset, data: prc } })
    (ok (map-set origination-fee-prc asset prc))))

(define-public (get-origination-fee-prc (asset principal))
  (ok (map-get? origination-fee-prc asset)))
(define-read-only (get-origination-fee-prc-read (asset principal))
  (map-get? origination-fee-prc asset))

(define-map reserve-factor principal uint)
(define-public (set-reserve-factor (asset principal) (factor uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (print { type: "set-reserve-factor", payload: { key: asset, data: factor } })
    (ok (map-set reserve-factor asset factor))))

(define-public (get-reserve-factor (asset principal))
  (ok (map-get? reserve-factor asset)))
(define-read-only (get-reserve-factor-read (asset principal))
  (map-get? reserve-factor asset))

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-reserve-data", payload: owner })
    (ok (var-set contract-owner owner))))

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))
(define-read-only (get-contract-owner-read)
  (var-get contract-owner))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))))

(define-public (delete-approved-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-delete approved-contracts contract))))

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

(map-set approved-contracts .pool-borrow true)
(map-set approved-contracts .pool-0-reserve true)
