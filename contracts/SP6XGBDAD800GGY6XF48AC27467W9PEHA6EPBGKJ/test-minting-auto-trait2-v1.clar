;; @contract MintingAutoTrait
;; @version 1.0
;; @description Trait contract for minting auto functionality

(use-trait ft 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.sip-010-trait.sip-010-trait)
(use-trait pyth-storage-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-traits-v1.core-trait)

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait minting-auto-trait
  (
    ;;-------------------------------------
    ;; User Functions
    ;;-------------------------------------

    ;; @desc - Mint USDh using supported assets
    ;; @param - minting-asset: SIP-010 trait of the minting asset
    ;; @param - amount-usdh-requested: amount of USDh to mint (10**8)
    ;; @param - price-slippage-tolerance: slippage tolerance in basis points
    ;; @param - memo: optional memo for the transfer call
    ;; @param - price-feed-bytes: optional Pyth price feed data
    ;; @param - execution-plan: Pyth contracts configuration
    ;; @return - (ok bool) on success, (err uint) on failure
    (mint 
      (
        <ft> 
        uint 
        uint 
        (optional (buff 34))
        (optional (buff 8192))
        {
          pyth-storage-contract: <pyth-storage-trait>,
          pyth-decoder-contract: <pyth-decoder-trait>,
          wormhole-core-contract: <wormhole-core-trait>
        }
      ) 
      (response bool uint)
    )

    ;; @desc - Redeem USDh for supported assets
    ;; @param - redeeming-asset: SIP-010 trait of the redeeming asset
    ;; @param - amount-usdh-requested: amount of USDh to redeem (10**8)
    ;; @param - price-slippage-tolerance: slippage tolerance in basis points
    ;; @param - memo: optional memo for the transfer call
    ;; @param - price-feed-bytes: optional Pyth price feed data
    ;; @param - execution-plan: Pyth contracts configuration
    ;; @return - (ok bool) on success, (err uint) on failure
    (redeem 
      (
        <ft> 
        uint 
        uint 
        (optional (buff 34))
        (optional (buff 8192))
        {
          pyth-storage-contract: <pyth-storage-trait>,
          pyth-decoder-contract: <pyth-decoder-trait>,
          wormhole-core-contract: <wormhole-core-trait>
        }
      ) 
      (response bool uint)
    )
  )
)