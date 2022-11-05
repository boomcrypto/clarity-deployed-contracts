(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant contract-owner tx-sender)

(define-constant token-uri "ipfs://QmeZwr3BMrK7BmjNu34ibEDFtJEc6sbvnct8L7wqJz3YhE")

(define-non-fungible-token dp-nft uint)
(define-constant max-supply u10)
(define-data-var last-id uint u0)

(define-constant err-sender-only (err u100))
(define-constant err-contract-owner-only (err u101))
(define-constant err-max-supply-reached (err u102))

(define-read-only
  (get-last-token-id) 
  (ok (var-get last-id))
)

(define-read-only 
  (get-owner 
    (id uint)
  )
  (ok (nft-get-owner? dp-nft id))
)

(define-read-only 
  (get-token-uri 
    (id uint)
  )
  (begin
    (asserts! (> id u0) (ok none))
    (asserts! (<= id (var-get last-id)) (ok none))
    (ok (some token-uri))
  )
)

(define-public 
  (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  ) 
  (begin
    (asserts! (is-eq tx-sender sender) err-sender-only)
    (nft-transfer? dp-nft id sender recipient)
  )
)

(define-public 
  (mint
    (recipient principal)
  )
  (let 
    (
      (id (+ (var-get last-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-contract-owner-only)
    (asserts! (<= id max-supply) err-max-supply-reached)
    (try! (nft-mint? dp-nft id recipient))
    (var-set last-id id)
    (ok true)
  )
)