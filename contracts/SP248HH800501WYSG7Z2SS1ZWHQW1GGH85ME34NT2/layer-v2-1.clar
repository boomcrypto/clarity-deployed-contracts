(impl-trait 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.nft-trait.nft-trait)
(define-non-fungible-token Layer-NFT uint)
(define-data-var last-token-id uint u10000)
(define-data-var admin-fee uint u1000)
(define-map token-data uint {price: uint, for-sale: bool})
(define-map token-metadata uint (string-ascii 256))
(define-map token-royalties uint {royalties: (list 6 {address: principal, percentage: uint}), owner-percentage: uint})
(define-data-var admin principal tx-sender)

(define-constant ERR-NO-ENTRY-IN-MAP (err u991))
(define-constant ERR-TOKEN-DNE (err u992))
(define-constant ERR-UNWRAPPING (err u993))
(define-constant ERR-TOKEN-ALREADY-EXISTS (err u994))
(define-constant ERR-TOKEN-NOT-FOR-SALE (err u995))
(define-constant ERR-ROYALTIES-TOTAL-OVERFLOW (err u996))
(define-constant ERR-NOT-AUTHORIZED (err u997))
(define-constant ERR-COULD-NOT-CALCULATE-ROYALTY-DATA (err u998))

(define-private (mint (all-token-data {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}))
  (let 
    (
      (token-id (get token-id all-token-data))
      (minter (get minter all-token-data))
      (data (get data all-token-data))
      (metadata (get metadata all-token-data))
      (royalties (get royalties all-token-data))
      (royalty-data (unwrap! (calculate-royalty-data royalties) ERR-COULD-NOT-CALCULATE-ROYALTY-DATA))
    )
    (try! (nft-mint? Layer-NFT token-id minter))
    (asserts! (map-insert token-data token-id data) ERR-TOKEN-ALREADY-EXISTS)
    (asserts! (map-insert token-metadata token-id metadata) ERR-TOKEN-ALREADY-EXISTS)
    (asserts! (map-insert token-royalties token-id royalty-data) ERR-TOKEN-ALREADY-EXISTS)
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-private (mint-transfer (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, recipient: principal}))
  (let (
    (all-token-data (get all-token-data file))
    (recipient (get recipient file))
    (token-id (get token-id all-token-data))
    (minter (get minter all-token-data))
  )
    (try! (mint all-token-data))
    (match (nft-transfer? Layer-NFT token-id minter recipient)
      ok-value (ok token-id)
      err-value (begin
        (try! (delete-nft token-id))
        (err err-value)
      )
    )
  )
)

(define-private (mint-pay (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, buyer: principal}))
  (let (
    (all-token-data (get all-token-data file))
    (buyer (get buyer file))
    (token-id (get token-id all-token-data))
    (minter (get minter all-token-data))
    (price (get price (get data all-token-data)))
  )
    (try! (mint all-token-data))
    (match (pay-transfer token-id price minter buyer)
      ok-value (ok token-id)
      err-value (begin
        (try! (delete-nft token-id))
        (err err-value)
      )
    )
  )
)

(define-private (mint-admin (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, post-mint: (optional {recipient: principal, is-purchase: bool})}))
  (let (
    (all-token-data (get all-token-data file))
    (post-mint (get post-mint file))
    (token-id (get token-id all-token-data))
    (minter (get minter all-token-data))
  )
    (if (is-none post-mint)
      (mint all-token-data)
      (let ((post-mint-data (unwrap! post-mint ERR-UNWRAPPING)))
        (if (get is-purchase post-mint-data)
          (mint-pay {all-token-data: all-token-data, buyer: (get recipient post-mint-data)})
          (mint-transfer {all-token-data: all-token-data, recipient: (get recipient post-mint-data)})          
        )
      )
    )
  )
)

(define-private (mint-edition (token-id uint) (all-token-data (response {minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))} uint)))
  (begin 
    (try! (mint (merge {token-id: token-id} (unwrap! all-token-data ERR-UNWRAPPING))))
    all-token-data
  )
)

(define-private (delete-maps (token-id uint))
  (begin
    (map-delete token-data token-id)
    (map-delete token-metadata token-id)
    (map-delete token-royalties token-id)
  )
)

(define-private (delete-nft (token-id uint))
  (begin
    (delete-maps token-id)
    (try! (nft-burn? Layer-NFT token-id (unwrap! (nft-get-owner? Layer-NFT token-id) ERR-TOKEN-DNE)))
    (ok token-id)
  )
)

(define-private (pay-transfer (token-id uint) (token-price uint) (token-owner principal) (token-recipient principal))
  (begin
    (try! (nft-transfer? Layer-NFT token-id token-owner token-recipient))
    (try! (pay token-id token-price token-owner))
    (map-set token-data token-id {for-sale: false, price: token-price})
    (ok token-id)
  )
)

(define-public (pay (token-id uint) (token-price uint) (token-owner principal))
  (let
    (
      (royalties-data (unwrap! (map-get? token-royalties token-id) ERR-NO-ENTRY-IN-MAP))
      (royalties (get royalties royalties-data))
      (owner-percentage (get owner-percentage royalties-data))
      (royalties-with-owner-share (append royalties {percentage: owner-percentage, address: token-owner}))
    )
    (fold pay-percentage royalties-with-owner-share (ok token-id))
  )
)

