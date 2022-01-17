(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token redeeem-nft uint)

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)

;; Custom errors
(define-constant ERR-NOT-AUTHORIZED (err u400)) ;; contract operation not unauthorized
(define-constant ERR-NFT-NOT-OWNED (err u401)) ;; nft operation not authorized
(define-constant ERR-APPROVAL-NOT-FOUND (err u402)) ;; approval doesnt exists for the token
(define-constant ERR-COLLECTION-CREATION (err 403)) ;; cant create a collection
(define-constant ERR-COLLECTION-COMPLETED (err u404)) ;; no more size on collection to mint a new token
(define-constant ERR-COLLECTION-NOT-FOUND (err u405)) ;; collection doesnt exists
(define-constant ERR-COLLECTION-WRITE (err u406)) ;; principal has no permission to write on the collection
(define-constant ERR-INSUFFICIENT-FUNDS (err u407)) ;; principal has insuffient funds to pay mint cost
(define-constant ERR-NFT-NOT-FOUND (err u408)) ;; nft doesnt exists

;; Data structures
(define-map meta uint (tuple (collection-id uint) (uri (string-ascii 256))))
(define-map collection-meta uint (tuple (creator principal) (max-size uint) (last-minted uint)))

;; (define-map meta uint {collection-id: uint, uri: (string-ascii 256)})
(define-map nft-approvals uint {approval: principal})

;; Contract variables
(define-data-var last-token-id uint u0)
(define-data-var last-collection-id uint u0)
(define-data-var mint-cost uint u0)
(define-data-var public-minting bool false)

;; Get the public minting status of the contract
(define-read-only (is-minting-public)
  (ok (var-get public-minting)))

;; Get current cost to mint
(define-read-only (get-mint-cost)
  (ok (var-get mint-cost)))

;; Get the approval status of a principal for a given token identifier
(define-read-only (get-approval (token-id uint))
  (ok (get approval (map-get? nft-approvals token-id))))

;; Get the owner of a given token identifier
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? redeeem-nft token-id)))

;; Get the owner of a given collection identifier
(define-read-only (get-collection-owner (collection-id uint))
  (ok (get creator (map-get? collection-meta collection-id))))

;; Last token ID, limited to uint range
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

;; Get the URI for metadata associated with the token
(define-read-only (get-token-uri (token-id uint))
  (ok (get uri (map-get? meta token-id))))

;; Get a token collection-id
(define-read-only (get-token-collection-id (token-id uint))
  (ok (get collection-id (map-get? meta token-id))))

;; Get the STX balance of a given principal
(define-read-only (get-stx-account-balance (account principal))
    (ok (stx-get-balance account)))

;; Get data for a given Collection ID
(define-read-only (get-collection-data (collection-id uint))
  (ok (map-get? collection-meta collection-id))
)

;; Set public minting state
(define-public (set-public-minting (value bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set public-minting value)
    (ok true)))

;; Set the mint cost
(define-public (set-mint-cost (cost uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set mint-cost cost)
    (ok true)))

;; Transfer from the sender to a new principal - Approval automatically revoked
(define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (if (is-owner-or-approved token-id tx-sender)
    (begin
      (try!
      (if (is-eq (ok none) (get-approval token-id))
        (ok false)
        (revoke-approval token-id)))
      (try! (nft-transfer? redeeem-nft token-id owner recipient))
      (ok true))
    ERR-NFT-NOT-OWNED))

;; Approve contract owner to act on behalf of token owner
(define-public (set-approval (token-id uint))
  (if (is-owner token-id tx-sender)
    (begin
        (map-set nft-approvals token-id {approval: CONTRACT-OWNER})
        (ok true))
    ERR-NFT-NOT-OWNED))

;; Revoke approval for contract owner to act on behalf of the token owner
(define-public (revoke-approval (token-id uint))
  (begin
    (asserts! (is-owner-or-approved token-id tx-sender) ERR-NFT-NOT-OWNED)
    (asserts! (map-delete nft-approvals token-id) ERR-APPROVAL-NOT-FOUND)
    (ok true)))

