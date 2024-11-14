---
title: "Trait creatures-neon"
draft: true
---
```
;; SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC.creatures-neon
;; Author: Rapha Stacks
;; "The man who has no imagination has no wings." - Muhammad Ali
(use-trait sip10 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-core.sip010-transferable-trait) 
(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant THIS-CONTRACT (as-contract tx-sender))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_RECEIVER (err u8))
(define-constant ERR_INVALID_FEES_TRAIT (err u10))
(define-constant ERR_NATIVE_FAILURE (err u99))
(define-constant ERR_NOT_CREATURE_SENDER (err u11))
(define-constant ERR_FT_FAILURE (err u12))

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-map swaps 
    uint 
    {
      creature-id: uint, 
      creatures-amount: uint,
      creatures-sender: principal, 
      ustx: uint, 
      stx-sender: (optional principal),  
      open: bool, 
      fees: principal
    }
)
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))
    
;; helper function to transfer SFT creatures 
(define-private (creatures-transfer-to (creature-id uint) (amount uint) (to principal) (memo (buff 34)))
    (begin 
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-core transfer creature-id amount tx-sender to))
      (print memo)
      (ok true))
) 

;; create a public offer
(define-public (offer (creature-id uint) (amount uint) (stx-sender (optional principal)) (ustx uint) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {creature-id: creature-id, creatures-amount: amount, creatures-sender: tx-sender, ustx: ustx, stx-sender: stx-sender,
         open: true, fees: (contract-of fees)}) ERR_INVALID_ID)
    (print 
      {
        type: "offer",
        swap_type: "CRE-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: stx-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: "CRE",
        in_nft_id: creature-id, ;; adding creature-id versus backend
        in_amount: amount, 
        in_decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-core get-decimals creature-id) ERR_FT_FAILURE), 
        out_contract: "STX",
        out-amount: ustx,
        out-decimals: u6,
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (creatures-transfer-to creature-id amount (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; only creatures-sender can cancel the swap and get the fees back
(define-public (cancel (id uint) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (creature-id (get creature-id swap))
    (amount (get creatures-amount swap)))
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get creatures-sender swap)) ERR_NOT_CREATURE_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees (get ustx swap)))
      (print 
       {
        type: "cancel",
        swap_type: "CRE-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get stx-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: "CRE",
        in_nft_id: creature-id, ;; adding creature-id versus backend
        in_amount: amount, 
        in_decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-core get-decimals creature-id) ERR_FT_FAILURE), 
        out_contract: "STX",
        out-amount: (get ustx swap),
        out-decimals: u6,
       }
      )
      (match (as-contract (creatures-transfer-to
                creature-id amount (get creatures-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (swap-creatures
    (id uint)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (creature-id (get creature-id swap))
    (amount (get creatures-amount swap))
    (creatures-receiver (default-to tx-sender (get stx-sender swap)))
    (ustx (get ustx swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender creatures-receiver) ERR_INVALID_RECEIVER) 
      (try! (contract-call? fees pay-fees ustx))
      (print 
       {
        type: "swap",
        swap_type: "CRE-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: creatures-receiver,
        open: false,
        fees: (contract-of fees),
        in_contract: "CRE",
        in_nft_id: creature-id, ;; adding creature-id versus backend
        in_amount: amount, 
        in_decimals: (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-core get-decimals creature-id) ERR_FT_FAILURE), 
        out_contract: "STX",
        out-amount: ustx,
        out-decimals: u6,
       }
      )
      (match (stx-transfer-memo? ustx creatures-receiver (get creatures-sender swap) 0x636174616d6172616e2073776170)
        success-stx (begin
            (asserts! success-stx ERR_NATIVE_FAILURE)
            (match (as-contract (creatures-transfer-to
                creature-id amount creatures-receiver
                0x636174616d6172616e2073776170))
              success-creatures (ok success-creatures)
              error-creatures (err (* error-creatures u100))))
        error-stx (err (* error-stx u1000)))))

(define-public (swap-and-store (id uint) (fees <fees-trait>) (lp-token <sip10>)) 
    (let 
    (
        (swap-result (unwrap-panic (swap-creatures id fees)))
    )
        (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.creatures-kit store lp-token) 
    )
)
```
