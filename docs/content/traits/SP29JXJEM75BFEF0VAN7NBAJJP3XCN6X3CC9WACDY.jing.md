---
title: "Trait jing"
draft: true
---
```
(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; This contract is admin-less and immutable

(define-constant BATCH-1
  (list 
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

(define-map swaps uint {ustx: uint, stx-sender: principal, amount: uint, ft-sender: (optional principal), open: bool, ft: principal, fees: principal})
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
(define-public (offer (ustx uint) (amount uint) (ft-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-b1 (contract-of ft)) ERR_TOKEN_NOT_B1)
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
         open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
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
      }
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
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap-id: id, 
            creator: (get stx-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: "STX",
            in_amount: ustx,
            in_decimals: u6,
            out_contract: (contract-of ft), 
            out-amount: ft-amount,
            out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        }
      )
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
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
(initialize-b1)

(define-read-only (is-b1 (token principal))
  (default-to false (map-get? b1-ft token)))
```
