---
title: "Trait net-lime-coyote"
draft: true
---
```
;; Digital zine sales contract

;; 1,000,000 microstacks = 1 STX
;; 100,000,000 satoshis = 1 BTC
(define-constant ustx-price u10000000) ;; 10 STX
(define-constant sats-price u10000) ;; 10,000 sats

;; Constants 
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-campaign-ended (err u101))
(define-constant err-not-initialized (err u102))
(define-constant err-not-cancelled (err u103))
(define-constant err-campaign-not-ended (err u104))
(define-constant err-campaign-cancelled (err u105))
(define-constant err-already-initialized (err u106))
(define-constant err-already-withdrawn (err u107))

;; Data vars
(define-data-var is-campaign-initialized bool false)
(define-data-var is-campaign-cancelled bool false)
(define-data-var beneficiary principal contract-owner)
(define-data-var campaign-start uint u0)
(define-data-var campaign-goal uint u0)
(define-data-var total-stx uint u0) ;; in microstacks
(define-data-var total-sbtc uint u0) ;; in sats
(define-data-var purchase-count uint u0)

;; Maps
;; Track who has purchased the zine
(define-map purchasers principal bool)

;; Initialize the campaign
;; Can only be called once
(define-public (initialize-campaign)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (not (var-get is-campaign-initialized)) err-already-initialized)
    (var-set is-campaign-initialized true)
    (var-set campaign-start burn-block-height)
    (ok true)))

;; Cancel the campaign
;; Only the owner can call this, at any time during or after the campaign
;; Can only be called once
(define-public (cancel-campaign)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (var-set is-campaign-cancelled true)
    (ok true)))

;; Purchase zine with STX
(define-public (purchase-with-stx)
  (begin
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (asserts! (not (var-get is-campaign-cancelled)) err-campaign-cancelled)
    (try! (stx-transfer? ustx-price tx-sender (as-contract tx-sender)))
    (map-set purchasers tx-sender true)
    (var-set total-stx (+ (var-get total-stx) ustx-price))
    (var-set purchase-count (+ (var-get purchase-count) u1))
    (ok true)))

;; Purchase zine with sBTC
(define-public (purchase-with-sbtc)
  (begin
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (asserts! (not (var-get is-campaign-cancelled)) err-campaign-cancelled)
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
      sats-price
      contract-caller
      (as-contract tx-sender) 
      none))
    (map-set purchasers tx-sender true)
    (var-set total-sbtc (+ (var-get total-sbtc) sats-price))
    (var-set purchase-count (+ (var-get purchase-count) u1))
    (ok true)))

;; Creator can withdraw funds at any time
(define-public (withdraw)
  (let (
    (total-stx-amount (var-get total-stx))
    (total-sbtc-amount (var-get total-sbtc))
  )
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (asserts! (is-eq tx-sender (var-get beneficiary)) err-not-authorized)
    (as-contract
      (begin
        (if (> total-stx-amount u0)
          (begin
            (try! (stx-transfer? total-stx-amount (as-contract tx-sender) (var-get beneficiary)))
            (var-set total-stx u0))
          true)
        (if (> total-sbtc-amount u0)
          (begin
            (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
              total-sbtc-amount
              (as-contract tx-sender)
              (var-get beneficiary)
              none))
            (var-set total-sbtc u0))
          true)
        (ok true)))))

;; Getter functions
(define-read-only (get-purchase-status (donor principal))
  (ok (default-to false (map-get? purchasers donor))))

(define-read-only (get-campaign-info)
  (ok {
    start: (var-get campaign-start),
    totalStx: (var-get total-stx),
    totalSbtc: (var-get total-sbtc),
    purchaseCount: (var-get purchase-count),
    isCancelled: (var-get is-campaign-cancelled),
    ustxPrice: ustx-price,
    satsPrice: sats-price,
  }))

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender)))
```
