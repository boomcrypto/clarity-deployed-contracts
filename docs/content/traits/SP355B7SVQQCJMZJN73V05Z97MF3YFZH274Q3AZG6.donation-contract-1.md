---
title: "Trait donation-contract-1"
draft: true
---
```
(define-map Donors principal uint)
(define-data-var totalDonations uint u0)
(define-data-var CONTRACT_OWNER principal tx-sender)

(define-read-only (get-donation-amount (who principal))
  (default-to u0 (map-get? Donors who))
)

(define-public (donate (amount uint))
  (begin
    (asserts! (>= amount u3000000) (err u101))
    (map-set Donors tx-sender (+ (get-donation-amount tx-sender) amount))
    (var-set totalDonations (+ (var-get totalDonations) amount))
    (stx-transfer? amount tx-sender (as-contract tx-sender))
  )
)

(define-public (release-funds (beneficiary principal))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT_OWNER)) (err u102))
    (as-contract (stx-transfer? (var-get totalDonations) tx-sender beneficiary))
  )
)

(define-public (update-contract-owner (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT_OWNER)) (err u102))
    (ok (var-set CONTRACT_OWNER who))
  )
)

```
