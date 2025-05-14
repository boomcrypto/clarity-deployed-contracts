---
title: "Trait flash-loan-v1"
draft: true
---
```
;; TRAITS
(use-trait callback-trait .trait-flash-loan-v1.flash-loan)

;; CONSTANTS
(define-constant SUCCESS (ok true))
(define-constant scaling-factor (pow u10 (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.constants-v1 get-market-token-decimals)))
(define-constant market-decimals (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.constants-v1 get-market-token-decimals))
(define-constant scaling-decimals u8)
;; Fee of 0.01% for processing flash loan scaled to 10^8
(define-constant fee u10000)


;; Errors
(define-constant ERR_CONTRACT_NOT_ALLOWED (err u110000))
(define-constant ERR_RESTRICTED_TO_TESTNET (err u110001))


;; Data vars
;; List of allowed contracts that are called back during the flash loan
(define-map allowed-contracts principal bool)

;; Read only functions

(define-read-only (get-fee)
  fee
)

(define-read-only (is-contract-allowed (contract principal))
  (default-to false (map-get? allowed-contracts contract))
)

;; Public functions

(define-public (set-allowed-contract (contract principal))
  (begin
    (asserts! (not is-in-mainnet) ERR_RESTRICTED_TO_TESTNET)
    (map-set allowed-contracts contract true)
    SUCCESS
))

(define-public (flash-loan (amount uint) (callback <callback-trait>) (data (optional (buff 10240))))
  (let (
      (scaled-fee (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.math-v1 to-fixed fee scaling-decimals market-decimals ))
      (flash-loan-fee (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.math-v1 divide-round-up (* amount scaled-fee) scaling-factor))
      (amount-with-fee (+ amount flash-loan-fee))
      (caller contract-caller)
      (callback-contract (contract-of callback))
    )
    (asserts! (default-to false (map-get? allowed-contracts callback-contract)) ERR_CONTRACT_NOT_ALLOWED)
    ;; transfer funds to user
    (try! (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.state-v1 transfer-to 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount))
    (try! (contract-call? callback on-granite-flash-loan amount flash-loan-fee data))
    (try! (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.state-v1 transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount-with-fee))
    (print {
      action: "flash-loan",
      amount: amount,
      fee: flash-loan-fee,
      caller: caller,
      contract: callback-contract
    })
    SUCCESS
  )
)


(map-set allowed-contracts .liquidator true)
```
