(impl-trait 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.nft-trait.nft-trait)
(define-non-fungible-token ineffablenft uint)
(define-data-var last-token-id uint u0)
(define-map token-data uint {price: uint, for-sale: bool})
(define-map token-metadata uint (string-ascii 256))
(define-data-var heylayer-admin principal tx-sender)

(define-constant ERR-NO-ENTRY-IN-MAP (err u991))
(define-constant ERR-TOKEN-DNE (err u992))
(define-constant ERR-UNWRAPPING (err u993))
(define-constant ERR-TOKEN-ALREADY-EXISTS (err u994))
(define-constant ERR-TOKEN-NOT-FOR-SALE (err u995))
(define-constant ERR-NOT-AUTHORIZED (err u997))

(define-private (mint (all-token-data {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}))
  (let
    (
      (token-id (get token-id all-token-data))
      (minter (get minter all-token-data))
      (data (get data all-token-data))
      (metadata (get metadata all-token-data))
    )
    (try! (nft-mint? ineffablenft token-id minter))
    (asserts! (map-insert token-data token-id data) ERR-TOKEN-ALREADY-EXISTS)
    (asserts! (map-insert token-metadata token-id metadata) ERR-TOKEN-ALREADY-EXISTS)
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-private (mint-transfer (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, recipient: principal}))
  (let (
    (all-token-data (get all-token-data file))
    (recipient (get recipient file))
    (token-id (get token-id all-token-data))
    (minter (get minter all-token-data))
  )
    (try! (mint all-token-data))
    (match (nft-transfer? ineffablenft token-id minter recipient)
      ok-value (ok token-id)
      err-value (begin
        (try! (delete-nft token-id))
        (err err-value)
      )
    )
  )
)

(define-private (mint-pay (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, buyer: principal}))
  (let (
    (all-token-data (get all-token-data file))
    (buyer (get buyer file))
    (token-id (get token-id all-token-data))
    (minter (get minter all-token-data))
  )
    (try! (mint all-token-data))
    (match (pay-transfer token-id minter buyer)
      ok-value (ok token-id)
      err-value (begin
        (try! (delete-nft token-id))
        (err err-value)
      )
    )
  )
)

(define-private (mint-admin (file {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, post-mint: (optional {recipient: principal, is-purchase: bool})}))
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

(define-private (mint-edition (token-id uint) (all-token-data (response {minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}} uint)))
  (begin
    (try! (mint (merge {token-id: token-id} (unwrap! all-token-data ERR-UNWRAPPING))))
    all-token-data
  )
)

(define-private (delete-maps (token-id uint))
  (begin
    (map-delete token-data token-id)
    (map-delete token-metadata token-id)
  )
)

(define-private (delete-nft (token-id uint))
  (begin
    (delete-maps token-id)
    (try! (nft-burn? ineffablenft token-id (unwrap! (nft-get-owner? ineffablenft token-id) ERR-TOKEN-DNE)))
    (ok token-id)
  )
)

(define-private (pay-transfer (token-id uint) (token-owner principal) (token-recipient principal))
  (let ((token-price (get price (unwrap! (map-get? token-data token-id) ERR-TOKEN-DNE))))
    (try! (pay token-price token-owner))
    (try! (nft-transfer? ineffablenft token-id token-owner token-recipient))
    (ok (map-set token-data token-id {for-sale: false, price: token-price}) )
  )
)

(define-public (pay (token-price uint) (token-owner principal))
  (begin
    (try! (pay-share (/ (* token-price u10) u100) (var-get heylayer-admin))) ;; Layer royalty
    (try! (pay-share (/ (* token-price u90) u100) 'SP1TNPPPEERTBVQ86EP4M0ZATMBRDVM37GKBJA4VZ))
    (try! (pay-share (/ (* token-price u0) u100) token-owner)) ;; Owner share
    (ok true)
  )
)

(define-private (pay-share (to-pay uint) (recipient principal))
  (if (not (is-eq tx-sender recipient))
    (stx-transfer? to-pay tx-sender recipient)
    (ok false)
  )
)

(define-private (complete-sale (sale-datum {token-id: uint, token-owner: principal, token-recipient: (optional principal), token-price: uint}))
  (let (
    (token-id (get token-id sale-datum))
    (token-owner (get token-owner sale-datum))
    (token-recipient-optional (get token-recipient sale-datum))
    (token-price (get token-price sale-datum))
  )
    (try! (pay token-price token-owner))
    (if (is-none token-recipient-optional)
      (ok token-id)
      (let ((token-recipient (unwrap! token-recipient-optional ERR-UNWRAPPING)))
        (try! (nft-transfer? ineffablenft token-id tx-sender token-recipient))
        (ok token-id)
      )
    )
  )
)

(define-private (transfer-many-helper (transfer-datum {token-id: uint, recipient: principal}))
  (transfer (get token-id transfer-datum) tx-sender (get recipient transfer-datum))
)

(define-private (is-admin)
  (is-eq tx-sender (var-get heylayer-admin))
)

(define-public (mint-many (files (list 500 {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint files))
  )
)

(define-public (mint-transfer-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, recipient: principal})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-transfer files))
  )
)

(define-public (mint-pay-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, buyer: principal})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-pay files))
  )
)

(define-public (mint-admin-many (files (list 500 {all-token-data: {token-id: uint, minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}, post-mint: (optional {recipient: principal, is-purchase: bool})})))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map mint-admin files))
  )
)

(define-public (mint-editions (edition-ids (list 10000 uint)) (all-token-data {minter: principal, metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (fold mint-edition edition-ids (ok all-token-data)))
  )
)

(define-public (lock-stx-in-escrow (token-id uint) (price uint) (memo (string-ascii 100)))
  (begin
    (try! (stx-transfer? price tx-sender (var-get heylayer-admin)))
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
      (token-owner (unwrap! (nft-get-owner? ineffablenft token-id) ERR-TOKEN-DNE))
    )
    (asserts! is-token-for-sale ERR-TOKEN-NOT-FOR-SALE)
    (try! (pay token-price token-owner))
    (try! (nft-transfer? ineffablenft token-id token-owner tx-sender))
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
    (asserts! (is-eq (some tx-sender) (nft-get-owner? ineffablenft token-id)) ERR-NOT-AUTHORIZED)
    (ok (map-set token-data token-id {price: price, for-sale: for-sale}))
  )
)

(define-public (change-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set heylayer-admin new-admin))
  )
)

(define-public (delete-token-many (token-ids (list 500 uint)))
  (ok (map delete-token token-ids))
)

(define-public (delete-token (token-id uint))
  (let ((nft-owner (unwrap! (nft-get-owner? ineffablenft token-id) ERR-TOKEN-DNE)))
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
    (asserts! (is-eq (some tx-sender) (nft-get-owner? ineffablenft token-id)) ERR-NOT-AUTHORIZED)
    (try! (nft-transfer? ineffablenft token-id owner recipient))
    (ok (map-set token-data token-id (merge (unwrap! (map-get? token-data token-id) ERR-NO-ENTRY-IN-MAP) {for-sale: false})))
  )
)

(define-read-only (get-all-token-data (token-id uint))
  (ok {
      token-id: token-id,
      token-metadata: (map-get? token-metadata token-id),
      token-data: (map-get? token-data token-id),
      token-owner: (nft-get-owner? ineffablenft token-id),
    })
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? ineffablenft token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? token-metadata token-id))
)
