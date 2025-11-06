;; @contract Granite Interface
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait granite-borrower .test-granite-borrower-trait-v1.granite-borrower-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_ASSET (err u109001))
(define-constant ERR_BALANCE_IS_ZERO (err u109002))
(define-constant ERR_INSUFFICIENT_BALANCE (err u109003))
(define-constant this-contract (as-contract tx-sender))
(define-constant aeusdc-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (granite-borrow
  (borrower-trait <granite-borrower>)
  (asset-trait <ft>)
  (amount uint)
  (price-feed-bytes1 (optional (buff 8192)))
  (price-feed-bytes2 (optional (buff 8192)))) 
  (let (
    (borrower-contract (contract-of borrower-trait))
    (asset (contract-of asset-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc2-v1 check-connections-and-assets borrower-contract none (some asset) none))
    (asserts! (is-eq asset aeusdc-token) ERR_INVALID_ASSET)
    (try! (write-feed price-feed-bytes1))
    (try! (write-feed price-feed-bytes2))
    (try! (as-contract (contract-call? borrower-trait borrow none amount none)))
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract .test-reserve-hbtc2-v1 none)))
    (print { action: "granite-borrow", user: contract-caller, data: { borrower: borrower-contract, asset: asset, amount: amount } })
      (ok true)
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
    (try! (contract-call? .test-state-hbtc2-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc2-v1 check-connections-and-assets borrower-contract none (some asset) none))
    (asserts! (is-eq asset aeusdc-token) ERR_INVALID_ASSET)
    (try! (contract-call? .test-reserve-hbtc2-v1 transfer asset-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait repay amount none)))
    (print { action: "granite-repay", user: contract-caller, data: { borrower: borrower-contract, asset: asset, amount: amount } })
    (ok true)
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
    (try! (contract-call? .test-state-hbtc2-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc2-v1 check-connections-and-assets borrower-contract none (some collateral) none))
    (try! (contract-call? .test-reserve-hbtc2-v1 transfer collateral-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait add-collateral collateral-trait amount none)))
    (print { action: "granite-add-collateral", user: contract-caller, data: { borrower: borrower-contract, collateral: collateral, amount: amount } })
    (ok true)
  )
)

(define-public (granite-remove-collateral
  (borrower-trait <granite-borrower>)
  (collateral-trait <ft>)
  (amount uint)
  (price-feed-bytes1 (optional (buff 8192)))
  (price-feed-bytes2 (optional (buff 8192)))) 
  (let (
    (borrower-contract (contract-of borrower-trait))
    (collateral (contract-of collateral-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc2-v1 check-connections-and-assets borrower-contract none (some collateral) none))
    (try! (write-feed price-feed-bytes1))
    (try! (write-feed price-feed-bytes2))
    (try! (as-contract (contract-call? borrower-trait remove-collateral none collateral-trait amount none)))
    (try! (as-contract (contract-call? collateral-trait transfer amount this-contract .test-reserve-hbtc2-v1 none)))
    (print { action: "granite-remove-collateral", user: contract-caller, data: { borrower: borrower-contract, collateral: collateral, amount: amount } })
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (sweep (asset-trait <ft>) (amount uint))
  (let (
    (asset (contract-of asset-trait))
    (balance (unwrap-panic (contract-call? asset-trait get-balance this-contract)))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-trading-asset asset))
    (asserts! (> amount u0) ERR_BALANCE_IS_ZERO)
    (asserts! (<= amount balance) ERR_INSUFFICIENT_BALANCE)
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract .test-reserve-hbtc2-v1 none)))
    (print { action: "sweep", user: contract-caller, data: { asset: asset, amount: amount, sender: this-contract, recipient: .test-reserve-hbtc2-v1 } })
    (ok amount)
  )
)

;;-------------------------------------
;; Helper
;;-------------------------------------

(define-private (write-feed (price-feed-bytes (optional (buff 8192))))
  (match price-feed-bytes bytes 
    (begin
      (try! (contract-call? 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-oracle-v4 verify-and-update-price-feeds
        bytes
        {
          pyth-storage-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-storage-v4,
          pyth-decoder-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-pnau-decoder-v3,
          wormhole-core-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-core-v4,
        }
      ))
      (ok true)
    )
    ;; do nothing if none
    (ok true)
  )
)