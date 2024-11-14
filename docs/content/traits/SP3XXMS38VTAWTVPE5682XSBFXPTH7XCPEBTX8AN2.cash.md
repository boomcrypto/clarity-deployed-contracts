---
title: "Trait cash"
draft: true
---
```
(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 
;; This contract is admin-less and immutable

(define-constant BATCH-1
  (list 
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

(define-map swaps uint {amount: uint, ft-sender: principal, ustx: uint, stx-sender: (optional principal), open: bool, ft: principal, fees: principal})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-private (ft-transfer-to (amount uint) (ft <fungible-token>) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? ft transfer amount tx-sender to (some memo)))
    (ok true)))

(define-private (stx-transfer-to (ustx uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many-memo send-many
    (list {to: to,
            ustx: ustx,
            memo: memo})))

(define-private (is-valid-fees (fees <fees-trait>))
  (or (is-eq (contract-of fees) YIN-FEES)
      (is-eq (contract-of fees) YANG-FEES)))

(define-public (offer (amount uint) (ustx uint) (stx-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-b1 (contract-of ft)) ERR_TOKEN_NOT_B1)
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {amount: amount, ft-sender: tx-sender, ustx: ustx, stx-sender: stx-sender,
         open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "FT-STX",
        swap-id: id, 
        creator: tx-sender,
        counterparty: stx-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX", 
        out-amount: ustx,
        out-decimals: u6,
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (ft-transfer-to amount ft (as-contract tx-sender) 0x696E74656772617465)
      success (ok id)
      error (err (* error u100)))))

;; only ft-sender can cancel the swap and get the fees back
(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (amount (get amount swap))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get ft-sender swap)) ERR_NOT_FT_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "FT-STX",
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get stx-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX",
        out-amount: ustx,
        out-decimals: u6
      }
    )
    (match (as-contract (ft-transfer-to 
                amount ft (get ft-sender swap)
                0x7365706172617465))
      success (ok success)
      error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (ft-receiver (default-to tx-sender (get stx-sender swap)))
    (amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender ft-receiver) ERR_INVALID_FT_RECEIVER) ;; ft-receiver is tx-sender  / assert out if the receiver is predetermined 
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "FT-STX",
            swap-id: id, 
            creator: (get ft-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: (contract-of ft),
            in_amount: amount,
            in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
            out_contract: "STX",
            out-amount: ustx,
            out-decimals: u6,
        }
      )
      (match (stx-transfer-to ustx (get ft-sender swap) 0x696E74656772617465)
        success-stx (begin
            (asserts! success-stx ERR_NATIVE_FAILURE)
            (match (as-contract (ft-transfer-to amount ft
                ft-receiver 0x696E74656772617465))
              success-ft (ok success-ft)
              error-ft (err (* error-ft u100))))
        error-stx (err (* error-stx u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_FT_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_FT_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_TOKEN_NOT_B1 (err u14))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
(initialize-b1)

(define-read-only (is-b1 (token principal))
  (default-to false (map-get? b1-ft token)))
```
