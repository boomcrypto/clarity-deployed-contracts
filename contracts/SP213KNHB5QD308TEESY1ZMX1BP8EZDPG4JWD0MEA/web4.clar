;; Digital Land NFT Smart Contract
;; This file is part of Bitfari

;; This SC manages millions of virtual billboards projected via AR, distributed using geofences
;; or served as regular online content. The SC assigns a single owner per place, zoom level
;; and location, creating a web of natural auditors for location-based content, ads and messages.

;; The result is a directory of land + economically motivated owners, with a vested interest 
;; in display the most important content and reducing less relevant ones. Spam is also discouraged
;; due to TX fees, etc. 

;; Via hooks to publicly available local consensus sources, this contract also tokenizes 
;; Open Street Map places with links to Wikipedia and Wikidata, decentralizes geodata, polygonal data,
;; local performance statistics like foot traffic, regular and search ads,
;; user generated content and whitelisted content. 

;; Supports OSM relations, ways, nodes, etc. Provides hooks for multiple channels.
;; Multi-currency minting, integrated account system + ClubCash system for couponing.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SIP009 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP009 interface (mainnet)
(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

;; Constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.1") ;; Version string
(define-constant MANPAGE "https://www.bitfari.org/man/digital-land-nft-v01") ;; Smart Contract Manual

;; Errors
;; 
(define-constant ERR_NOT_AUTHORIZED (err u401)) ;;: Not authorized for the operation
(define-constant ERR_ALREADY_MINTED (err u402)) ;;: already registered
(define-constant ERR_CANT_MINT (err u403)) ;;:::::: minting not authorized, possible limit reached
(define-constant ERR_NOT_FOUND (err u404)) ;;:::::: no dl map entry
(define-constant ERR_STX_TRANSFER (err u405)) ;;::: non-sponsored purchase
(define-constant ERR_PRICE_TOO_LOW (err u406)) ;;:: tried to submit a tx with low or no fee
(define-constant ERR_PAYMENT_FAILURE (err u407)) ;; minting not paid
(define-constant ERR_SENDING_PAYMENT (err u408)) ;; error while sending the payment 
(define-constant ERR_LOW_BALANCE (err u409)) ;;:::: landlord deposited funds are insufficient 
(define-constant ERR_CANT_MAP_RP (err u410)) ;;:::: map insert error, check data
(define-constant ERR_CANT_MAP_PLACE (err u411)) ;;: map insert error, check data
(define-constant ERR_CANT_MAP_UTIL (err u412)) ;;;: error mapping transfer utility, check data
(define-constant ERR_UPDATING_BAL (err u413)) ;;::: failure updating balance, invalid coupon id 
(define-constant ERR_INVALID_ID (err u414)) ;;::::: invalid nft id 
(define-constant ERR_TOKEN_TRANSFER (err u415)) ;;: failure during a token transfer operation

;; Vars
;;

(define-data-var fari-nominal   uint u125)          ;;: FARI Nominal Price 
(define-data-var fari-discount  uint u2)            ;;: FARI Digital Land discount (eg divided by 2, etc)
(define-data-var last-id        uint u0)
(define-data-var fees           uint u2000000)      ;;: place registration fees
(define-data-var default-usd    uint u199)          ;;: default price in USD
(define-data-var default-fari   uint u140000000000) ;;: default price in FARI
(define-data-var default-stx    uint u450000000)    ;;: default price in STX
(define-data-var club1K         uint u1500)
(define-data-var club10K        uint u15000)
(define-data-var club100K       uint u150000)
(define-data-var club1M         uint u1500000)
(define-data-var json-root      (string-ascii 256) "https://api.bitfari.com/json/land/nft/")
(define-data-var ipfs-root      (string-ascii 256) "https://ipfs.io/Yh3erdsj/dland/land/nft/")

;; Register the digital land nft
;;
(define-non-fungible-token digital-land uint)

;; Place ownership, zoning, photos, itineraries and content all defined here
(define-map places { osm-id: uint, type: (string-ascii 10)} {
    ;; indexing set
    nft-id: uint, landlord: principal, json: (string-ascii 256),
    ;; real world mappings
    geodata: (string-ascii 256), polygon: (string-ascii 256),
    ;; user photos
    cover-photo: (string-ascii 256), dash-photo: (string-ascii 256),
    ;; additional addresses for payment/management
    management: principal, btc-treasury: (string-ascii 64),
    ;; key agency channels
    direct: (string-ascii 256), apps: (string-ascii 256),
    fari: (string-ascii 256), gov: (string-ascii 256),
    mil: (string-ascii 256), pol: (string-ascii 256),
    official: (string-ascii 256),
    ;; community channels
    channels:  (string-ascii 256), content: (string-ascii 256),
    ;; time sensitive ads/content
    itinerary: (string-ascii 256),
    ;; geo-search content
    search: (string-ascii 256),
    ;; web2 hooks
    web2: (string-ascii 256),
    ;; ambient social channels
    social: (string-ascii 256),
    ;; shareable place statistics 
    statistics: (string-ascii 256)})

;; Metaverse to real world mapping 
(define-map redpill { id: uint } { json: (string-ascii 256) }) 

;; Utility mapping for transfers 
(define-map transfer-utility { id: uint } { osm-id: uint, type: (string-ascii 10), json: (string-ascii 256) }) 

;; Payments - has minting for this place been paid?
(define-map payments { osm-id: uint, type: (string-ascii 10), landlord: principal } { amount: uint, paid: bool })

;; Bank Teller simul - landlord balance gained thru incentives, coupons, airdrops, offers, etc.
(define-map bank-teller { landlord: principal } { balance: uint }) 

;; FARI:: Land valuations in FARI
(define-map valuation-fari { osm-id: uint, type: (string-ascii 10) } { price-fari: uint }) 

;; STX:: Land valuations in STX
(define-map valuation-stx { osm-id: uint, type: (string-ascii 10) } { price-stx: uint }) 

;; USD:: Land valuations in USD
(define-map valuation-usd { osm-id: uint, type: (string-ascii 10) } { price-usd: uint }) 

;; SIP009

;; SIP009: Transfer the token to a specified principal
 (define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (if
    (and 
      (is-eq (some tx-sender) (nft-get-owner? digital-land token-id))
      (is-eq owner tx-sender))
    (map-transfer token-id owner recipient)
    ERR_TOKEN_TRANSFER))

;; SIP009: Get the owner of the specified token ID
 (define-read-only (get-owner (token-id uint))
   (ok (nft-get-owner? digital-land token-id)))
 
;; SIP009: Get the last token ID
 (define-read-only (get-last-token-id)
   (ok (var-get last-id)))

;; SIP009: Get the token URI
 (define-read-only (get-token-uri (token-id uint))
  (ok (get json (map-get? redpill {id: token-id}))))

;; Private functions
;;
(define-private (is-owner (token-id uint) (landlord principal))
   (is-eq landlord (unwrap! (nft-get-owner? digital-land token-id) false)))

;; Insert maps 
;;

;; Inserts a new real to metaverse index entry
;; @returns bool  
(define-private (insert-rp (id uint) (json (string-ascii 256)))
  (map-insert redpill { id: id } { json: json }))

;; Inserts a new place entry
;; @returns bool 
(define-private (insert-place 
                (osm-id uint) (type (string-ascii 10))
                (nft-id uint) (landlord principal) (json (string-ascii 256)) 
                (geodata (string-ascii 256)) (polygon (string-ascii 256)) 
                (cover-photo (string-ascii 256)) (dash-photo (string-ascii 256)) (management principal)
                (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
                (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
                (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
                (channels  (string-ascii 256)) (content (string-ascii 256))
                (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
                (social (string-ascii 256)) (statistics (string-ascii 256)))

    (map-insert places 
            { osm-id: osm-id, type: type }
            { nft-id: nft-id, landlord: landlord, json: json, 
            geodata: geodata, polygon: polygon, cover-photo: cover-photo,
            dash-photo: dash-photo, management: management,
            btc-treasury: btc-treasury, direct: direct, apps: apps,
            fari: fari, gov: gov, mil: mil, pol: pol,
            official: official, channels: channels, content: content,
            itinerary: itinerary, search: search,
            web2: web2, social: social, statistics: statistics }))

;; Read-only functions
;;

;; Returns version of the 
;; digital land nft contract
;; @returns string-ascii
(define-read-only (get-version) 
    VERSION)

;; Returns the smart contract 
;; manpage - a manual
;; @returns url/string-ascii
(define-read-only (get-man) 
    MANPAGE)

;; Get min fees 
;; Returns minimum fees
;; @returns uint 
(define-read-only (get-fees)
    (var-get fees))

;; Get Nominal Price - FARI 
;; Returns nominal Fari/USD conversion 
;; @returns uint 
(define-read-only (get-fari-nominal)
    (var-get fari-nominal))

;; Get Discount - FARI 
;; Returns nominal discount for Fari purchases 
;; @returns a percentage in uint 
(define-read-only (get-fari-discount)
    (var-get fari-discount))

;; Get club coupon values
;; to support flex redemption
;; @returns uint 
(define-read-only (get-club1K)
    (var-get club1K))

(define-read-only (get-club10K)
    (var-get club10K))

(define-read-only (get-club100K)
    (var-get club100K))        

(define-read-only (get-club1M)
    (var-get club1M))

;; Get the URI mapped to an ID
;; @returns json uri 
(define-read-only (get-by-id (id uint))
  (map-get? redpill {id: id}))

;; Get place details from a type + osmID
;; @returns map 
(define-read-only (get-place (osm-id uint) (type (string-ascii 10)))
  (map-get? places {osm-id: osm-id, type: type}))

;; Get the place landlord from a type + osmID
;; @returns map 
(define-read-only (get-landlord (osm-id uint) (type (string-ascii 10)))
 (get landlord (map-get? places {osm-id: osm-id, type: type})))

;; Get payment info
;; @returns map 
(define-read-only (get-payment (landlord principal) (osm-id uint) (type (string-ascii 10)))
  (map-get? payments {osm-id: osm-id, type: type, landlord: landlord}))

;; Asset specific public functions
;;

;; Set Nominal Price 
;; @returns uint 
(define-public (set-fari-nominal (new-nominal uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set fari-nominal new-nominal))))  

;; Set Nominal Discount Factor 
;; @returns uint 
(define-public (set-nominal-discount (new-discount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set fari-discount new-discount))))  

;; Set fees 
;; Returns minimum fees
;; @returns uint 
(define-public (set-fees (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set fees new-fee))))  

;; Set default prices 
;; Can be overriden via premium prices
;; @returns uint 

;; FARI
(define-public (set-default-fari (new-fari uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set default-fari new-fari))))

;; STX
(define-public (set-default-stx (new-stx uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set default-stx new-stx))))

