---
title: "Trait Goat"
draft: true
---
```
(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

  (define-constant MAX_SUPPLY (* u100000000 (pow u10 u3)))

  (define-fungible-token Goat MAX_SUPPLY)

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
      (ft-transfer? Goat amt from to)))


  (define-public (mint (amt uint) (to principal))
    (begin
      (try! (check-owner))
      (ft-mint? Goat amt to) ))

  (define-read-only (get-name)                   (ok "Goat"))
  (define-read-only (get-symbol)                 (ok "GOAT"))
  (define-read-only (get-decimals)               (ok u3))
  (define-read-only (get-balance (of principal)) (ok (ft-get-balance Goat of)))
  (define-read-only (get-total-supply)           (ok (ft-get-supply Goat)))
  (define-read-only (get-max-supply)             (ok MAX_SUPPLY))
  (define-read-only (get-token-uri)              (ok (some u"https://img.freepik.com/free-vector/friendly-cartoon-mountain-goat-illustration_1308-166297.jpg?t=st=1732171916~exp=1732175516~hmac=f2a7ca871836d30d029a792d333a02bbf276212296de1fc9d2e0307cef1ad5a4&w=996")))
  
```
