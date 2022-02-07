;; @contract Jump Protocol
;; @version 1.1 (mainnet)

;; DESCRIPTION: The Jump Protocol is an early attempt at bridging NFTs from various blockchains to the Stacks Blockchain.
;; NOTE: We would like to thank the team at Megapont for the creation of the non-custodial marketplace. We took lots of inspiration while creating the one used in this contract.
;; NOTICE: The following contract is still being developed, please use it at your own risk.

(define-non-fungible-token jump uint)

;; | DATA VARS |
(define-data-var last-id uint u0)
(define-data-var bridge-count uint u0)
(define-data-var contract-owner principal tx-sender)

;; | ERRORS |
(define-constant ERR-NOT-AUTHORIZED u1111)
(define-constant ERR-TRANSFER u2222)
(define-constant ERR-BURN u3333)
(define-constant ERR-MINT u4444)
(define-constant ERR-NOT-FOUND u5555)
(define-constant ERR-LISTING u6666)

;; | STORAGE |
(define-map token-count principal uint)
(define-map market uint {price: uint})
(define-map nfts uint
  {
    id: uint,
    name: (string-ascii 2048),
    description: (string-ascii 2048),
    chain: (string-ascii 2048),
    uri: (string-ascii 2048),
    orginAddress: (string-ascii 2048),
    minter: principal
  }
)


;; PUBLIC-FUNCTION | Set-Contract-Owner: Lets contract owner set new contract owner
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set contract-owner owner)
    (ok true)
  )
)

;; PUBLIC-FUNCTION | Mint-Nft: Lets contract owner mint a new NFT
(define-public (mint-nft (name (string-ascii 2048)) (description (string-ascii 2048)) (chain (string-ascii 2048)) (uri (string-ascii 2048)) (orginAddress (string-ascii 2048)) (minter principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR-NOT-AUTHORIZED))
    (let
      ((id (+ u1 (var-get last-id))))
      (var-set last-id (+ (var-get last-id) u1))
      (var-set bridge-count (+ (var-get bridge-count) u1))
      (map-insert nfts id {id: id, name: name, description: description, chain: chain, uri: uri, orginAddress: orginAddress, minter: minter})
      (map-set token-count minter (+ (get-balance minter) u1))
      (match (nft-mint? jump id minter)
        success (ok true)
        error (err ERR-MINT)
      )
    )
  )
)

;; PUBLIC-FUNCTION | Transfer: Allows user to transfer an NFT they own
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; PUBLIC-FUNCTION | Burn-Nft: Lets contract owner burn an NFT (map entry remains stored in the contract)
(define-public (burn-nft (id uint))
  (begin
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set bridge-count (- (var-get bridge-count) u1))
    (map-set token-count tx-sender (- (get-balance tx-sender) u1))
    (map-delete nfts id)
    (match (nft-burn? jump id tx-sender)
      success (ok true)
      error (err ERR-BURN)
    )
  )
)

;; PUBLIC-FUNCTION | Update-Nft: Lets contract owner update the map data for a specific NFT
(define-public (update-nft (id uint) (name (string-ascii 2048)) (description (string-ascii 2048)) (chain (string-ascii 2048)) (uri (string-ascii 2048)) (orginAddress (string-ascii 2048)) (minter principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-set nfts id {id: id, name: name, description: description, chain: chain, uri: uri, orginAddress: orginAddress, minter: minter})
    (ok true)
  )
)

;; PRIVATE-FUNCTION | Trnsfr: Private transfer function mainly used for the non-custodial marketplace
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? jump id sender recipient)
        success
          (let
            ((sender-balance (get-balance sender))
            (recipient-balance (get-balance recipient)))
              (map-set token-count
                    sender
                    (- sender-balance u1))
              (map-set token-count
                    recipient
                    (+ recipient-balance u1))
              (ok success))
        error (err error)))

;; PUBLIC-FUNCTION | Get-Listing-In-Ustx: Gets listing price for a NFT on the non-custodial marketplace
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

  ;; PUBLIC-FUNCTION | List-In-Ustx: Lists NFT on the non-custodial marketplace
(define-public (list-in-ustx (id uint) (price uint))
  (let ((listing  {price: price}))
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)
    )
  )

;; PUBLIC-FUNCTION | Unlist-In-Ustx: Removes NFT listing from non-custodial marketplace
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)
    )
  )

;; PUBLIC-FUNCTION | Buy-In-Ustx: Purchases listed NFT from non-custodial marketplace
(define-public (buy-in-ustx (id uint))
  (let ((owner (unwrap! (nft-get-owner? jump id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (try! (stx-transfer? price tx-sender owner))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; PRIVATE-FUNCTION | Is-Owner: Checks if user owns a specific NFT
(define-private (is-owner (id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? jump id) false)))

;; READ-ONLY | Get-Contract-Owner: Gets contract owner wallet
(define-read-only (get-contract-owner)
  (var-get contract-owner))

;; READ-ONLY | Get-Owner: Returns the owner of a specific NFT
(define-read-only (get-owner (id uint))
  (nft-get-owner? jump id))

;; READ-ONLY | Get-Last-Token-Id: Returns the ID of the last NFT minted
(define-read-only (get-last-token-id)
  (var-get last-id))

  ;; READ-ONLY | Get-Bridge-Count: Returns the total number of NFTs bridged
  (define-read-only (get-bridge-count)
    (var-get bridge-count))

;; READ-ONLY | Get-Nft: Returns map data for a specific NFT
(define-read-only (get-nft (id uint))
  (map-get? nfts id))

;; READ-ONLY | Get-Token-Uri: Returns URI for a specific NFT
(define-read-only (get-token-uri (id uint))
  (get uri (map-get? nfts id)))

;; READ-ONLY | Get-Balance: Gets token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))
