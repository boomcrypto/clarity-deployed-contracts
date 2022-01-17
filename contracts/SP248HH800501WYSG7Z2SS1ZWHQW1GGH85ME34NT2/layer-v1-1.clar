(impl-trait 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.nft-trait.nft-trait)
(define-non-fungible-token Layer-NFT uint)
(define-data-var last-token-id uint u10000000000)
(define-data-var last-collection-id uint u200000)
(define-data-var admin-fee uint u1000)
(define-map token-data {token-id: uint} {price: uint, for-sale: bool})
(define-map token-metadata {token-id: uint} (string-ascii 256))
(define-map token-royalties {token-id: uint} {royalties: (list 6 {address: principal, percentage: uint}), owner-percentage: uint})
(define-map collection-data {collection-id: uint} {last-file-id: uint, owner: principal})
(define-data-var admin principal 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2)

(define-private (mint-token (token-id uint) (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalty-data {royalties: (list 6 {address: principal, percentage: uint}), owner-percentage: uint}))
  (match (nft-mint? Layer-NFT token-id tx-sender)
    success 
      (if 
        (and
          (map-insert token-data {token-id: token-id} data)
          (map-insert token-metadata {token-id: token-id} metadata)
          (map-insert token-royalties {token-id: token-id} royalty-data)
        )
        (ok token-id)
        (err u102)
      )  
    error (err u101)
  )
)

(define-public (mint-single-token (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalties (optional (list 5 {address: principal, percentage: uint}))))
  (let
    (
      (royalty-data (unwrap! (calculate-royalty-data royalties) (err u104)))
      (token-id (+ u1 (var-get last-token-id)))
    )
    (match (mint-token token-id data metadata royalty-data)
      success (begin
        (var-set last-token-id token-id)
        (ok token-id)
      )
      error (err error)
    )
  )
)

(define-public (mint-collection (files (optional (list 100 {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}))))
  (let
    (
      (collection-id (+ u1 (var-get last-collection-id)))
      (first-token-id (* collection-id u100000))
      (last-file-id (fold mint-collection-nft-helper (default-to (list ) files) first-token-id))
    )
    (begin 
      (map-set collection-data {collection-id: collection-id} {last-file-id: last-file-id, owner: tx-sender})
      (var-set last-collection-id collection-id)
      (ok collection-id)
    )
  )
)

(define-private (mint-collection-nft-helper (file {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}) (token-id uint)) 
  (if (is-ok (mint-token (+ u1 token-id) (get data file) (get metadata file) (unwrap! (calculate-royalty-data (get royalties file)) u1)))
    (+ u1 token-id)
    token-id
  )
)

(define-public (mint-to-collection (collection-id uint) (files (list 100 {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))})))
  (let
    (
      (collection-info (unwrap! (map-get? collection-data {collection-id: collection-id}) (err u431)))
      (token-id (get last-file-id collection-info))
      (collection-owner (get owner collection-info))
      (last-file-id (fold mint-collection-nft-helper files token-id))
    )
    (if 
      (and
        (is-eq tx-sender collection-owner)
        (map-set collection-data {collection-id: collection-id} {owner: collection-owner, last-file-id: last-file-id})
      )
      (ok last-file-id)
      (err u334)
    )
  )
)

(define-private (calculate-total-royalties-percentage-helper (royalty {address: principal, percentage: uint}) (running-percentage uint))
  (+ running-percentage (get percentage royalty))
)

(define-private (calculate-royalty-data (royalties (optional (list 5 {address: principal, percentage: uint}))))
  (let
    (
      (all-royalties (concat (list {address: (var-get admin), percentage: (var-get admin-fee)}) (default-to (list ) royalties)))
      (total-royalties-percentage (fold calculate-total-royalties-percentage-helper all-royalties u0))
      (owner-percentage (- u10000 total-royalties-percentage))
    )
    (if (<= total-royalties-percentage u10000)
      (ok {royalties: all-royalties, owner-percentage: owner-percentage})
      (err u103)
    )
  )
)

