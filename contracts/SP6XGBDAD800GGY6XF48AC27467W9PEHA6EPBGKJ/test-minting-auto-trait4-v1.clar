;; @contract Minting Auto Trait
;; @version 1

(use-trait ft 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.sip-010-trait.sip-010-trait)
(use-trait pyth-storage-trait 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.storage-trait)
(use-trait pyth-decoder-trait 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-traits-v2.decoder-trait)
(use-trait wormhole-core-trait 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-traits-v2.core-trait)

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait minting-auto-trait
  (
    ;;-------------------------------------
    ;; User Functions
    ;;-------------------------------------

    ;; @desc - Mint USDh using supported assets
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