(define-private (pay-percentage (royalty {percentage: uint, address: principal}) (price-res (response uint uint)))
  (let 
    (
      (price (unwrap! price-res price-res))
      (stx-to-pay (/ (* price (get percentage royalty)) u10000))
      (address-to-pay (get address royalty))
    )
    (asserts! (not (is-eq tx-sender address-to-pay)) (ok price))
    (try! (stx-transfer? stx-to-pay tx-sender address-to-pay))
    (ok price)
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
    (asserts! (<= total-royalties-percentage u10000) ERR-ROYALTIES-TOTAL-OVERFLOW)
    (ok {royalties: all-royalties, owner-percentage: owner-percentage})
  )
)

(define-private (complete-sale (sale-datum {token-id: uint, token-owner: principal, token-recipient: (optional principal), token-price: uint}))
  (let (
    (token-id (get token-id sale-datum))
    (token-owner (get token-owner sale-datum))
    (token-recipient-optional (get token-recipient sale-datum))
    (token-price (get token-price sale-datum))
  ) 
    (if (is-none token-recipient-optional)
      (ok (try! (pay token-id token-price token-owner)))
      (ok (try! (pay-transfer token-id token-price token-owner (unwrap! token-recipient-optional (err u0)))))
    )
  )
)

(define-private (transfer-many-helper (transfer-datum {token-id: uint, recipient: principal}))
  (transfer (get token-id transfer-datum) tx-sender (get recipient transfer-datum))
)

(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

(define-public (mint-many (files (list 500 {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint files))
  )
)

(define-public (mint-transfer-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, recipient: principal})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-transfer files))
  )
)

(define-public (mint-pay-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, buyer: principal})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-pay files))
  )
)

(define-public (mint-admin-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}, post-mint: (optional {recipient: principal, is-purchase: bool})})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-admin files))
  )
)

(define-public (mint-editions (edition-ids (list 10000 uint)) (all-token-data {minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (fold mint-edition edition-ids (ok all-token-data)))
  )
)

(define-public (lock-stx-in-escrow (token-id uint) (price uint) (memo (string-ascii 100)))
  (begin
    (try! (stx-transfer? price tx-sender (var-get admin)))
    (print memo)
    (ok token-id)
  )
)

(define-public (purchase (token-id uint))
  (let 
    (
      (data (unwrap! (map-get? token-data token-id) ERR-TOKEN-DNE))
      (is-token-for-sale (get for-sale data))
      (token-price (get price data))
      (token-owner (unwrap! (nft-get-owner? Layer-NFT token-id) ERR-TOKEN-DNE))
    )
    (asserts! is-token-for-sale ERR-TOKEN-NOT-FOR-SALE)
    (try! (pay token-id token-price token-owner))
    (try! (nft-transfer? Layer-NFT token-id token-owner tx-sender))
    (ok (map-set token-data token-id {for-sale: false, price: token-price}))
  )
)

(define-public (transfer-stx-many (transfer-data (list 500 {amount: uint, recipient: principal, memo: (optional (string-ascii 100))})))
  (ok (map transfer-stx transfer-data))
)

(define-public (transfer-stx (transfer-datum {amount: uint, recipient: principal, memo: (optional (string-ascii 100))}))
  (begin
    (try! (stx-transfer? (get amount transfer-datum) tx-sender (get recipient transfer-datum)))
    (print (get memo transfer-datum))
    (ok (get amount transfer-datum))
  )
)

(define-public (complete-sale-many (sale-data (list 500 {token-id: uint, token-owner: principal, token-recipient: (optional principal), token-price: uint})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map complete-sale sale-data))
  )
)

(define-public (set-token-price-data (token-id uint) (price uint) (for-sale bool))
  (begin 
    (asserts! (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id)) ERR-NOT-AUTHORIZED)
    (ok (map-set token-data token-id {price: price, for-sale: for-sale}))
  )
)

(define-public (set-admin-fee (fee uint))
  (begin 
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin-fee fee))
  )
)

(define-public (change-admin (new-admin principal))
  (begin 
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))
  )
)

(define-public (delete-token-many (token-ids (list 500 uint)))
  (ok (map delete-token token-ids))
)

(define-public (delete-token (token-id uint))
  (let ((nft-owner (unwrap! (nft-get-owner? Layer-NFT token-id) ERR-TOKEN-DNE)))
    (asserts! (is-eq tx-sender nft-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (delete-nft token-id)
  )
)

(define-public (transfer-many (transfer-data (list 500 {token-id: uint, recipient: principal})))
  (ok (map transfer-many-helper transfer-data))
)

(define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (begin 
    (asserts! (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id)) ERR-NOT-AUTHORIZED)
    (try! (nft-transfer? Layer-NFT token-id owner recipient))
    (ok (map-set token-data token-id (merge (unwrap! (map-get? token-data token-id) ERR-NO-ENTRY-IN-MAP) {for-sale: false})))
  )
)

(define-public (validate-auth (challenge-token (string-ascii 500))) (ok true))

(define-read-only (get-all-token-data (token-id uint))
  (ok {
      token-id: token-id,
      token-owner: (nft-get-owner? Layer-NFT token-id),
      token-metadata: (map-get? token-metadata token-id),
      token-data: (map-get? token-data token-id),
      token-royalties: (map-get? token-royalties token-id),
    })
)
  
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Layer-NFT token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? token-metadata token-id))
)