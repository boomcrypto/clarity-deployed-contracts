;; title: Tokio:Vice by George Grant
;; version: v.1.0.0
;; author: Eriq Ferrari - eriq.btc
;; artist: George Grant - ggtv.btc
;; collection: Tokio:Vice by George Grant
;; description: Tokyo Vice represents an attempt at combining Asian and 
;;    Western Pop Culture / Art Deco with the style of Japanese artist 
;;    Hiroshi Nagai. Owning a piece of that collection will allow you 
;;    additional multipliers in our MEME APP Rewards system.
;; summary: Advanced SIP-009 NFT with built-in Marketplace
;; functions: Pricing, whitelist, and start block management, 
;;    Whitelisted users can mint during the time-locked free mint period,
;;    Minting supports for fungible tokens, Customizable collection limit, 
;;    Maximum supply enforced, Artist royalties enforced and customizable,
;;    Advanced built-in marketplace supports STX and fungible tokens, 
;;    Bulk actions enabled, Ownership transferrable
;; License: MIT

;; This contract implements the SIP-009 community-standard Non-Fungible Token trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait);; 

;; This contract use the SIP-010 community-standard Fungible Token trait
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) ;; 

;; SIP-010 transfer implementation
(define-private (transfer-ft (token-contract <sip-010-trait>) (amount uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer amount sender recipient none)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; NFT ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define the NFT's name
(define-non-fungible-token GGTV uint)

;; Keep track of the last minted token ID
(define-data-var last-token-id uint u0)

;; Contract variables
(define-data-var CONTRACT_OWNER (optional principal) (some tx-sender))
(define-data-var TREASURY principal tx-sender) ;; contract treasury
(define-data-var COLLECTION_LIMIT uint u200) ;; Limit to series of 200
(define-data-var START uint u0) ;; starting btc block
(define-data-var MINT_LIMIT uint u1) ;; max number of mints per wallet
(define-data-var FREEMINT_DURATION uint u144) ;; Free mint last 1 day 144 btc blocks

;; Contract constants
(define-constant TIMELOCK u50000) ;; blocks before unlock supply change
(define-constant MAX_SUPPLY u500) ;; collection will never exceed this supply

;; Errors
(define-constant ERR_OWNER_ONLY (err u1000))
(define-constant ERR_OWNERSHIP_RENOUNCED (err false))
(define-constant ERR_NOT_TOKEN_OWNER (err u1002))
(define-constant ERR_ALREADY_STARTED (err u2000))
(define-constant ERR_NOT_STARTED (err u2001))
(define-constant ERR_TOO_EARLY (err u2002))
(define-constant ERR_PAST_BLOCK (err u2003))
(define-constant ERR_SOLD_OUT (err u3000))
(define-constant ERR_FREEMINT_ENDED (err u3001))
(define-constant ERR_ALREADY_MINTED (err u3002))
(define-constant ERR_TOKEN_NOT_ALLOWED (err u3003))



;; Base uri string to fetch metadata
(define-data-var base-uri (string-ascii 80) "https://memecoinstx.com/metadata/GGTV/")

;; Contract mapping
(define-map BALANCE principal uint)
(define-map FREEMINTERS principal uint)
(define-map MINTED principal uint)
(define-map WHITELISTED_TOKEN principal uint) ;; Contract address and price

;; Show the current collection limit (timelocked).
(define-read-only (get-collection-limit)
  (ok (var-get COLLECTION_LIMIT))
)

;; SIP-009 function: Get the last minted token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP-009 function: Get link where token metadata is hosted
(define-read-only (get-token-uri (id uint))
  (ok (some (concat (var-get base-uri) (int-to-ascii id))))
)

;; SIP-009 function: Get the owner of a given token
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? GGTV id))
)

;; SIP-009 function: Transfer NFT token to another owner.
(define-public (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  )
  (let (
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  )
    (asserts! (is-eq tx-sender owner) ERR_NOT_TOKEN_OWNER)
    (map-delete MARKET id)
    ;; Increase the wallet balance
    (add-one recipient)
    ;; Decrease the wallet balance
    (remove-one sender)
    (print {
        topic: "transfer",
        sender: sender,
        recipient: recipient,
    })
    (nft-transfer? GGTV id sender recipient)
  )
)

;; Read-only. Show the owner address
(define-read-only (show-the-contract-owner)
  (ok (var-get CONTRACT_OWNER))
)

