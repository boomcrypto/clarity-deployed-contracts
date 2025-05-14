---
title: "Trait MERRYXMAS"
draft: true
---
```
(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

  (define-constant MAX_SUPPLY (* u100000000000 (pow u10 u6)))

  (define-fungible-token MERRYXMAS MAX_SUPPLY)

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
      (ft-transfer? MERRYXMAS amt from to)))


  (define-public (mint (amt uint) (to principal))
    (begin
      (try! (check-owner))
      (ft-mint? MERRYXMAS amt to) ))

  (define-read-only (get-name)                   (ok "MERRYXMAS"))
  (define-read-only (get-symbol)                 (ok "MERRYXMAS"))
  (define-read-only (get-decimals)               (ok u6))
  (define-read-only (get-balance (of principal)) (ok (ft-get-balance MERRYXMAS of)))
  (define-read-only (get-total-supply)           (ok (ft-get-supply MERRYXMAS)))
  (define-read-only (get-max-supply)             (ok MAX_SUPPLY))
  (define-read-only (get-token-uri)              (ok (some u"https://gist.githubusercontent.com/velarqa/7a8f69b8c5a438541ee4e582652b6eea/raw/6e692b8cf5ed6a419c9ff15abb72e49f743f3408/moon-decimals.json")))
  
```
