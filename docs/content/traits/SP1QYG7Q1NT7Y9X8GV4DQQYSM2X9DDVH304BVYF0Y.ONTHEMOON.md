---
title: "Trait ONTHEMOON"
draft: true
---
```
(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

  (define-constant MAX_SUPPLY (* u100000000000 (pow u10 u6)))

  (define-fungible-token ONTHEMOON MAX_SUPPLY)

  (define-constant err-check-owner (err u1))
  (define-constant err-transfer    (err u4))

  (define-data-var owner principal tx-sender)

  (define-private (check-owner)
    (ok (asserts! (is-eq tx-sender (var-get owner)) err-check-owner)))

  (define-public (set-owner (new-owner principal))
    (begin
    (try! (check-owner))
    (ok (var-set owner new-owner)) ))

  (define-public
    (transfer
      (amt  uint)
      (from principal)
      (to   principal)
      (memo (optional (buff 34))))
    (begin
      (asserts! (is-eq tx-sender from) err-transfer)
      (ft-transfer? ONTHEMOON amt from to)))


  (define-public (mint (amt uint) (to principal))
    (begin
      (try! (check-owner))
      (ft-mint? ONTHEMOON amt to) ))

  (define-read-only (get-name)                   (ok "ONTHEMOON"))
  (define-read-only (get-symbol)                 (ok "ONTHEMOON"))
  (define-read-only (get-decimals)               (ok u6))
  (define-read-only (get-balance (of principal)) (ok (ft-get-balance ONTHEMOON of)))
  (define-read-only (get-total-supply)           (ok (ft-get-supply ONTHEMOON)))
  (define-read-only (get-max-supply)             (ok MAX_SUPPLY))
  (define-read-only (get-token-uri)              (ok (some u"https://api.jsonbin.io/v3/qs/674ed1b1e41b4d34e45ee7d9")))
  
```
