(use-trait nft-trait 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG.nft-trait.nft-trait)

(define-constant CONTRACT-OWNER tx-sender)

(define-data-var transfer-fee uint u1000000)

(define-data-var topay principal 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG)


(define-public (pay (nft <nft-trait>) (id uint) (name (string-utf8 256)))
 (stx-transfer? (var-get transfer-fee) tx-sender (var-get topay)))

 (define-public (set-transfer-fee (newfee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set transfer-fee newfee))
  )
)

(define-read-only (get-fee)
  (var-get transfer-fee))

  (define-public (payto (newpayee principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set topay newpayee))
  )
)

(define-read-only (get-payee)
  (var-get topay))



(define-constant err-not-authorized (err u403))

