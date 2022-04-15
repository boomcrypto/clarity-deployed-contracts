(use-trait nft-trait 'SP158WX3ZNRDG4SR56TD1398NZK1945QTTKB8B60X.nft-trait.nft-trait)

(define-constant CONTRACT-OWNER tx-sender)

(define-data-var comm1 uint u1000000)

(define-data-var topay principal 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG)


(define-public (pay (nft <nft-trait>) (id uint) (name (string-utf8 256)))

 (stx-transfer? (var-get comm1) tx-sender (var-get topay)))

 (define-public (setcomm1 (newcomm uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set comm1 newcomm))
  )
)

(define-read-only (get-comm)
  (var-get comm1))

  (define-public (payto (newpayee principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set topay newpayee))
  )
)

(define-read-only (get-payee)
  (var-get topay))



(define-constant err-not-authorized (err u403))

