---
title: "Trait fundraising"
draft: true
---
```
;; Fundraising Campaign Contract
;; A simple contract to accept crypto donations in STX or sBTC.

;; Constants 
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-campaign-ended (err u101))
(define-constant err-not-initialized (err u102))
(define-constant err-campaign-not-ended (err u104))
(define-constant err-already-initialized (err u106))

(define-constant default-duration u4320) ;; Duration in *Bitcoin* blocks. This default value means is if a block is 10 minutes, this is roughly 30 days.

;; Data vars
(define-data-var is-campaign-initialized bool false)
(define-data-var beneficiary principal contract-owner)
(define-data-var campaign-duration uint u173000)
(define-data-var campaign-start uint u0)
(define-data-var campaign-goal uint u0)
(define-data-var total-stx uint u0) ;; in microstacks
(define-data-var total-sbtc uint u0) ;; in sats
(define-data-var donation-count uint u0)

;; Maps
(define-map stx-donations principal uint)  ;; donor -> amount
(define-map sbtc-donations principal uint) ;; donor -> amount

;; Initialize the campaign (goal in US dollars)
;; Pass duration as 0 to use the default duration (~30 days)
;; Can only be called once
(define-public (initialize-campaign (goal uint) (duration uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (not (var-get is-campaign-initialized)) err-already-initialized)
    (var-set is-campaign-initialized true)
    (var-set campaign-start burn-block-height)
    (var-set campaign-goal goal)
    (var-set campaign-duration duration)
    (var-set campaign-duration (if (is-eq duration u0) 
      default-duration
      duration))
    (ok true)))

;; Donate STX. Pass amount in microstacks.
(define-public (donate-stx (amount uint))
  (begin
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (asserts! (< burn-block-height (+ (var-get campaign-start) (var-get campaign-duration))) 
              err-campaign-ended)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stx-donations tx-sender 
      (+ (default-to u0 (map-get? stx-donations tx-sender)) amount))
    (var-set total-stx (+ (var-get total-stx) amount))
    (var-set donation-count (+ (var-get donation-count) u1))
    (ok true)))

;; Donate sBTC. Pass amount in Satoshis.
(define-public (donate-sbtc (amount uint))
  (begin
    (asserts! (var-get is-campaign-initialized) err-not-initialized)
    (asserts! (< burn-block-height (+ (var-get campaign-start) (var-get campaign-duration))) 
              err-campaign-ended)
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
      amount 
      contract-caller
      (as-contract tx-sender) 
      none))
    (map-set sbtc-donations tx-sender
      (+ (default-to u0 (map-get? sbtc-donations tx-sender)) amount))
    (var-set total-sbtc (+ (var-get total-sbtc) amount))
    (var-set donation-count (+ (var-get donation-count) u1))
    (ok true)))

;; Getter functions
(define-read-only (get-stx-donation (donor principal))
  (ok (default-to u0 (map-get? stx-donations donor))))

(define-read-only (get-sbtc-donation (donor principal))
  (ok (default-to u0 (map-get? sbtc-donations donor))))

(define-read-only (get-campaign-info)
  (ok {
    start: (var-get campaign-start),
    end: (+ (var-get campaign-start) (var-get campaign-duration)),
    goal: (var-get campaign-goal),
    totalStx: (var-get total-stx),
    totalSbtc: (var-get total-sbtc),
    donationCount: (var-get donation-count),
    isExpired: (>= burn-block-height (+ (var-get campaign-start) (var-get campaign-duration))),
  }))

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender)))

```
