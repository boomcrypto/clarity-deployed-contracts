;; @contract Hermetica Interface
;; @version 1

(use-trait ft 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.sip-010-trait.sip-010-trait)
(use-trait pyth-storage 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.storage-trait)
(use-trait pyth-decoder 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.decoder-trait)
(use-trait wormhole-core 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-traits-v2.core-trait)
(use-trait staking .test-staking-trait-v1.staking-trait)
(use-trait staking-silo .test-staking-silo-trait-v1.staking-silo-trait)
(use-trait minting-auto .test-minting-auto-trait4-v1.minting-auto-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BALANCE_IS_ZERO (err u112001))
(define-constant ERR_INSUFFICIENT_BALANCE (err u112002))
(define-constant this-contract (as-contract tx-sender))
(define-constant usdh-base (pow u10 u8))

(define-constant reserve .test-reserve-hbtc-v1-1)
(define-constant usdh-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdh-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (hermetica-stake
  (amount uint)
  (staking-trait <staking>))
  (let (
    (ratio (unwrap-panic (contract-call? staking-trait get-usdh-per-susdh)))
    (susdh-amount (/ (* amount usdh-base) ratio))
    (contract (contract-of staking-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-connection contract))
    (try! (contract-call? .test-reserve-hbtc-v1-1 transfer usdh-token amount this-contract))
    (try! (as-contract (contract-call? staking-trait stake amount none)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 transfer susdh-amount this-contract reserve none)))
    (print { action: "hermetica-stake", user: contract-caller, data: { usdh-amount: amount, susdh-amount: susdh-amount, ratio: ratio, staking-contract: contract } })
    (ok susdh-amount)
  )
)

(define-public (hermetica-unstake
  (amount uint)
  (staking-trait <staking>))
  (let (
    (contract (contract-of staking-trait))
    (transfer-result (try! (contract-call? .test-reserve-hbtc-v1-1 transfer susdh-token amount this-contract)))
    (claim-id (try! (as-contract (contract-call? staking-trait unstake amount))))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-connection contract))

    (print { action: "hermetica-unstake", user: contract-caller, data: { susdh-amount: amount, claim-id: claim-id, staking-contract: contract } })
    (ok claim-id)
  )
)

(define-public (hermetica-withdraw
  (claim-id uint)
  (staking-silo-trait <staking-silo>))
  (let (
    (amount (get amount (unwrap-panic (contract-call? staking-silo-trait get-claim claim-id))))
    (contract (contract-of staking-silo-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-connection contract))
    (try! (as-contract (contract-call? staking-silo-trait withdraw claim-id)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer amount this-contract reserve none)))

    (print { action: "hermetica-withdraw", user: contract-caller, data: { amount: amount, claim-id: claim-id, staking-silo-contract: contract } })
    (ok amount)
  )
)

(define-public (hermetica-unstake-and-withdraw
  (amount uint)
  (staking-trait <staking>)
  (staking-silo-trait <staking-silo>))
  (let (
    (ratio (unwrap-panic (contract-call? staking-trait get-usdh-per-susdh)))
    (usdh-amount (/ (* amount ratio) usdh-base))
    (staking-contract (contract-of staking-trait))
    (staking-silo-contract (contract-of staking-silo-trait))
    (transfer-result (try! (contract-call? .test-reserve-hbtc-v1-1 transfer susdh-token amount this-contract)))
    (claim-id (try! (as-contract (contract-call? staking-trait unstake amount))))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-connections-and-assets staking-contract (some staking-silo-contract) none none))
    (try! (as-contract (contract-call? staking-silo-trait withdraw claim-id)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-amount this-contract reserve none)))
    (print { action: "hermetica-unstake-and-withdraw", user: contract-caller, data: { susdh-amount: amount, usdh-expected: usdh-amount, usdh-received: usdh-amount, ratio: ratio, staking-contract: staking-contract, staking-silo-contract: staking-silo-contract, claim-id: claim-id } })
    (ok usdh-amount)
  )
)

