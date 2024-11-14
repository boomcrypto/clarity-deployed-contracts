---
title: "Trait test-minting-state"
draft: true
---
```
;; @contract Minting State
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_GATEKEEPER (err u2001))
(define-constant ERR_ABOVE_MAX (err u2002))

(define-constant usdh-base (pow u10 u8))
(define-constant max-confirmation-window u144)
(define-constant max-fee u200)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var mint-confirmation-window uint u10)
(define-data-var redeem-confirmation-window uint u10)

(define-data-var whitelist-enabled bool true)
(define-data-var mint-enabled bool true)
(define-data-var redeem-enabled bool true)

(define-data-var min-amount-usdh-requested uint (* u1000 usdh-base))

(define-data-var fee-address principal tx-sender)
(define-data-var mint-fee-usdh uint u10)
(define-data-var redeem-fee-usdh uint u10)
(define-data-var mint-fee-asset uint u10)
(define-data-var redeem-fee-asset uint u10)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map whitelist
  {
    address: principal 
  }
  {
    minter: bool,
    redeemer: bool
  }
)

(define-map gatekeepers
  {
    address: principal 
  }
  {
    active: bool
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-mint-confirmation-window)
  (var-get mint-confirmation-window)
)

(define-read-only (get-redeem-confirmation-window)
  (var-get redeem-confirmation-window)
)

(define-read-only (get-whitelist-enabled)
  (var-get whitelist-enabled)
)

(define-read-only (get-mint-enabled)
  (var-get mint-enabled)
)

(define-read-only (get-redeem-enabled)
  (var-get redeem-enabled)
)

(define-read-only (get-fee-address)
  (var-get fee-address)
)

(define-read-only (get-min-amount-usdh-requested)
  (var-get min-amount-usdh-requested)
)

(define-read-only (get-mint-fee-usdh)
  (var-get mint-fee-usdh)
)

(define-read-only (get-redeem-fee-usdh)
  (var-get redeem-fee-usdh)
)

(define-read-only (get-mint-fee-asset)
  (var-get mint-fee-asset)
)

(define-read-only (get-redeem-fee-asset)
  (var-get redeem-fee-asset)
)

(define-read-only (get-whitelist (address principal))
  (default-to 
    { minter: false, redeemer: false }
    (map-get? whitelist { address: address })
  )
)

(define-read-only (get-gatekeeper-active (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? gatekeepers { address: address })
    )
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-read-only (get-request-mint-state (address principal))
  {
    mint-enabled: (var-get mint-enabled),
    min-amount-usdh: (var-get min-amount-usdh-requested),
    whitelisted: (check-is-minter address),
  }
)

(define-read-only (get-request-redeem-state (address principal))
  {
    redeem-enabled: (var-get redeem-enabled),
    min-amount-usdh: (var-get min-amount-usdh-requested),
    whitelisted: (check-is-redeemer address)
  }
)

(define-read-only (get-confirm-mint-state)
  {
    mint-enabled: (var-get mint-enabled),
    fee-address: (var-get fee-address),
    mint-fee-usdh: (var-get mint-fee-usdh),
    mint-fee-asset: (var-get mint-fee-asset),
  }
)

(define-read-only (get-confirm-redeem-state)
  {
    redeem-enabled: (var-get redeem-enabled),
    fee-address: (var-get fee-address),
    redeem-fee-usdh: (var-get redeem-fee-usdh),
    redeem-fee-asset: (var-get redeem-fee-asset),
  }
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-gatekeeper (address principal))
  (ok (asserts! (get-gatekeeper-active address) ERR_NOT_GATEKEEPER))
)

(define-read-only (check-is-minter (address principal))
  (if (get-whitelist-enabled) (get minter (get-whitelist address)) true)
)

(define-read-only (check-is-redeemer (address principal))
  (if (get-whitelist-enabled) (get redeemer (get-whitelist address)) true)
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-mint-confirmation-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-window max-confirmation-window) ERR_ABOVE_MAX)
    (ok (var-set mint-confirmation-window new-window))
  )
)

(define-public (set-redeem-confirmation-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-window max-confirmation-window) ERR_ABOVE_MAX)
    (ok (var-set redeem-confirmation-window new-window))
  )
)

(define-public (set-whitelist-enabled (whitelist-enabled-set bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set whitelist-enabled whitelist-enabled-set))
  )
)

(define-public (set-mint-enabled (mint-enabled-set bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set mint-enabled mint-enabled-set))
  )
)

(define-public (set-redeem-enabled (redeem-enabled-set bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set redeem-enabled redeem-enabled-set))
  )
)

(define-public (set-min-amount-usdh-requested (new-min-amount-usdh-requested uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set min-amount-usdh-requested new-min-amount-usdh-requested))
  )
)

(define-public (set-fee-address (new-fee-address principal))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set fee-address new-fee-address)))
)

(define-public (set-mint-fee-usdh (new-mint-fee-usdh uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-mint-fee-usdh max-fee) ERR_ABOVE_MAX)
    (ok (var-set mint-fee-usdh new-mint-fee-usdh)))
)

(define-public (set-redeem-fee-usdh (new-redeem-fee-usdh uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-redeem-fee-usdh max-fee) ERR_ABOVE_MAX)
    (ok (var-set redeem-fee-usdh new-redeem-fee-usdh)))
)

(define-public (set-mint-fee-asset (new-mint-fee-asset uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-mint-fee-asset max-fee) ERR_ABOVE_MAX)
    (ok (var-set mint-fee-asset new-mint-fee-asset)))
)

(define-public (set-redeem-fee-asset (new-redeem-fee-asset uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-redeem-fee-asset max-fee) ERR_ABOVE_MAX)
    (ok (var-set redeem-fee-asset new-redeem-fee-asset)))
)

(define-public (set-gatekeeper (address principal) (active bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (map-set gatekeepers { address: address } { active: active }))
  )
)

;;-------------------------------------
;; Gatekeeper
;;-------------------------------------

(define-public (set-trading-disabled)
  (begin 
    (try! (check-is-gatekeeper tx-sender))
    (var-set mint-enabled false)
    (ok (var-set redeem-enabled false))
  )
)

(define-public (set-mint-disabled)
  (begin 
    (try! (check-is-gatekeeper tx-sender))
    (ok (var-set mint-enabled false))
  )
)

(define-public (set-redeem-disabled)
  (begin
    (try! (check-is-gatekeeper tx-sender))
    (ok (var-set redeem-enabled false))
  )
)

(define-private (whitelist-processor (entry {address: principal, mint: bool, redeem: bool}))
  (map-set whitelist { address: (get address entry) } { minter: (get mint entry), redeemer: (get redeem entry)})
)

(define-private (whitelist-remover (address principal))
  (map-delete whitelist { address: address })
)

(define-public (add-whitelist (entries (list 1000 {address: principal, mint: bool, redeem: bool})))
  (begin
    (try! (check-is-gatekeeper tx-sender))
    (ok (map whitelist-processor entries)))
)

(define-public (remove-whitelist (entries (list 1000 principal)))
  (begin
    (try! (check-is-gatekeeper tx-sender))
    (ok (map whitelist-remover entries)))
)
```
