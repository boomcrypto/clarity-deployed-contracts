(define-constant CONTRACT_OWNER tx-sender)
(define-constant COST-OF-BENJAMIN-NFT u100)

(define-constant ERR_READING_SBTC_BALANCE (err u7001))
(define-constant ERR_NOT_ENOUGH_SBTC (err u7002))
(define-constant ERR_NOT_OWNER (err u7003))

(define-public (join-the-benjamin-club (price-feed-bytes (buff 8192)))
  (let (
      ;; Update & verify VAA for BTC price feed
      (update-status (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3
        verify-and-update-price-feeds price-feed-bytes {
        pyth-storage-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3,
        pyth-decoder-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2,
        wormhole-core-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3,
      })))
      ;; Get fresh BTC price
      (price-data (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3
        get-price
        ;; The official BTC price feed id.
        0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43
        'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3
      )))
      ;; Adjust price and get user sBTC balance
      ;; Price feeds represent numbers in a fixed-point format. The expo property tells us
      ;; at what certain position is the decimal point implicity fixed.
      (price-denomination (pow 10 (* (get expo price-data) -1)))
      ;; We'll adjust the price to its normal decimal representation.
      (adjusted-price (to-uint (/ (get price price-data) price-denomination)))
      ;; Get the user's current sBTC balance.
      (user-sbtc-balance (unwrap!
        (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          get-balance-available tx-sender
        )
        ERR_READING_SBTC_BALANCE
      ))
    )
    ;; Determine if the user has at least $100 worth of sBTC to join the Benjamin Club and mint NFT
    (if (> (/ (* user-sbtc-balance adjusted-price) (to-uint price-denomination))
        COST-OF-BENJAMIN-NFT
      )
      (let ((hundred-dollars-in-sbtc (/ (* COST-OF-BENJAMIN-NFT (to-uint price-denomination)) adjusted-price)))
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          transfer hundred-dollars-in-sbtc tx-sender (as-contract tx-sender)
          none
        ))
        (contract-call? .nft-contract mint tx-sender)
      )
      ERR_NOT_ENOUGH_SBTC
    )
  )
)

(define-public (release)
  (let ((amount-to-release (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      get-balance-available (as-contract tx-sender)
    ))))
    (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer amount-to-release tx-sender
      'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37 none
    ))
  )
)