;; USD
(define-public (set-default-usd (new-usd uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set default-usd new-usd))))

;; Set coupon values 
;; Returns redemption values
;; @returns uint 

;; 1K
(define-public (set-club1K (new-1K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club1K new-1K)))) 

;; 10K
(define-public (set-club10K (new-10K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club10K new-10K)))) 

;; 100K
(define-public (set-club100K (new-100K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club100K new-100K)))) 

;; 1M
(define-public (set-club1M (new-1M uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club1M new-1M)))) 

;; Roots
;; Places can be minted to Bitfari
;; or to IPFS for full decentralization

;; Minting and crystallization are two separate
;; processes. Minting zones, claims and set ups the asset

;; Crystallization distributes a minted, review and curated
;; asset to join the network. 

;; Minting is required. Crystallization is optional.


;; Set root 
;; Update NFT root dir for jsons
;; @returns uint 
(define-public (set-root (new-root (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set json-root new-root))))  

;; Set ipfs/web3 root 
;; Update NFT ipfs root dir for jsons
;; @returns uint 
(define-public (set-ipfs-root (new-ipfs (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set ipfs-root new-ipfs))))  

;; Re-zoning places
;;

;; Updates a place
;; @returns bool 
(define-public (update-place (osm-id uint) (type (string-ascii 10))
                (nft-id uint) (landlord principal) (json (string-ascii 256)) 
                (geodata (string-ascii 256)) (polygon (string-ascii 256)) 
                (cover-photo (string-ascii 256)) (dash-photo (string-ascii 256)) (management principal)
                (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
                (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
                (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
                (channels  (string-ascii 256)) (content (string-ascii 256))
                (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
                (social (string-ascii 256)) (statistics (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-set places { osm-id: osm-id, type: type }
            { nft-id: nft-id, landlord: landlord, json: json,
            geodata: geodata, polygon: polygon, cover-photo: cover-photo,
            dash-photo: dash-photo, management: management, btc-treasury: btc-treasury,
            direct: direct, apps: apps, fari: fari, gov: gov, mil: mil, pol: pol,
            official: official, channels: channels, content: content, itinerary: itinerary,
            search: search, web2: web2, social: social, statistics: statistics }))))

;; Transfers a place
;; @returns bool 

(define-private (map-transfer (token-id uint) (owner principal) (recipient principal))
  (let 
  (
  (osm-x (get-osm token-id))
  (type-x (get-type token-id))
  )

  (map-set places { osm-id: osm-x, type: type-x }
      { nft-id: token-id, landlord: recipient, json: (get-json token-id),
      geodata: (get-geodata osm-x type-x), polygon: (get-polygon osm-x type-x),
      cover-photo: (get-cover osm-x type-x), dash-photo: (get-dash osm-x type-x), 
      management: recipient, btc-treasury: "none", direct: (get-direct osm-x type-x),
      apps: (get-apps osm-x type-x), fari: (get-fari osm-x type-x),
      gov: (get-gov osm-x type-x), mil: (get-mil osm-x type-x), pol: (get-pol osm-x type-x),
      official: (get-official osm-x type-x), channels: (get-geodata osm-x type-x),
      content: (get-content osm-x type-x), itinerary: (get-itinerary osm-x type-x), 
      search: (get-search osm-x type-x), web2: (get-web2 osm-x type-x),
      social: (get-social osm-x type-x), statistics: (get-stats osm-x type-x) })
  
   (nft-transfer? digital-land token-id owner recipient)))

;; Get Land Keys Before a Transfer

;; OSM ID
;; ;; @returns uint
(define-read-only (get-osm (token-id uint))
  (default-to u0 (get osm-id (map-get? transfer-utility { id: token-id }))))

;; Type
;; ;; @returns string ascii 10
(define-read-only (get-type (token-id uint))
 (default-to "none" (get type (map-get? transfer-utility { id: token-id }))))

;; JSON
;; ;; @returns json/string ascii 256
(define-read-only (get-json (token-id uint))
  (default-to "none" (get json (map-get? transfer-utility { id: token-id }))))

;; BURNING AND DELETING
;;
;; Burn deletes a token, removing it from the wallet
;; this is non-reversible

;; Three map delete utilities are provided to remove
;; orphan records created by token burning operations.

;; These functions are meant to be executed in tandem
;; by an authorized client.

;; Burns a place - in case of demolitions, 
;; disasters, new-zoning, catalog updates
;; troubleshooting, and similar reasons
;; @returns bool or err
(define-public (burn (token-id uint))
  (begin
    (if (is-owner token-id tx-sender)
      (match (nft-burn? digital-land token-id tx-sender)
        success (ok true)
        error (err error)) ERR_NOT_AUTHORIZED)))

;; Delete a listing in the place map
;; @returns bool 
(define-public (delete-place (osm-id uint) (type (string-ascii 10)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-delete places { osm-id: osm-id, type: type }))))

;; Delete a listing in the redpill index
;; @returns bool 
(define-public (delete-redpill (token-id uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-delete redpill { id: token-id }))))

;; Delete transfer utility records
;; @returns bool 
(define-public (delete-transfer-utility (token-id uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-delete transfer-utility { id: token-id }))))

;; ;; Reedem coupons
;; ;; Assigns a balance to coupon holders
;; ;; upon NFT transfer
;; ;; @returns response bool 

(define-public (redeem-1K (token-id uint))
(if ( > token-id u0)
  (begin
  (try! (contract-call? .club-1k transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club1K))})
  (ok true)) ERR_INVALID_ID))