;; helper to check the contract caller is the owner
(define-private (is-admin)
  (let (
    (owner (var-get CONTRACT_OWNER))
  )
  (if (is-some owner)
    (is-eq contract-caller (unwrap-panic owner))
    false
  )
  )
)

;; Admin function to change the owner address
(define-public (admin-change-owner (address principal)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (var-set CONTRACT_OWNER (some address))
    (print {
        topic: "new owner",
        owner: address,
    })
    (ok true)
  )
)

;; Admin function to renounce the ownership
(define-public (admin-renounce-ownership) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (var-set CONTRACT_OWNER none)
    (print {
        topic: "ownership renounced",
        owner: none,
    })
    (ok true)
  )
)

;; Admin function to start the free mint
(define-public (admin-set-token-base-ui (uri (string-ascii 80))) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (var-set base-uri uri)
    (print {
        topic: "metadata-update",
        base-uri: uri,
        block: burn-block-height
    })
    (print { ;; common notification for metadata update
      notification: "token-metadata-update", 
      payload: { token-class: "nft", contract-id: (as-contract tx-sender) }
    })
    (ok true)
  )
)

;; Admin function to change the start for free mint
(define-public (admin-change-start (block uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (asserts! (or (< burn-block-height (var-get START)) (is-eq (var-get START) u0)) ERR_ALREADY_STARTED)
    (asserts! (< burn-block-height block) ERR_PAST_BLOCK)
    (var-set START block)
    (print {
        topic: "start",
        block: block
    })
    (ok true)
  )
)

;; Admin function to change the duration of the free mint
;; first you need to configure a start date or will fail
(define-public (admin-change-freemint-duration (blocks uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (asserts! (or (< burn-block-height (var-get START)) (is-eq (var-get START) u0)) ERR_ALREADY_STARTED)
    (var-set FREEMINT_DURATION blocks)
    (print {
        topic: "freemint duration",
        blocks: blocks
    })
    (ok true)
  )
)

;; Admin function to change the collection limit
;; Can be executed after one year from mint.
(define-public (admin-change-supply (supply uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (asserts! (and (> supply (var-get COLLECTION_LIMIT)) (<= supply MAX_SUPPLY)) ERR_OUT_OF_RANGE)
    (asserts! (> burn-block-height (+ (var-get START) TIMELOCK)) ERR_TOO_EARLY)
    (var-set COLLECTION_LIMIT supply)
    (print {
        topic: "supply extended",
        supply: supply
    })
    (ok true)
  )
)

;; Admin function to change the mints per wallet
(define-public (admin-change-mints-per-wallet (mints uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (var-set MINT_LIMIT mints)
    (print {
        topic: "new mint limit",
        mints: mints
    })
    (ok true)
  )
)

;; Admin function to change the treasury address
(define-public (admin-change-treasury (address principal)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (var-set TREASURY address)
    (print {
        topic: "new treasury address",
        treasury: address,
    })
    (ok true)
  )
)

;; Admin function to change the whitelisted tokens
(define-public (admin-add-token (address principal) (price uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (map-set WHITELISTED_TOKEN address price)
    (print {
        topic: "new token whitelisted",
        contract: address,
        price: price,
    })
    (ok true)
  )
)

;; Admin function to remove the whitelisted tokens
(define-public (admin-remove-token (address principal) ) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (map-delete WHITELISTED_TOKEN address )
    (print {
        topic: "token removed",
        contract: address,
    })
    (ok true)
  )
)

;; Admin function to add free minters
(define-public (admin-add-freeminters (freeminters (list 100 {address: principal, quantity: uint}))) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (fold check-err (map add-freeminter freeminters) (ok true))
  )
)

(define-private (add-freeminter (wallet {address: principal, quantity: uint}))
  (let (
    (address (get address wallet))
    (quantity (get quantity wallet))
  ) 
  (map-set FREEMINTERS address quantity)
  (print {
        topic: "added to freeminters",
        wallet: address,
        quantity: quantity,
    })
  (ok true)
  )
)

;; Admin airdrop
(define-public (admin-airdrop (recipient principal)) 
  ;; Create the new token ID by incrementing the last minted ID.
  (let ((id (+ (var-get last-token-id) u1)) )
    ;; Only the contract owner can airdrop a token.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) (var-get COLLECTION_LIMIT)) ERR_SOLD_OUT)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? GGTV id recipient))
    ;; Update the last minted token ID.
    (var-set last-token-id id)
    ;; Increase the wallet balance
    (add-one recipient)
    ;; Print mint information
    (print {
        topic: "airdrop",
        recipient: recipient,
        id: id,
        balance: (get-owner-balance recipient),
    })
    ;; Return a success status and the newly minted NFT ID.
    (ok id)
  )
)

