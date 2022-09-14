(define-constant contract-owner tx-sender)

(define-constant nft-max-count u200)
(define-constant nft-uri "THIS IS TEST URI")

(define-non-fungible-token dp-test-2 uint)

(define-data-var last-id uint u0)

(define-constant err-nft-transfer-not-allowed (err u100))
(define-constant err-nft-mint-max-count-reached (err u101))
(define-constant err-unauthorized (err u200))

(define-read-only
  (get-last-token-id) 
    (ok (var-get last-id))
)

(define-read-only
  (get-token-uri (id uint)) 
    (if (<= id (var-get last-id)) 
      (ok (some nft-uri))
      (ok none)
    )
)

(define-read-only
  (get-owner (id uint)) 
    (ok (nft-get-owner? dp-test-2 id))
)

(define-public
  (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  )
  err-nft-transfer-not-allowed
)

(define-public 
  (mint
    (recipient principal)
  )
  (let 
    (
      (id (+ (var-get last-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (<= id nft-max-count) err-nft-mint-max-count-reached)
    (try! (nft-mint? dp-test-2 id recipient))
    (var-set last-id id)
    (ok id)
  )
)