;;  hermetica mints convert sBTC, aeUSDC, etc. to USDh
(define-public (hermetica-mint
  (minting-auto-trait <minting-auto>)
  (minting-asset-trait <ft>)
  (amount-asset uint)
  (amount-usdh uint)
  (price-slippage-tolerance-input uint)
  (memo (optional (buff 34)))
  (price-feed-bytes (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage>,
    pyth-decoder-contract: <pyth-decoder>,
    wormhole-core-contract: <wormhole-core>
  })
)
  (let (
    (minting-contract (contract-of minting-auto-trait))
    (minting-asset (contract-of minting-asset-trait))
    (minting-asset-data (contract-call? .test-state-hbtc-v1-1 get-trading-asset minting-asset))
    (max-slippage (get max-slippage minting-asset-data))
    (price-slippage-tolerance (if (< max-slippage price-slippage-tolerance-input) max-slippage price-slippage-tolerance-input))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-connections-and-assets minting-contract none (some minting-asset) none))
    (try! (contract-call? .test-reserve-hbtc-v1-1 transfer minting-asset-trait amount-asset this-contract))
    (try! (as-contract (contract-call? minting-auto-trait mint minting-asset-trait amount-usdh price-slippage-tolerance memo price-feed-bytes execution-plan)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer amount-usdh this-contract reserve none)))
    (print { action: "hermetica-mint", user: contract-caller, data: { minting-asset: minting-asset, amount-asset: amount-asset, usdh-received: amount-usdh, minting-contract: minting-contract } })
    (ok amount-usdh)
  )
)

;;  hermetica redeems can be used to convert USDh to sBTC, aeUSDC, etc.
(define-public (hermetica-redeem
  (minting-auto-trait <minting-auto>)
  (redeeming-asset-trait <ft>)
  (amount-usdh uint)
  (price-slippage-tolerance-input uint)
  (memo (optional (buff 34)))
  (price-feed-bytes (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage>,
    pyth-decoder-contract: <pyth-decoder>,
    wormhole-core-contract: <wormhole-core>
  }))
  (let (
    (minting-contract (contract-of minting-auto-trait))
    (redeeming-asset (contract-of redeeming-asset-trait))
    (redeeming-asset-data (contract-call? .test-state-hbtc-v1-1 get-trading-asset redeeming-asset))
    (max-slippage (get max-slippage redeeming-asset-data))
    (price-slippage-tolerance (if (< max-slippage price-slippage-tolerance-input) max-slippage price-slippage-tolerance-input))
    (initial-asset-balance (unwrap-panic (contract-call? redeeming-asset-trait get-balance this-contract)))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-connections-and-assets minting-contract none (some redeeming-asset) none))    
    (try! (contract-call? .test-reserve-hbtc-v1-1 transfer usdh-token amount-usdh this-contract))
    (try! (as-contract (contract-call? minting-auto-trait redeem redeeming-asset-trait amount-usdh price-slippage-tolerance memo price-feed-bytes execution-plan)))
    (let (
      (new-asset-balance (unwrap-panic (contract-call? redeeming-asset-trait get-balance this-contract)))
      (asset-received (- new-asset-balance initial-asset-balance))
    )
      (try! (as-contract (contract-call? redeeming-asset-trait transfer asset-received this-contract reserve none)))
      (print { action: "hermetica-redeem", user: contract-caller, data: { redeeming-asset: redeeming-asset, amount-usdh: amount-usdh, asset-received: asset-received, minting-contract: minting-contract } })
      (ok asset-received)
    )
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
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-trading-asset asset))
    (asserts! (> amount u0) ERR_BALANCE_IS_ZERO)
    (asserts! (<= amount balance) ERR_INSUFFICIENT_BALANCE)
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "sweep", user: contract-caller, data: { asset: asset, amount: amount, sender: this-contract, recipient: reserve } })
    (ok amount)
  )
)