;; Mint a new NFT for free
(define-public (freemint)
  ;; Create the new token ID by incrementing the last minted ID.
  (let ((id (+ (var-get last-token-id) u1)) (freemints (available-freemints)))
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) (var-get COLLECTION_LIMIT)) ERR_SOLD_OUT)
    (asserts! (>= burn-block-height (var-get START)) ERR_NOT_STARTED)
    (asserts! (< burn-block-height (+ (var-get FREEMINT_DURATION) (var-get START))) ERR_FREEMINT_ENDED)
    (asserts! (> (available-freemints) u0) ERR_ALREADY_MINTED)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? GGTV id contract-caller))
    (map-set FREEMINTERS contract-caller (- freemints u1))
    ;; Update the last minted token ID.
    (var-set last-token-id id)
    ;; Increase the wallet balance
    (add-one contract-caller)
    ;; Print mint information
    (print {
        topic: "freemint",
        recipient: contract-caller,
        id: id,
        balance: (get-owner-balance contract-caller),
        available_free_mints: (- freemints u1),
    })
    ;; Return a success status and the newly minted NFT ID.
    (ok id)
  )
)

;; Mint a new NFT.
(define-public (mint (token <sip-010-trait>))
  ;; Create the new token ID by incrementing the last minted ID.
  (let (
    (id (+ (var-get last-token-id) u1)) 
    (mints (available-mints))
    (price (get-token-price (contract-of token)))
    )
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) (var-get COLLECTION_LIMIT)) ERR_SOLD_OUT)
    (asserts! (> burn-block-height (+ (var-get FREEMINT_DURATION) (var-get START))) ERR_NOT_STARTED)
    (asserts! (> (available-mints) u0) ERR_ALREADY_MINTED)
    (asserts! (> price u0) ERR_TOKEN_NOT_ALLOWED)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? GGTV id contract-caller))
    (try! (transfer-ft token price contract-caller (var-get TREASURY)))
    (map-set MINTED contract-caller (+ (default-to u0 (map-get? MINTED contract-caller)) u1))
    ;; Update the last minted token ID.
    (var-set last-token-id id)
    ;; Increase the wallet balance
    (add-one contract-caller)
    ;; Print mint information
    (print {
        topic: "mint",
        recipient: contract-caller,
        id: id,
        balance: (get-owner-balance contract-caller),
        available_mints: (- mints u1),
    })
    ;; Return a success status and the newly minted NFT ID.
    (ok id)
  )
)

;; Read-only. Get the price for a specific token
(define-read-only (get-token-price (address principal)) 
  (default-to u0 (map-get? WHITELISTED_TOKEN address))
)

;; Read-only. Get an owner sfts balance
(define-read-only (get-owner-balance (address principal))
  (default-to u0 (map-get? BALANCE address))
)

;; Helper to get the remaining mints for the contract-caller
(define-read-only (available-mints)
  (- (var-get MINT_LIMIT) (default-to u0  (map-get? MINTED contract-caller)))
)

;; Helper to get the remaining free mints for the contract-caller
(define-read-only (available-freemints)
  (default-to u0 (map-get? FREEMINTERS contract-caller))
)

;; Helper to loop bulk actions
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

;; Helper to add one nft to owner balance
(define-private (add-one (address principal)) 
 (map-set BALANCE address (+ (get-owner-balance address) u1))
)

;; Helper to remove one nft to owner balance
(define-private (remove-one (address principal)) 
 (map-set BALANCE address (- (get-owner-balance address) u1))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Marketplace ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This contract implement commission trait
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission) ;; 

