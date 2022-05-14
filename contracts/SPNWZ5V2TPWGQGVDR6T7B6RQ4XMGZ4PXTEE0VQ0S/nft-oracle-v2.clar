;; STXNFT Royalty and NFT Oracle Contract

;; for NFTs with royalty contracts, specifying the way
;;   in which the NFT creators should get paid.
(define-map royalty-contracts
  principal
  principal
)

;; for NFTs without royalty contracts, where we can
;;   set royalties in a more limited way.
(define-map royalty-amounts
  { nft: principal }
  { address: principal, percent: uint}
)

(define-constant contract-owner tx-sender)
(define-constant err-not-allowed u403)

;; gets the default royalty contract for an NFT contract
(define-read-only (get-royalty-contract (nft principal))
  (map-get? royalty-contracts nft)
)

(define-read-only (get-royalty-amount (nft principal))
  (map-get? royalty-amounts { nft: nft })
)

(define-read-only (is-trusted (nft principal))
  (or (is-some (map-get? royalty-amounts { nft: nft }))
      (is-some (map-get? royalty-contracts nft)))
)

(define-public (set-royalty-amount (contract principal) (address principal) (percent uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set royalty-amounts { nft: contract } 
                                 { address: address, percent: percent}))
  )
)

(define-public (set-royalty-contract (contract principal) (commission principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set royalty-contracts contract commission))
  )
)

(define-public (remove-royalty-amount (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-delete royalty-amounts { nft: contract }))
  )
)

(define-public (remove-royalty-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-delete royalty-contracts contract))
  )
)