;; @contract Portals
;; @version 1.0 (mainnet)

;; DESCRIPTION: Portals lets you bridge 1/1 NFTs from other networks to the Stacks Network.
;; NOTICE: The following contract is still being developed, please use it at your own risk.

(define-non-fungible-token portals uint)

;; | DATA VARS |
(define-data-var last-id uint u0)
(define-data-var contract-owner principal tx-sender)

;; | ERRORS |
(define-constant ERR-NOT-AUTHORIZED u1111)
(define-constant ERR-TRANSFER u2222)
(define-constant ERR-BURN u3333)
(define-constant ERR-MINT u4444)

;; | STORAGE |
(define-map nfts uint
  {
    id: uint,
    name: (string-ascii 80),
    description: (string-ascii 80),
    chain: (string-ascii 80),
    creator: (string-ascii 80),
    uri: (string-ascii 2048),
    minter: principal
  }
)

;; PUBLIC-FUNCTION | Set-Contract-Owner: Lets contract owner set new contract owner
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set contract-owner owner))
  )
)

;; PUBLIC-FUNCTION | Mint-Nft: Lets contract owner mint a new NFT
(define-public (mint-nft (name (string-ascii 80)) (description (string-ascii 80)) (chain (string-ascii 80)) (creator (string-ascii 80)) (uri (string-ascii 2048)) (minter principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR-NOT-AUTHORIZED))
    (let
      ((id (+ u1 (var-get last-id))))
      (var-set last-id (+ u1 (var-get last-id)))
      (map-insert nfts id {id: id, name: name, description: description, chain: chain, creator: creator, uri: uri, minter: minter})
      (match (nft-mint? portals id tx-sender)
        success (ok true)
        error (err ERR-MINT)
      )
    )
  )
)

;; PUBLIC-FUNCTION | Transfer: Allows user to transfer an NFT they own
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (if (and (is-owner id tx-sender) (is-eq sender tx-sender))
    (match (nft-transfer? portals id sender recipient)
      success (ok true)
      error (err ERR-TRANSFER)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

;; PUBLIC-FUNCTION | Burn-Nft: Lets contract owner burn an NFT (map entry remains stored in the contract)
(define-public (burn-nft (id uint))
  (if (and (is-owner id tx-sender) (is-eq tx-sender (var-get contract-owner)))
    (match (nft-burn? portals id tx-sender)
      success (ok true)
      error (err ERR-BURN)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

;; PUBLIC-FUNCTION | Update-Nft: Lets contract owner update the map data for a specific NFT
(define-public (update-nft (id uint) (name (string-ascii 80)) (description (string-ascii 80)) (chain (string-ascii 80)) (creator (string-ascii 80)) (uri (string-ascii 2048)) (minter principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-set nfts id {id: id, name: name, description: description, chain: chain, creator: creator, uri: uri, minter: minter})
    (ok true)
  )
)

;; PRIVATE-FUNCTION | Is-Owner: Checks if user owns a specific NFT
(define-private (is-owner (id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? portals id) false)))

;; READ-ONLY | Get-Contract-Owner: Gets contract owner wallet
(define-read-only (get-contract-owner)
  (var-get contract-owner))

;; READ-ONLY | Get-Owner: Returns the owner of a specific NFT
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? portals id)))

;; READ-ONLY | Get-Last-Token-Id: Returns the ID of the last NFT minted
(define-read-only (get-last-token-id)
  (var-get last-id))

;; READ-ONLY | Get-Nft: Returns map data for a specific NFT
(define-read-only (get-nft (id uint))
  (map-get? nfts id))

;; READ-ONLY | Get-Token-Uri: Returns URI for a specific NFT
(define-read-only (get-token-uri (id uint))
  (ok (get uri (map-get? nfts id))))