;; New Trait. This contract implement commission-ft trait
(use-trait commission-ft-trait 'SP39WYZ7BCDD4E7XSKDFVQSERXYTT9MEFE5683JGR.commission-ft-trait.commission-ft) ;;

;; Marketplace mapping
(define-map MARKET uint {price: uint, commission: principal, token: (optional principal),})
(define-map MARKETPLACE_TOKENS principal bool) 

;; Marketplace variables
(define-data-var ROYALTIES uint u300) ;; 3% royalties

;; Marketplace errors
(define-constant ERR_NOT_LISTED (err u4000))
(define-constant ERR_NOT_MINTED (err u4001))
(define-constant ERR_WRONG_COMMISSION (err u4002))
(define-constant ERR_OUT_OF_RANGE (err u4003))
(define-constant ERR_STX_ONLY (err u4004))
(define-constant ERR_WRONG_TOKEN (err u4005))

;; Admin function to change the artist royalties min u0 (no royaalties) max u1000 (10%)
(define-public (admin-change-royalties (royalties uint)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (asserts! (and (>= royalties u0) (< royalties u1000)) ERR_OUT_OF_RANGE)
    (var-set ROYALTIES royalties)
    (print {
        topic: "change royalties",
        royalties: royalties,
    })
    (ok true)
  )
)

;; Admin function to whitelist tokens for marketplace
(define-public (admin-add-token-marketplace (address principal)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (map-set MARKETPLACE_TOKENS address true)
    (print {
        topic: "added token for marketplace",
        token: address,
    })
    (ok true)
  )
)

;; Admin function to remove tokens for marketplace
(define-public (admin-remove-token-marketplace (address principal)) 
  (begin 
    ;; Only the contract owner can start the mint.
    (asserts! (is-admin) ERR_OWNER_ONLY)
    (map-delete MARKETPLACE_TOKENS address)
    (print {
        topic: "removed token for marketplace",
        token: address,
    })
    (ok true)
  )
)

;; Marketplace built-in functions

;; List a NFT in uSTX
(define-public (list-in-ustx (id uint) (price uint) (commission <commission-trait>))
  (let (
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  ) 
    (asserts! (is-eq tx-sender owner) ERR_NOT_TOKEN_OWNER)
    (map-set MARKET id {token: none, price: price, commission: (contract-of commission)})
    (print {
      topic: "list-in-ustx",
      id: id,
      price: price,
      commission: commission,
    })
    (ok true)
  )
)

;; Unlist a NFT
(define-public (unlist-in-ustx (id uint) )
  (let (
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  ) 
    (asserts! (is-eq tx-sender owner) ERR_NOT_TOKEN_OWNER)
    (map-delete MARKET id)
    (print {
      topic: "unlist-in-ustx",
      id: id,
    })
    (ok true)
  )
)

;; Buy a NFT in uSTX
(define-public (buy-in-ustx (id uint) (commission <commission-trait>) )
  (let (
    (listing (get-listing id))
    (price (get price listing))
    (token (get token listing))
    (royalties (var-get ROYALTIES))
    (royaltiesAmount (/ (* royalties price) u10000))
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  ) 
    (asserts! (> price u0) ERR_NOT_LISTED)
    (asserts! (is-none token) ERR_STX_ONLY)
    (asserts! (is-eq (contract-of commission) (get commission listing)) ERR_WRONG_COMMISSION)
    (if (> royalties u0) 
        (begin 
          (try! (stx-transfer? (- price royaltiesAmount) tx-sender owner))
          (try! (stx-transfer? royaltiesAmount tx-sender (var-get TREASURY)))
        )
        (try! (stx-transfer? price tx-sender owner))
    )
    (try! (contract-call? commission pay id price))
    (try! (nft-transfer? GGTV id owner tx-sender))
    (map-delete MARKET id)
    ;; Increase the wallet balance
    (add-one tx-sender)
    ;; Decrease the wallet balance
    (remove-one owner)
    (print {
      topic: "buy-in-ustx",
      id: id,
      price: price,
      commission: commission,
      seller: owner,
      taker: tx-sender,
    })
    (print {
        topic: "transfer",
        sender: owner,
        recipient: tx-sender,
    })
    (ok true)
  )
)

;; Marketplace bulk functions

;; List up to 100 NFTs in uSTX
(define-public (list-many (names (list 100 {id: uint, price: uint, commission: <commission-trait>})))
  (fold check-err (map list-single names) (ok true))
)

;; helper to list a single NFT in STX
(define-private (list-single (name {id: uint, price: uint, commission: <commission-trait>}))
  (list-in-ustx (get id name) (get price name) (get commission name))
)

;; Unlist up to 100 NFTs
(define-public (unlist-many (names (list 100 uint))) ;; valid for both stx and ft listing
  (fold check-err (map unlist-single names) (ok true))
)

;; helper to unlist a single NFT
(define-private (unlist-single (id uint))
  (unlist-in-ustx id)
)

;; Buy up to 100 NFTs in uSTX
(define-public (buy-many (names (list 100 {id: uint, commission: <commission-trait>})))
  (fold check-err (map buy-single names) (ok true))
)

;; helper to buy a single NFT in STX
(define-private (buy-single (name {id: uint, commission: <commission-trait>}))
  (buy-in-ustx (get id name) (get commission name))
)

;; Read-only. Get the listing data
(define-read-only (get-listing (id uint))
  (default-to {price: u0, commission: (as-contract tx-sender), token: none} (map-get? MARKET id))
)

;; Fungible token Marketplace built-in functions

;; List a NFT in FT (only allowed tokens)
(define-public (list-in-ft (id uint) (ft <sip-010-trait>) (price uint) (commission <commission-ft-trait>) )
  (let (
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  ) 
    (asserts! (is-eq tx-sender owner) ERR_NOT_TOKEN_OWNER)
    (asserts! (is-token-allowed (contract-of ft)) ERR_TOKEN_NOT_ALLOWED)
    (map-set MARKET id {
            token: (some (contract-of ft)), 
            price: price, 
            commission: (contract-of commission)
            })
    (print {
      topic: "list-in-ft",
      id: id,
      token: ft,
      price: price,
      commission: commission,
    })
    (ok true)
  )
)

;; Buy a NFT in FT (only allowed tokens)
(define-public (buy-in-ft (id uint) (ft <sip-010-trait>) (commission <commission-ft-trait>) )
  (let (
    (listing (get-listing id))
    (price (get price listing))
    (token (get token listing))
    (royalties (var-get ROYALTIES))
    (royaltiesAmount (/ (* royalties price) u10000))
    (owner (unwrap-panic (unwrap! (get-owner id) ERR_NOT_MINTED)))
  ) 
    (asserts! (> price u0) ERR_NOT_LISTED)
    (asserts! (is-eq (unwrap! token ERR_STX_ONLY) (contract-of ft)) ERR_WRONG_TOKEN)
    (asserts! (is-eq (contract-of commission) (get commission listing)) ERR_WRONG_COMMISSION)
    (if (> royalties u0) 
        (begin 
          (try! (transfer-ft ft (- price royaltiesAmount) tx-sender owner))
          (try! (transfer-ft ft royaltiesAmount tx-sender (var-get TREASURY)))
        )
        (try! (transfer-ft ft price tx-sender owner))
    )
    (try! (contract-call? commission pay id price ft))
    (try! (nft-transfer? GGTV id owner tx-sender))
    (map-delete MARKET id)
    ;; Increase the wallet balance
    (add-one tx-sender)
    ;; Decrease the wallet balance
    (remove-one owner)
    (print {
      topic: "buy-in-ft",
      id: id,
      price: price,
      token: token,
      commission: commission,
      seller: owner,
      taker: tx-sender,
    })
    (print {
        topic: "transfer",
        sender: owner,
        recipient: tx-sender,
    })
    (ok true)
  )
)

;; Fungible token Marketplace bulk functions

;; List up to 100 NFTs in FT (only allowed tokens)
(define-public (list-many-ft (names (list 100 {id: uint, token: <sip-010-trait>, price: uint, commission: <commission-ft-trait>})))
  (fold check-err (map list-single-ft names) (ok true))
)

;; helper to list a single NFT in FT (only allowed tokens)
(define-private (list-single-ft (name {id: uint, price: uint, token: <sip-010-trait>, commission: <commission-ft-trait>}))
  (list-in-ft (get id name) (get token name) (get price name) (get commission name))
)

;; Buy up to 100 NFTs in FT (only allowed tokens)
(define-public (buy-many-ft (names (list 100 {id: uint, token: <sip-010-trait>, commission: <commission-ft-trait>})))
  (fold check-err (map buy-single-ft names) (ok true))
)

;; helper to buy a single NFT in FT (only allowed tokens)
(define-private (buy-single-ft (name {id: uint, token: <sip-010-trait>, commission: <commission-ft-trait>}))
  (buy-in-ft (get id name) (get token name) (get commission name))
)

;; Read-only. Get the Marketplace allowed tokens
(define-read-only (is-token-allowed (address principal))
  (default-to false (map-get? MARKETPLACE_TOKENS address))
)