(define-public (purchase (token-id uint))
  (let 
    (
      (data (unwrap! (map-get? token-data { token-id: token-id }) (err u1001)))
      (is-token-for-sale (get for-sale data))
      (token-price (get price data))
      (token-owner (unwrap! (nft-get-owner? Layer-NFT token-id) (err u16)))
    )
    (if 
      (and
        is-token-for-sale
        (>= (stx-get-balance tx-sender) token-price)
        (is-ok (pay token-id token-price token-owner))
        (unwrap! (nft-transfer? Layer-NFT token-id token-owner tx-sender) (err u18))
      )
      (ok (map-set token-data { token-id: token-id } {for-sale: false, price: token-price}))
      (err u19)
    )
  )
)

(define-public (pay (token-id uint) (price uint) (owner-address principal))
  (let
    (
      (royalties-data (unwrap! (map-get? token-royalties {token-id: token-id}) (err u190)))
      (royalties (get royalties royalties-data))
      (owner-percentage (get owner-percentage royalties-data))
    )
    (fold pay-percentage (append royalties {percentage: owner-percentage, address: owner-address}) (ok price))
  )
)

(define-private (pay-percentage (royalty {percentage: uint, address: principal}) (price-res (response uint uint)))
  (let ((price (unwrap! price-res (err u1234))))
    (if (not (is-eq tx-sender (get address royalty)))
      (if (is-ok (stx-transfer? (/ (* price (get percentage royalty)) u10000) tx-sender (get address royalty)))
        (ok price)
        (err u1023)
      )
      (ok price) 
    )
  )
)

(define-public (complete-sale (token-id uint) (new-owner-address principal) (old-owner-address principal) (token-price uint))
  (if 
    (and
      (is-eq tx-sender (var-get admin))
      (is-ok (pay token-id token-price old-owner-address))
    )
    (nft-transfer? Layer-NFT token-id tx-sender new-owner-address) 
    (err u561)
  )
)

(define-public (set-token-price-data (token-id uint) (price uint) (for-sale bool))
  (if (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id))
    (ok (map-set token-data {token-id: token-id} {price: price, for-sale: for-sale}))
    (err u13)
  )
)

(define-public (change-collection-owner (collection-id uint) (new-owner principal))
  (let ((collection-info (unwrap! (map-get? collection-data {collection-id: collection-id}) (err u325))))
    (if (is-eq (get owner collection-info) tx-sender)
      (ok (map-set collection-data {collection-id: collection-id} {owner: new-owner, last-file-id: (get last-file-id collection-info)}))
      (err u677)
    )
  )
)

(define-public (set-admin-fee (fee uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin-fee fee))
    (err u499)
  )
)

(define-public (change-admin (new-admin principal))
  (if (is-eq (var-get admin) tx-sender)
    (ok (var-set admin new-admin))
    (err u221)
  )
)

(define-public (validate-auth (challenge-token (string-ascii 500))) (ok true))

(define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (if
    (and 
      (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id))
      (is-eq owner tx-sender)
      (is-ok (nft-transfer? Layer-NFT token-id owner recipient))
    )
    (ok (map-set token-data {token-id: token-id} (merge (unwrap! (map-get? token-data {token-id: token-id}) (err u1903)) {for-sale: false})))
    (err u37)
  )
)

(define-read-only (get-all-token-data (token-id uint))
  (ok {
      token-id: token-id,
      token-metadata: (unwrap! (map-get? token-metadata {token-id: token-id}) (err u3)),
      token-data: (unwrap! (map-get? token-data {token-id: token-id}) (err u8)),
      token-royalties: (unwrap! (map-get? token-royalties {token-id: token-id}) (err u4)),
      token-owner: (unwrap! (nft-get-owner? Layer-NFT token-id) (err u5)),
    })
)

(define-read-only (get-collection-data (collection-id uint))
  (map-get? collection-data {collection-id: collection-id}))
  
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Layer-NFT token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (unwrap! (map-get? token-metadata { token-id: token-id }) (err u2222))))
)