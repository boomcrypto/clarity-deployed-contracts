---
title: "Trait dmg-cha"
draft: true
---
```
(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; This contract is admin-less and immutable

(define-map swaps uint {ustx: uint, stx-sender: principal, amount: uint, ft-sender: (optional principal), open: bool})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

;; helper function to transfer stx to a principal with memo
(define-private (stx-transfer-to (ustx uint) (to principal) (memo (optional (buff 34))))
  (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token transfer ustx tx-sender to memo))

;; create a swap between btc and fungible token
(define-public (offer (ustx uint) (amount uint) (ft-sender (optional principal)))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
         open: true}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "STX-FT",
        swap-id: id, 
        creator: tx-sender,
        counterparty: ft-sender,
        open: true,
        in_contract: "SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token",
        in_amount: ustx,
        in_decimals: (unwrap! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-decimals) ERR_FT_FAILURE),
        out_contract: "SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token", 
        out-amount: amount,
        out-decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-decimals) ERR_FT_FAILURE),
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? .fire hold-fees ustx))
    (match (stx-transfer-to ustx (as-contract tx-sender) (some 0x696E74656772617465))
      success (ok id)
      error (err (* error u100)))))

;; only stx-sender can cancel the swap after and get the fees back
(define-public (cancel (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_NOT_STX_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? .fire release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "STX-FT",
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get ft-sender swap),
        open: false,
        in_contract: "SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token",
        in_amount: ustx,
        in_decimals: (unwrap! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-decimals) ERR_FT_FAILURE),
        out_contract: "SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token",  
        out-amount: (get amount swap),
        out-decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-decimals) ERR_FT_FAILURE),
      }
    )
      (match (as-contract (stx-transfer-to
                ustx (get stx-sender swap)
                (some 0x7365706172617465)))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (stx-receiver (default-to tx-sender (get ft-sender swap)))
    (ft-amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER) ;; assert out if the receiver is predetermined 
      (try! (contract-call? .fire pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "STX-FT",
            swap-id: id, 
            creator: (get stx-sender swap),
            counterparty: tx-sender,
            open: false,
            in_contract: "SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token",
            in_amount: ustx,
            in_decimals: (unwrap! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-decimals) ERR_FT_FAILURE),
            out_contract: "SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token",
            out-amount: ft-amount,
            out-decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-decimals) ERR_FT_FAILURE),
        }
      )
      (match (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer
          ft-amount stx-receiver (get stx-sender swap)
          (some 0x696E74656772617465))
        success-ft (begin
            (asserts! success-ft ERR_NATIVE_FAILURE)
            (match (as-contract (stx-transfer-to
                (get ustx swap) stx-receiver
                (some 0x696E74656772617465)))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-ft (err (* error-ft u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_STX_RECEIVER (err u9))
(define-constant ERR_NOT_STX_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.

```
