;; @contract Hermetica Interface
;; @version 0.1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait pyth-storage 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.storage-trait)
(use-trait pyth-decoder 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.decoder-trait)
(use-trait wormhole-core 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-traits-v2.core-trait)
(use-trait staking 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-trait-v1.staking-trait)
(use-trait staking-silo 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-silo-trait-v1.staking-silo-trait)
(use-trait minting-auto 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.minting-auto-trait-v1.minting-auto-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u110001))
(define-constant ERR_INSUFFICIENT_BALANCE (err u110002))

(define-constant this-contract (as-contract tx-sender))
(define-constant usdh-base (pow u10 u8))

(define-constant reserve .test-reserve-hbtc-v3)
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
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of staking-trait) none none none))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer usdh-token amount this-contract))
    (try! (as-contract (contract-call? staking-trait stake amount none)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 transfer susdh-amount this-contract reserve none)))
    (print { action: "hermetica-stake", user: contract-caller, data: { usdh-amount: amount, susdh-amount: susdh-amount, ratio: ratio, staking: staking-trait } })
    (ok susdh-amount)
  )
)

(define-public (hermetica-unstake
  (amount uint)
  (staking-trait <staking>))
  (let (
    (transfer-result (try! (contract-call? .test-reserve-hbtc-v3 transfer susdh-token amount this-contract)))
    (claim-id (try! (as-contract (contract-call? staking-trait unstake amount))))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of staking-trait) none none none))
    (print { action: "hermetica-unstake", user: contract-caller, data: { susdh-amount: amount, claim-id: claim-id, staking: staking-trait } })
    (ok claim-id)
  )
)

(define-public (hermetica-withdraw
  (claim-id uint)
  (staking-silo-trait <staking-silo>))
  (let (
    (amount (get amount (unwrap-panic (contract-call? staking-silo-trait get-claim claim-id))))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of staking-silo-trait) none none none))
    (try! (as-contract (contract-call? staking-silo-trait withdraw claim-id)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer amount this-contract reserve none)))
    (print { action: "hermetica-withdraw", user: contract-caller, data: { amount: amount, claim-id: claim-id, staking-silo: staking-silo-trait } })
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
    (transfer-result (try! (contract-call? .test-reserve-hbtc-v3 transfer susdh-token amount this-contract)))
    (claim-id (try! (as-contract (contract-call? staking-trait unstake amount))))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of staking-trait) (some (contract-of staking-silo-trait)) none none))
    (try! (as-contract (contract-call? staking-silo-trait withdraw claim-id)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer usdh-amount this-contract reserve none)))
    (print { action: "hermetica-unstake-and-withdraw", user: contract-caller, data: { susdh-amount: amount, usdh-expected: usdh-amount, usdh-received: usdh-amount, ratio: ratio, staking: staking-trait, staking-silo: staking-silo-trait, claim-id: claim-id } })
    (ok usdh-amount)
  )
)

;;  hermetica mints convert sBTC, aeUSDC, etc. to USDh
(define-public (hermetica-mint
  (minting-auto-trait <minting-auto>)
  (minting-asset-trait <ft>)
  (amount-asset uint)
  (amount-usdh uint)
  (slippage-tolerance-input uint)
  (memo (optional (buff 34)))
  (price-feed (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage>,
    pyth-decoder-contract: <pyth-decoder>,
    wormhole-core-contract: <wormhole-core>
  })
)
  (let (
    (minting-asset-data (contract-call? .test-state-hbtc-v3 get-asset (contract-of minting-asset-trait)))
    (max-slippage (get max-slippage minting-asset-data))
    (slippage-tolerance (if (< max-slippage slippage-tolerance-input) max-slippage slippage-tolerance-input))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of minting-auto-trait) none (some (contract-of minting-asset-trait)) none))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer minting-asset-trait amount-asset this-contract))
    (try! (as-contract (contract-call? minting-auto-trait mint minting-asset-trait amount-usdh slippage-tolerance memo price-feed execution-plan)))
    (try! (as-contract (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 transfer amount-usdh this-contract reserve none)))
    (print { action: "hermetica-mint", user: contract-caller, data: { minting-asset: minting-asset-trait, amount-asset: amount-asset, usdh-received: amount-usdh, minting-contract: minting-auto-trait } })
    (ok amount-usdh)
  )
)

;;  hermetica redeems can be used to convert USDh to sBTC, aeUSDC, etc.
(define-public (hermetica-redeem
  (minting-auto-trait <minting-auto>)
  (redeeming-asset-trait <ft>)
  (amount-usdh uint)
  (slippage-tolerance-input uint)
  (memo (optional (buff 34)))
  (price-feed (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage>,
    pyth-decoder-contract: <pyth-decoder>,
    wormhole-core-contract: <wormhole-core>
  }))
  (let (
    (redeeming-asset-data (contract-call? .test-state-hbtc-v3 get-asset (contract-of redeeming-asset-trait)))
    (max-slippage (get max-slippage redeeming-asset-data))
    (slippage-tolerance (if (< max-slippage slippage-tolerance-input) max-slippage slippage-tolerance-input))
    (initial-asset-balance (unwrap-panic (contract-call? redeeming-asset-trait get-balance this-contract)))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of minting-auto-trait) none (some (contract-of redeeming-asset-trait)) none))    
    (try! (contract-call? .test-reserve-hbtc-v3 transfer usdh-token amount-usdh this-contract))
    (try! (as-contract (contract-call? minting-auto-trait redeem redeeming-asset-trait amount-usdh slippage-tolerance memo price-feed execution-plan)))
    (let (
      (new-asset-balance (unwrap-panic (contract-call? redeeming-asset-trait get-balance this-contract)))
      (asset-received (- new-asset-balance initial-asset-balance))
    )
      (try! (as-contract (contract-call? redeeming-asset-trait transfer asset-received this-contract reserve none)))
      (print { action: "hermetica-redeem", user: contract-caller, data: { redeeming-asset: redeeming-asset-trait, amount-usdh: amount-usdh, asset-received: asset-received, minting-contract: minting-auto-trait } })
      (ok asset-received)
    )
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