(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; This contract is admin-less and immutable

(define-constant BATCH-1
 (list 
  'SP3J2H949KF8N4EPXKB42ZQT4EFGJFEW36DX20J1D.jackaroo-stxcity
  'SP371690BDHK9WRH3KXXRWNK62YR8N1P5JSYGQKRM.clive-stxcity
  'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity
  'SP10VQCN71BZ0CXVKH7DF2H1MEQNKG9C49R9AHGKB.bao-stxcity
  'SP2ECF9BD90CXW96XYT032MG6BQ2N6TRQ47V0D90R.september-11-stxcity
  'SP116BXQNYGH2SDF64Z68CRPKVTK93KWTVXTA2DYD.moon-landing-stxcity
  'SP3W69VDG9VTZNG7NTW1QNCC1W45SNY98W1JSZBJH.flat-earth-stxcity
  'SP1HPB7YTZDXMZSZD51C113PQFAXKSNR0QYFFPWVC.blewy-stxcity
  'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2.honey-badger-stxcity
  'SPKMQ8QD26HS1B2E9KXWCDKRF63X0RP8BZ361QTH.moneystack-stxcity
  'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9.dry-sock-stxcity
  'SP3BRXZ9Y7P5YP28PSR8YJT39RT51ZZBSECTCADGR.skullcoin-stxcity
  'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity
  'SP2PGA85MN3D1YVMRJK9WCGQT09Q9EZBCM7C3VNYA.fuck-the-cabal-stxcity
  'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV.moist-sock-bonding-curve
  'SP739VRRCMXY223XPR28BWEBTJMA0B27DY8GTKCH.gyatt-bonding-curve
  'SP345FTTDC4VT580K18ER0MP5PR1ZRP5C3Q0KYA1P.booster-bonding-curve
  'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
  'SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve
  'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
  'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
  'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
  'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
  'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
  'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
  'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
  'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
  'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
  'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
  'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega
  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3
  'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X.friedger-token-v1
  'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
  'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
  'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
  'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
  'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-stx
  'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi
  'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog
  'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo
  'SP3F2NN8A1B75N64HWGY3R7E9XEJHGX3GY052312W.suss
))

(define-map b1-ft principal bool)

(define-private (add-b1-ft (token principal))
  (map-set b1-ft token true))

(define-private (initialize-b1)
  (begin
    (map add-b1-ft BATCH-1)
    (ok true)))

;; Define the two allowed fee contracts
(define-constant YIN-FEES .yin)
(define-constant YANG-FEES .yang)

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-map swaps uint {ustx: uint, stx-sender: principal, amount: uint, ft-sender: (optional principal), open: bool, ft: principal, fees: principal, expired-height: (optional uint)})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-private (is-valid-fees (fees <fees-trait>))
  (or (is-eq (contract-of fees) YIN-FEES)
      (is-eq (contract-of fees) YANG-FEES)))

;; create a swap between btc and fungible token
(define-public (offer (ustx uint) (amount uint) (ft-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>) (expiry (optional uint)))
  (let ((id (var-get next-id)))
    (asserts! (is-b1 (contract-of ft)) ERR_TOKEN_NOT_B1)
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (match expiry
            some-expiry (begin 
                        (asserts! (map-insert swaps id
                            {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
                             open: true, ft: (contract-of ft), fees: (contract-of fees), expired-height: (some (+ burn-block-height some-expiry))}) ERR_INVALID_ID)
                            (print 
                            {
                                type: "offer",
                                swap-id: id, 
                                creator: tx-sender,
                                counterparty: ft-sender,
                                open: true,
                                fees: (contract-of fees),
                                in_contract: "STX",
                                in_amount: ustx,
                                in_decimals: u6,
                                out_contract: (contract-of ft), 
                                out-amount: amount,
                                out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
                                expired-height: (some (+ burn-block-height some-expiry))
                            })
                        )
            (begin
            (asserts! (map-insert swaps id
                  {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
                  open: true, ft: (contract-of ft), fees: (contract-of fees), expired-height: none}) ERR_INVALID_ID)
            (print 
                            {
                                type: "offer",
                                swap-id: id, 
                                creator: tx-sender,
                                counterparty: ft-sender,
                                open: true,
                                fees: (contract-of fees),
                                in_contract: "STX",
                                in_amount: ustx,
                                in_decimals: u6,
                                out_contract: (contract-of ft), 
                                out-amount: amount,
                                out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
                                expired-height: none
                            })
            )
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (stx-transfer? ustx tx-sender (as-contract tx-sender))
      success (ok id)
      error (err (* error u100)))))

;; only stx-sender can cancel the swap after and get the fees back
(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_NOT_STX_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get ft-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: "STX",
        in_amount: ustx,
        in_decimals: u6,
        out_contract: (contract-of ft), 
        out-amount: (get amount swap),
        out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
      }
    )
      (match (as-contract (stx-transfer? ustx tx-sender (get stx-sender swap)))
        success (ok success)
        error (err (* error u100)))))

(define-public (re-price (id uint) (ft <fungible-token>) (fees <fees-trait>) (amount uint) (expiry (optional uint)))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_NOT_STX_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (match expiry
            some-expiry (begin 
                        (asserts! (map-set swaps id (merge swap {amount: amount, expired-height: (some (+ burn-block-height some-expiry))})) ERR_NATIVE_FAILURE)
                        (print 
                        {
                            type: "re-price",
                            swap-id: id, 
                            creator: tx-sender,
                            counterparty: (get ft-sender swap),
                            open: false,
                            fees: (contract-of fees),
                            in_contract: "STX",
                            in_amount: ustx,
                            in_decimals: u6,
                            out_contract: (contract-of ft), 
                            out-amount: amount,
                            out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
                            expired-height: (some (+ burn-block-height some-expiry))
                        }
                        ))
            (begin
            (asserts! (map-set swaps id (merge swap {amount: amount, expired-height: none})) ERR_NATIVE_FAILURE)
                        (print 
                        {
                            type: "cancel",
                            swap-id: id, 
                            creator: tx-sender,
                            counterparty: (get ft-sender swap),
                            open: false,
                            fees: (contract-of fees),
                            in_contract: "STX",
                            in_amount: ustx,
                            in_decimals: u6,
                            out_contract: (contract-of ft), 
                            out-amount: amount,
                            out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
                            expired-height: none
                        }
                        ))
        )
      (ok true)))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (stx-receiver (default-to tx-sender (get ft-sender swap)))
    (ft-amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER) ;; assert out if the receiver is predetermined 
      (match (get expired-height swap)
            some-height (asserts! (<= burn-block-height some-height) ERR_BOMB_EXPIRED)
            true) 
      (try! (contract-call? fees pay-fees ustx))

      (match (contract-call? ft transfer
          ft-amount stx-receiver (get stx-sender swap)
          (some 0x696E74656772617465))
        success-ft (begin
            (asserts! success-ft ERR_NATIVE_FAILURE)
            (match (as-contract (stx-transfer? (get ustx swap) tx-sender stx-receiver))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-ft (err (* error-ft u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_STX_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_STX_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_TOKEN_NOT_B1 (err u14))
(define-constant ERR_BOMB_EXPIRED (err u15))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
(initialize-b1)

(define-read-only (is-b1 (token principal))
  (default-to false (map-get? b1-ft token)))