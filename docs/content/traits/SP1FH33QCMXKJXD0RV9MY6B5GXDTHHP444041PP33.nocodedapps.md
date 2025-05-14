---
title: "Trait nocodedapps"
draft: true
---
```
(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

  (define-constant MAX_SUPPLY (* u100000000 (pow u10 u3)))

  (define-fungible-token NoCodeDapps MAX_SUPPLY)

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
      (ft-transfer? NoCodeDapps amt from to)))


  (define-public (mint (amt uint) (to principal))
    (begin
      (try! (check-owner))
      (ft-mint? NoCodeDapps amt to) ))

  (define-read-only (get-name)                   (ok "NoCodeDapps"))
  (define-read-only (get-symbol)                 (ok "NCD"))
  (define-read-only (get-decimals)               (ok u3))
  (define-read-only (get-balance (of principal)) (ok (ft-get-balance NoCodeDapps of)))
  (define-read-only (get-total-supply)           (ok (ft-get-supply NoCodeDapps)))
  (define-read-only (get-max-supply)             (ok MAX_SUPPLY))
  (define-read-only (get-token-uri)              (ok (some u"https://ipfs.io/ipfs/bafkreihsi26hezqtx3gxlw3qbvy3763qfu3h245mm6qymdvmiz4fq5foje")))
  
```
