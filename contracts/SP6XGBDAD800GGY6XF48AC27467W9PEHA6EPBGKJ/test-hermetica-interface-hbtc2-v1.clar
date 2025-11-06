;; @contract Hermetica Interface
;; @version 1

(use-trait ft 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.sip-010-trait.sip-010-trait)
(use-trait pyth-storage 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-traits-v1.core-trait)
(use-trait staking .test-staking-trait-v1.staking-trait)
(use-trait staking-silo .test-staking-silo-trait-v1.staking-silo-trait)
(use-trait minting-auto .test-minting-auto-trait2-v1.minting-auto-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant this-contract (as-contract tx-sender))
(define-constant usdh-base (pow u10 u8))

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
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-connection contract))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 amount this-contract))
    (try! (as-contract (contract-call? staking-trait stake amount none)))
    (let (
      (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
      (susdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 get-balance this-contract)))
    )
      (if (> usdh-balance u0)
        (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )

      (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 transfer susdh-balance this-contract .test-reserve-hbtc-v1 none)))

      (print { action: "hermetica-stake", user: contract-caller, data: { usdh-amount: amount, susdh-expected: susdh-amount, susdh-returned: susdh-balance, usdh-returned: usdh-balance, ratio: ratio, staking-contract: contract } })  
      (ok true)
    )
  )
)

(define-public (hermetica-unstake
  (amount uint)
  (staking-trait <staking>))
  (let (
    (contract (contract-of staking-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-connection contract))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 amount this-contract))
    (try! (as-contract (contract-call? staking-trait unstake amount)))
    (let (
      (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
      (susdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 get-balance this-contract)))
    )
      (if (> usdh-balance u0)
        (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (if (> susdh-balance u0)
        (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 transfer susdh-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (print { action: "hermetica-unstake", user: contract-caller, data: { susdh-amount: amount, usdh-returned: usdh-balance, susdh-returned: susdh-balance, staking-contract: contract } })
      (ok true)
    )
  )
)

(define-public (hermetica-withdraw
  (claim-id uint)
  (staking-silo-trait <staking-silo>))
  (let (
    (amount (get amount (unwrap-panic (contract-call? staking-silo-trait get-claim claim-id))))
    (contract (contract-of staking-silo-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-connection contract))
    (try! (as-contract (contract-call? staking-silo-trait withdraw claim-id)))
    (let (
      (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
    )

      (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))

      (print { action: "hermetica-withdraw", user: contract-caller, data: { amount: amount, usdh-returned: usdh-balance, claim-id: claim-id, staking-silo-contract: contract } })
      (ok true)
    )
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
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets staking-contract (some staking-silo-contract) none none))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 amount this-contract))
    (let (
      (claim-id (try! (as-contract (contract-call? staking-trait unstake amount))))
    )
      (try! (contract-call? staking-silo-trait withdraw claim-id))
      (let (
        (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
        (susdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 get-balance this-contract)))
      )
        (if (> susdh-balance u0)
          (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 transfer susdh-balance this-contract .test-reserve-hbtc-v1 none)))
          true
        )

        (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "hermetica-unstake-and-withdraw", user: contract-caller, data: { susdh-amount: amount, usdh-expected: usdh-amount, usdh-returned: usdh-balance, susdh-returned: susdh-balance, ratio: ratio, staking-contract: staking-contract, staking-silo-contract: staking-silo-contract, claim-id: claim-id } })
        (ok true)
      )
    )
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
    (minting-asset-data (contract-call? .test-state-hbtc-v1 get-trading-asset minting-asset))
    (max-slippage (get max-slippage minting-asset-data))
    (price-slippage-tolerance (if (< max-slippage price-slippage-tolerance-input) max-slippage price-slippage-tolerance-input))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets minting-contract none (some minting-asset) none))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer minting-asset-trait amount-asset this-contract))
    (try! (as-contract (contract-call? minting-auto-trait mint minting-asset-trait amount-usdh price-slippage-tolerance memo price-feed-bytes execution-plan)))
    (let (
      (asset-balance (unwrap-panic (contract-call? minting-asset-trait get-balance this-contract)))
      (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
    )
      (if (> asset-balance u0)
        (try! (as-contract (contract-call? minting-asset-trait transfer asset-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))
      (print { action: "hermetica-mint", user: contract-caller, data: { minting-asset: minting-asset, amount-asset: amount-asset, amount-usdh-expected: amount-usdh, usdh-returned: usdh-balance, asset-returned: asset-balance, minting-contract: minting-contract } })
      (ok true)
    )
  )
)

;;  hermetica redeems can be used to convert USDh to sBTC, aeUSDC, etc.
(define-public (hermetica-redeem
  (minting-auto-trait <minting-auto>)
  (redeeming-asset-trait <ft>)
  (amount-asset uint)
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
    (redeeming-asset-data (contract-call? .test-state-hbtc-v1 get-trading-asset redeeming-asset))
    (max-slippage (get max-slippage redeeming-asset-data))
    (price-slippage-tolerance (if (< max-slippage price-slippage-tolerance-input) max-slippage price-slippage-tolerance-input))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets minting-contract none (some redeeming-asset) none))    
    (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 amount-usdh this-contract))
    (try! (as-contract (contract-call? minting-auto-trait redeem redeeming-asset-trait amount-usdh price-slippage-tolerance memo price-feed-bytes execution-plan)))
    (let (
      (usdh-balance (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance this-contract)))
      (asset-balance (unwrap-panic (contract-call? redeeming-asset-trait get-balance this-contract)))
    )
      (if (> usdh-balance u0)
        (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-balance this-contract .test-reserve-hbtc-v1 none)))
        true
      )
      (try! (as-contract (contract-call? redeeming-asset-trait transfer asset-balance this-contract .test-reserve-hbtc-v1 none)))
      (print { action: "hermetica-redeem", user: contract-caller, data: { redeeming-asset: redeeming-asset, amount-usdh: amount-usdh, amount-asset-expected: amount-asset, asset-returned: asset-balance, usdh-returned: usdh-balance, minting-contract: minting-contract } })
      (ok true)
    )
  )
)