;; @contract Granite Interface
;; @version 0.1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait granite-borrower .test-granite-borrower-trait-v1.granite-borrower-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_ASSET (err u112001))
(define-constant ERR_INVALID_AMOUNT (err u112002))
(define-constant ERR_INSUFFICIENT_BALANCE (err u112003))

(define-constant this-contract (as-contract tx-sender))
(define-constant aeusdc-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant reserve .test-reserve-hbtc-v3)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (granite-borrow
  (borrower-trait <granite-borrower>)
  (asset-trait <ft>)
  (amount uint)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192)))) 
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrower-trait) none (some (contract-of asset-trait)) none))
    (asserts! (is-eq (contract-of asset-trait) aeusdc-token) ERR_INVALID_ASSET)
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (try! (as-contract (contract-call? borrower-trait borrow none amount none)))
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "granite-borrow", user: contract-caller, data: { borrower: borrower-trait, asset: asset-trait, amount: amount } })
    (ok true)
  )
)

(define-public (granite-repay
  (borrower-trait <granite-borrower>)
  (asset-trait <ft>)
  (amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrower-trait) none (some (contract-of asset-trait)) none))
    (asserts! (is-eq (contract-of asset-trait) aeusdc-token) ERR_INVALID_ASSET)
    (try! (contract-call? .test-reserve-hbtc-v3 transfer asset-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait repay amount none)))
    (print { action: "granite-repay", user: contract-caller, data: { borrower: borrower-trait, asset: asset-trait, amount: amount } })
    (ok true)
  )
)

(define-public (granite-add-collateral
  (borrower-trait <granite-borrower>)
  (collateral-trait <ft>)
  (amount uint)) 
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrower-trait) none (some (contract-of collateral-trait)) none))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer collateral-trait amount this-contract))
    (try! (as-contract (contract-call? borrower-trait add-collateral collateral-trait amount none)))
    (print { action: "granite-add-collateral", user: contract-caller, data: { borrower: borrower-trait, collateral: collateral-trait, amount: amount } })
    (ok true)
  )
)

(define-public (granite-remove-collateral
  (borrower-trait <granite-borrower>)
  (collateral-trait <ft>)
  (amount uint)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrower-trait) none (some (contract-of collateral-trait)) none))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (try! (as-contract (contract-call? borrower-trait remove-collateral none collateral-trait amount none)))
    (try! (as-contract (contract-call? collateral-trait transfer amount this-contract reserve none)))
    (print { action: "granite-remove-collateral", user: contract-caller, data: { borrower: borrower-trait, collateral: collateral-trait, amount: amount } })
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

;; @desc - sweeps any leftover tokens from interface contract to reserve
;; @param - asset-trait: the token to sweep
;; @param - amount: the amount to sweep
(define-public (sweep (asset-trait <ft>) (amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-asset (contract-of asset-trait)))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= amount (unwrap-panic (contract-call? asset-trait get-balance this-contract))) ERR_INSUFFICIENT_BALANCE)
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "sweep", user: contract-caller, data: { asset: asset-trait, amount: amount, sender: this-contract, recipient: reserve } })
    (ok amount)
  )
)

;;-------------------------------------
;; Helper
;;-------------------------------------

(define-private (write-feed (price-feed (optional (buff 8192))))
  (match price-feed bytes 
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