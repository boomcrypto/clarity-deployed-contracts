(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

  (define-constant MAX_SUPPLY (* u1000000000 (pow u10 u5)))

  (define-fungible-token AluxLobs MAX_SUPPLY)

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
      (ft-transfer? AluxLobs amt from to)))


  (define-public (mint (amt uint) (to principal))
    (begin
      (try! (check-owner))
      (ft-mint? AluxLobs amt to) ))

  (define-read-only (get-name)                   (ok "AluxLobs"))
  (define-read-only (get-symbol)                 (ok "ALUX"))
  (define-read-only (get-decimals)               (ok u5))
  (define-read-only (get-balance (of principal)) (ok (ft-get-balance AluxLobs of)))
  (define-read-only (get-total-supply)           (ok (ft-get-supply AluxLobs)))
  (define-read-only (get-max-supply)             (ok MAX_SUPPLY))
  (define-read-only (get-token-uri)              (ok (some u"https://rose-useful-vicuna-13.mypinata.cloud/ipfs/QmXATHXeoRqeuAjAZgM4GkFTiJa8V1CgnMGM8U5b3p8DbD")))
  