(define-public (redeem-10K (token-id uint))
(if ( > token-id u0)
  (begin
 (try! (contract-call? .club-10k transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club10K))})
  (ok true)) ERR_INVALID_ID))

(define-public (redeem-100K (token-id uint))
(if ( > token-id u0)
  (begin    
  (try! (contract-call? .club-100k transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club100K))})
  (ok true)) ERR_INVALID_ID))

(define-public (redeem-1M (token-id uint))
(if ( > token-id u0)
  (begin
  (try! (contract-call? .club-1M transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club1M))})
  (ok true)) ERR_INVALID_ID))

;; Payment and registration
;;

;; Set Land Valuation
;; ;; FARI :::: land valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns bool 
(define-public (set-fari-price (osm-id uint) (type (string-ascii 10)) (price-fari uint))
  (begin
  (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
  (map-set valuation-fari { osm-id: osm-id, type: type } { price-fari: price-fari })
  (ok true)))

;; ;; STX :::: land valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns bool 
(define-public (set-stx-price (osm-id uint) (type (string-ascii 10)) (price-stx uint))
  (begin
  (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
  (map-set valuation-stx { osm-id: osm-id, type: type } { price-stx: price-stx })
  (ok true))) 

;; Get Roots

;; Web3 IPFS
;; @returns string-ascii 
(define-read-only (get-ipfs-root)
  (var-get ipfs-root))
 
;; Web2 JSON
;; @returns string-ascii 
(define-read-only (get-json-root)
  (var-get json-root))

;; Get Hooks

;; Get Place Geodata
;; @returns string-ascii/url pointing to geodata json
(define-read-only (get-geodata (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get geodata (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place Polygons for 3d Mapping
;; @returns string-ascii/url pointing to polygon json
(define-read-only (get-polygon (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get polygon (map-get? places {osm-id: osm-id, type: type }))))

;; Get Cover Photo
;; @returns string-ascii/url pointing to a cover photo from whitelisted sources
(define-read-only (get-cover (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get cover-photo (map-get? places {osm-id: osm-id, type: type }))))

;; Get Dashboard Photo
;; @returns string-ascii/url pointing to the dashboard photo from whitelisted sources
(define-read-only (get-dash (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get dash-photo (map-get? places {osm-id: osm-id, type: type }))))

;; Gets the Management STX Principal
;; @returns principal - account for non-custodial place management
(define-read-only (get-management (osm-id uint) (type (string-ascii 10)))
 (default-to tx-sender (get management (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place BTC Treasury
;; @returns string-ascii of a btc address (any type)
(define-read-only (get-btc-treasury (osm-id uint) (type (string-ascii 10)))
  (default-to "none" (get btc-treasury (map-get? places {osm-id: osm-id, type: type }))))

;; Get Direct Ads
;; @returns string-ascii pointing to json of direct ads
(define-read-only (get-direct (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get geodata (map-get? places {osm-id: osm-id, type: type }))))

;; Get Local Apps
;; @returns string-ascii pointing to json of apps promoted at the place
(define-read-only (get-apps (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get apps (map-get? places {osm-id: osm-id, type: type }))))

;; Get the Fari Guide
;; @returns string-ascii pointing to a Bitfari auto generated local guide json
(define-read-only (get-fari (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get fari (map-get? places {osm-id: osm-id, type: type }))))

;; Get Gov Content/Ads
;; @returns string-ascii pointing to your local government content json
;; government ads/content is whitelisted 
(define-read-only (get-gov (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get gov (map-get? places {osm-id: osm-id, type: type }))))

;; Get Military Content/Ads
;; @returns string-ascii pointing to your local military content json
;; military content is whitelisted, this can help in disaster situations
;; war zones, emergencies and serves as a geoweb for military ops
(define-read-only (get-mil (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get mil (map-get? places {osm-id: osm-id, type: type }))))

;; Get Police Content/Ads
;; @returns string-ascii pointing to your local police content json
;; local police content is whitelisted, this can help in emergencies,
;; lock downs, public disturbances and serves as a geoweb for police ops
(define-read-only (get-pol (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get pol (map-get? places {osm-id: osm-id, type: type }))))

;; Gets Official Content
;; @returns string-ascii pointing to local official whitelisted content json
(define-read-only (get-official (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get official (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place AR Channels
;; @returns string-ascii pointing to a json for AR channels 
(define-read-only (get-channels (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get channels (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place Content
;; @returns string-ascii pointing to a json of user generated content 
(define-read-only (get-content (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get content (map-get? places {osm-id: osm-id, type: type }))))

;; Gets the Advertisement Itinerary for the Place
;; @returns string-ascii pointing to a json of ad itineraries
(define-read-only (get-itinerary (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get itinerary (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place Search
;; @returns string-ascii pointing to a json of local search ads
(define-read-only (get-search (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get search (map-get? places {osm-id: osm-id, type: type }))))

;; Get Place Web2 Hooks
;; @returns string-ascii pointing to a json containing 
;; a list of legacy/web2 services connected to the place 
(define-read-only (get-web2 (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get web2 (map-get? places {osm-id: osm-id, type: type }))))

;; Get Ambient Social
;; @returns string-ascii pointing to a json listing 
;; ambient social networking services
(define-read-only (get-social (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get social (map-get? places {osm-id: osm-id, type: type }))))

;; Get Local Stats
;; @returns string-ascii pointing to stats json
(define-read-only (get-stats (osm-id uint) (type (string-ascii 10)))
  (default-to "" (get statistics (map-get? places {osm-id: osm-id, type: type }))))
 
;; Get Default Prices
;; ;; @returns uint 

;; FARI
(define-read-only (get-default-fari)
  (var-get default-fari))

;; STX
(define-read-only (get-default-stx)
  (var-get default-stx))

;; USD
(define-read-only (get-default-usd)
  (var-get default-usd))

;; Get Land Valuation
;; ;; FARI :::: land valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-fari (osm-id uint) (type (string-ascii 10)))
 (default-to (var-get default-fari) (get price-fari (map-get? valuation-fari { osm-id: osm-id, type: type }))))

;; ;; STX :::: land valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-stx (osm-id uint) (type (string-ascii 10)))
 (default-to (var-get default-stx) (get price-stx (map-get? valuation-stx { osm-id: osm-id, type: type })))) 

;; ;; USD :::: land valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-usd (osm-id uint) (type (string-ascii 10)))
 (default-to (var-get default-usd) (get price-usd (map-get? valuation-usd { osm-id: osm-id, type: type })))) 

;; ;; Get Balance :: check USD balance after NFT deposits
;; ;; @returns uint 
(define-read-only (get-usd-balance)
  (default-to u0 (get balance (map-get? bank-teller { landlord: tx-sender })))) 

;; Minting

;; Mints a place
;; @returns bool 
 (define-private (mint 
                 (osm-id uint) (type (string-ascii 10)) (landlord principal) 
                 (json (string-ascii 256)) (geodata (string-ascii 256))
                 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
                 (dash-photo (string-ascii 256)) (management principal)
                 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
                 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
                 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
                 (channels  (string-ascii 256)) (content (string-ascii 256))
                 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
                 (social (string-ascii 256)) (statistics (string-ascii 256)))
 
        (let ((next-id (+ u1 (var-get last-id))))

        ;; Check osm id + type is not registered
        (asserts! (is-none (map-get? places {osm-id: osm-id, type: type })) ERR_ALREADY_MINTED)
        ;; Data structure to connect real ids with osm ids
        (asserts! (map-insert redpill 
            { id: next-id } 
            { json: json }) ERR_CANT_MAP_RP)

        ;; Utility Map for transfers  
        (asserts! (map-insert transfer-utility 
            { id: next-id } 
            { osm-id: osm-id, type: type, json: json }) ERR_CANT_MAP_UTIL)

        ;; To avoid double entries, keep straightforward ownership records, etc.
        (asserts! (map-insert places 
            { osm-id: osm-id, type: type } 
            { nft-id: next-id, landlord: landlord, json: json,
            geodata: geodata, polygon: polygon, cover-photo: cover-photo,
            dash-photo: dash-photo, management: management,
            btc-treasury: btc-treasury, direct: direct, apps: apps,
            fari: fari, gov: gov, mil: mil, pol: pol,
            official: official, channels: channels, content: content,
            itinerary: itinerary, search: search,
            web2: web2, social: social, statistics: statistics }) ERR_CANT_MAP_PLACE)
 
        ;; Finally, mint after asserts and children record creation
        ;; a new id is assigned to this token
        (match (nft-mint? digital-land next-id landlord)
            success
            (begin
            (var-set last-id next-id)       
            (ok true))
            error (err error))))
  
;; ;; STX mint
;; ;; @returns bool 
(define-public (stx-mint (osm-id uint) (type (string-ascii 10)) (landlord principal)
 (amount-stx uint) (json (string-ascii 256)) (geodata (string-ascii 256))
 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
 (dash-photo (string-ascii 256)) (management principal)
 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
 (channels  (string-ascii 256)) (content (string-ascii 256))
 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
 (social (string-ascii 256)) (statistics (string-ascii 256)))
  (if ( >= amount-stx (get-price-stx osm-id type))
  (begin    
  (try! (stx-transfer? amount-stx tx-sender CONTRACT_OWNER))
  (try! (as-contract (mint osm-id type landlord json
                           geodata polygon cover-photo  
                           dash-photo management  
                           btc-treasury direct apps fari  
                           gov mil pol official channels   
                           content itinerary search web2  
                           social statistics )))
  (ok true)) ERR_PRICE_TOO_LOW))

;; ;; Club mint. This mints via Club NFT Coupons
;; ;; Only pays network fees, rest sponsored by coupons
;; ;; @returns bool 
(define-public (club-mint (osm-id uint) (type (string-ascii 10))
 (landlord principal) (json (string-ascii 256)) (geodata (string-ascii 256))
 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
 (dash-photo (string-ascii 256)) (management principal)
 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
 (channels  (string-ascii 256)) (content (string-ascii 256))
 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
 (social (string-ascii 256)) (statistics (string-ascii 256)))
  (begin
   (asserts! ( > (get-usd-balance) (get-price-usd osm-id type)) (err ERR_LOW_BALANCE))
   (unwrap-panic (stx-transfer? (var-get fees) tx-sender CONTRACT_OWNER))
   
    (map-insert payments 
        { osm-id: osm-id, type: type, landlord: tx-sender } 
        { amount: (var-get fees), paid: true })
    (map-set bank-teller { landlord: tx-sender } 
        {balance: (- (get-usd-balance) (get-price-usd osm-id type)) })
    (unwrap-panic (as-contract (mint  osm-id type landlord json
                                      geodata polygon cover-photo  
                                      dash-photo management  
                                      btc-treasury direct apps fari  
                                      gov mil pol official channels   
                                      content itinerary search web2  
                                      social statistics )))
    (ok true)))

;; ;; FARI mint
;; ;; @returns bool 
(define-public (fari-mint (osm-id uint) (type (string-ascii 10)) (landlord principal)
 (amount-fari uint) (json (string-ascii 256)) (geodata (string-ascii 256))
 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
 (dash-photo (string-ascii 256)) (management principal)
 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
 (channels  (string-ascii 256)) (content (string-ascii 256))
 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
 (social (string-ascii 256)) (statistics (string-ascii 256)))
  (if ( >= amount-fari (get-price-fari osm-id type))
  (begin  
  (try! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn
                        transfer amount-fari tx-sender CONTRACT_OWNER none))
  (try! (as-contract (mint osm-id type landlord json
                           geodata polygon cover-photo  
                           dash-photo management  
                           btc-treasury direct apps fari  
                           gov mil pol official channels   
                           content itinerary search web2  
                           social statistics )))
  (ok true)) ERR_PRICE_TOO_LOW))

;; ;; FARI nominal pool mint
;; ;; @returns bool 
(define-public (fari-nominal-mint (osm-id uint) (type (string-ascii 10)) (landlord principal)
 (amount-fari uint) (json (string-ascii 256)) (geodata (string-ascii 256))
 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
 (dash-photo (string-ascii 256)) (management principal)
 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
 (channels  (string-ascii 256)) (content (string-ascii 256))
 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
 (social (string-ascii 256)) (statistics (string-ascii 256)))

 (if  (>= ( * amount-fari (get-fari-nominal)) 
              (to-uint ( / (to-int (get-price-usd osm-id type)) (to-int (get-fari-discount))))) 
  (begin
  (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)

  (try! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn
                        transfer amount-fari tx-sender CONTRACT_OWNER none))
  (try! (as-contract (mint osm-id type landlord json
                           geodata polygon cover-photo  
                           dash-photo management  
                           btc-treasury direct apps fari  
                           gov mil pol official channels   
                           content itinerary search web2  
                           social statistics )))
  (ok true)) ERR_PRICE_TOO_LOW))