;; Set the URI for given token
(define-public (set-token-uri (token-id uint) (uri (string-ascii 256)))
  (match (map-get? meta token-id)
    token-meta
      (begin
        (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-collection-owner (get collection-id token-meta) tx-sender)) ERR-NOT-AUTHORIZED)
        (map-set meta token-id {collection-id: (get collection-id token-meta), uri: uri} )
        (ok true))
    ERR-NFT-NOT-FOUND))

;; Set the collection id for given token
(define-public (set-token-collection-id (token-id uint) (collection-id uint))
  (match (map-get? meta token-id)
    token-meta
      (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (map-set meta token-id {collection-id: collection-id, uri: (get uri token-meta)} )
        (ok true))
    ERR-NFT-NOT-FOUND))

;; Mint an NFT on a given Collection
(define-public (mint (collection-id uint) (uri (string-ascii 256)))
    (match (map-get? collection-meta collection-id)
      collection
        (begin
          (asserts! (or (is-eq (get max-size collection) u0) (and (> (get max-size collection) u0) (< (get last-minted collection) (get max-size collection)))) ERR-COLLECTION-COMPLETED)
          (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (get creator collection))) ERR-COLLECTION-WRITE)
          (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (var-get public-minting)) ERR-NOT-AUTHORIZED)
          (ok (try! (mint-token tx-sender collection-id uri))))
      ERR-COLLECTION-NOT-FOUND))

;; Redeeem the NFT for a physical asset should burn the token on the blockchain
(define-public (redeeem (token-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (match (nft-burn? redeeem-nft token-id tx-sender)
      success (ok true)
      error (err error))))

;; Creates a new collection
(define-public (create-collection (max-size uint))
  (let ((next-collection-id (+ u1 (var-get last-collection-id))))
    (begin
      (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (var-get public-minting)) ERR-NOT-AUTHORIZED)
      (map-insert collection-meta next-collection-id { creator: tx-sender, max-size: max-size, last-minted: u0 })
      (var-set last-collection-id next-collection-id)
      (ok next-collection-id))))

;; Checks if a principal owns the token
(define-private (is-owner (token-id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? redeeem-nft token-id) false)))

;; Checks if a principal owns the token
(define-private (is-collection-owner (collection-id uint) (user principal))
  (match (map-get? collection-meta collection-id)
    collection (is-eq user (get creator collection))
    false))

;; Checks if the contract owner is approved to act on behalf of the token owner
(define-private (is-approved (token-id uint))
  (is-eq CONTRACT-OWNER (unwrap! (get approval (map-get? nft-approvals token-id)) false)))

(define-private (is-owner-or-approved (token-id uint) (user principal))
  (if (is-owner token-id user)
    true
    (if (is-approved token-id) true false)))

;; Mint a token to a specific principal
(define-private (mint-token (new-owner principal) (collection-id uint) (uri (string-ascii 256)))
  (if (charge-stx)
    (let ((next-token-id (+ u1 (var-get last-token-id))))
      (match (nft-mint? redeeem-nft next-token-id new-owner)
        success
          (begin
            (map-insert meta next-token-id { uri: uri, collection-id: collection-id })
            (match (map-get? collection-meta collection-id)
              collection
              (begin
                (map-set collection-meta collection-id {creator: (get creator collection), max-size: (get max-size collection), last-minted: (+ u1 (get last-minted collection))})
                (var-set last-token-id next-token-id)
                (ok next-token-id))
              ERR-COLLECTION-NOT-FOUND
            ))
        error (err error)))
    ERR-INSUFFICIENT-FUNDS))

;; Charge the minting if needed
(define-private (charge-stx)
  (if (> (var-get mint-cost) u0)
    (match (stx-transfer? (var-get mint-cost) tx-sender (as-contract tx-sender))
      success true
      error false)
    true))