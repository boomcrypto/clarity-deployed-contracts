(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bitbasel-event-test uint)

(define-constant public-key 0x0216a02aeef5bc5602edc8db48b7a1f87eb84a04528eb82ae5fe0c6f6a0f3e7314)

(define-data-var last-id uint u0)

(define-constant err-untransferable (err u1000))
(define-constant err-invalid-signature (err u1001))
(define-constant err-unauthorized (err u1002))

(define-public
  (mint
    (message (buff 32))
    (signature (buff 65))
    (recipient principal)
  )
  (let 
    (
      (id (+ (var-get last-id) u1))
      (key (unwrap! (secp256k1-recover? message signature) err-invalid-signature))
    )
    (asserts! (is-eq key public-key) err-unauthorized)
    (try! (nft-mint? bitbasel-event-test id recipient))
    (ok (var-set last-id id))
  )
)

(define-public
  (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  )
  err-untransferable
)

(define-read-only (get-last-token-id) 
  (ok (var-get last-id))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? bitbasel-event-test id))
)

(define-read-only (get-token-uri (id uint)) 
  (ok (some "ipfs://bafkreiexo2u2bfh5ablaoy7ur4ybza4lqacincccnlzvnmz2uqfgrp5ttq"))
)
