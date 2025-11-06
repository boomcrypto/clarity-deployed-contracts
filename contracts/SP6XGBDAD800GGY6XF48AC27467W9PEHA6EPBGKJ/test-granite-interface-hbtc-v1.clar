;; @contract Granite Interface
;; @version 0.1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait granite-borrower .test-granite-borrower-trait-v1.granite-borrower-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_ASSET (err u109001))
(define-constant this-contract (as-contract tx-sender))
(define-constant aeusdc-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (granite-borrow
  (borrower-trait <granite-borrower>)
  (asset-trait <ft>)
  (amount uint)
  (pyth-price-feed-data (optional (buff 8192)))) 
  (let (
    (borrower-contract (contract-of borrower-trait))
    (asset (contract-of asset-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets borrower-contract none (some asset) none))
    (asserts! (is-eq asset aeusdc-token) ERR_INVALID_ASSET)
    (try! (as-contract (contract-call? borrower-trait borrow pyth-price-feed-data amount none)))
    (let (
      (remaining-balance (unwrap-panic (contract-call? asset-trait get-balance this-contract)))
    )

      (try! (as-contract (contract-call? asset-trait transfer remaining-balance this-contract .test-reserve-hbtc-v1 none)))

      (print { action: "granite-borrow", user: contract-caller, data: { borrower: borrower-contract, asset: asset, amount: amount, remaining-returned: remaining-balance } })
      (ok true)
    )
  )
)

(define-public (granite-repay
  (borrower-trait <granite-borrower>)
  (asset-trait <ft>)
  (amount uint))
  (let (
    (borrower-contract (contract-of borrower-trait))
    (asset (contract-of asset-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets borrower-contract none (some asset) none))
    (asserts! (is-eq asset aeusdc-token) ERR_INVALID_ASSET)
    (try! (contract-call? .test-reserve-hbtc-v1 transfer asset-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait repay amount none)))
    (let (
      (remaining-balance (unwrap-panic (contract-call? asset-trait get-balance this-contract)))
    )
      (if (> remaining-balance u0)
        (try! (as-contract (contract-call? asset-trait transfer remaining-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (print { action: "granite-repay", user: contract-caller, data: { borrower: borrower-contract, asset: asset, amount: amount, remaining-returned: remaining-balance } })
      (ok true)
    )
  )
)

(define-public (granite-add-collateral
  (borrower-trait <granite-borrower>)
  (collateral-trait <ft>)
  (amount uint)) 
  (let (
    (borrower-contract (contract-of borrower-trait))
    (collateral (contract-of collateral-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets borrower-contract none (some collateral) none))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer collateral-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait add-collateral collateral-trait amount none)))
    (let (
      (remaining-balance (unwrap-panic (contract-call? collateral-trait get-balance this-contract)))
    )
      (if (> remaining-balance u0)
        (try! (as-contract (contract-call? collateral-trait transfer remaining-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (print { action: "granite-add-collateral", user: contract-caller, data: { borrower: borrower-contract, collateral: collateral, amount: amount, remaining-returned: remaining-balance } })
      (ok true)
    )
  )
)

(define-public (granite-remove-collateral
  (borrower-trait <granite-borrower>)
  (collateral-trait <ft>)
  (amount uint)
  (pyth-price-feed-data (optional (buff 8192)))) 
  (let (
    (borrower-contract (contract-of borrower-trait))
    (collateral (contract-of collateral-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets borrower-contract none (some collateral) none))
    (try! (as-contract (contract-call? borrower-trait remove-collateral pyth-price-feed-data collateral-trait amount none)))
    (let (
      (remaining-balance (unwrap-panic (contract-call? collateral-trait get-balance this-contract)))
    )

      (try! (as-contract (contract-call? collateral-trait transfer remaining-balance this-contract .test-reserve-hbtc-v1 none)))

      (print { action: "granite-remove-collateral", user: contract-caller, data: { borrower: borrower-contract, collateral: collateral, amount: amount, remaining-returned: remaining-balance } })
      (ok true)
    )
  )
)