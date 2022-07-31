

;; SIP009 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP009 interface (mainnet)
;;(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

;; Constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.1") ;; version string
(define-constant MANPAGE "https://www.bitfari.org/man/simple-ad-v01") ;; smart contract manual

;; Errors
;; 

(define-constant ERR_NOT_AUTHORIZED (err u401)) ;;: not authorized for the operation
(define-constant ERR_ALREADY_MINTED (err u402)) ;;: already registered
(define-constant ERR_CANT_MINT (err u403)) ;;:::::: minting not authorized, possible limit reached
(define-constant ERR_NOT_FOUND (err u404)) ;;:::::: no ad map entry
(define-constant ERR_STX_TRANSFER (err u405)) ;;::: non-sponsored purchase
(define-constant ERR_PRICE_TOO_LOW (err u406)) ;;:: tried to submit a tx with low or no fee
(define-constant ERR_PAYMENT_FAILURE (err u407)) ;; minting not paid
(define-constant ERR_SENDING_PAYMENT (err u408)) ;; error while sending the payment 
(define-constant ERR_CANT_MAP_AD (err u411)) ;;: map insert error, check data
(define-constant ERR_INVALID_ID (err u414)) ;;::::: invalid nft id 
(define-constant ERR_TOKEN_TRANSFER (err u415)) ;;: failure during a token transfer operation

;; Vars
;;

(define-data-var last-id        uint u0)
(define-data-var fees           uint u2000)      ;;: ad registration fees
(define-data-var min-usd        uint u1)            ;;: default price in USD
(define-data-var min-fari       uint u140000) ;;: default price in FARI
(define-data-var min-stx        uint u450)    ;;: default price in STX
(define-data-var json-root      (string-ascii 256) "https://api.bitfari.com/json/ads/")
(define-data-var ipfs-root      (string-ascii 256) "https://ipfs.io/Yh3erdsj/ads/")

;; Register a simple ad nft
;;
(define-non-fungible-token simple-ad uint)

;; Simple ad standard definition  
(define-map ads { id: uint } {
advertiser: principal, json: (string-ascii 256),
;; The address of the network, for example
;; classifieds.btc, billboards.btc, or malls.btc 
network: principal, title: (string-ascii 256), copy: (string-ascii 512),

;; One url for the art image itself, 
;; another for a desired customer landing page 
;; This even helps billboard ads, as customers see
;; a double feature of the ad on their wallets
art-url:  (string-ascii 256), click-url: (string-ascii 256),

;; Aural links help the visually tourists, immigrants 
;; and the visually impaired navigate cities better
aural-url: (string-ascii 256), 

;; Action links help assess the success of CPA campaigns
;; while the action code helps monitor sucess/error conditions
action-url: (string-ascii 256), action-code: (string-ascii 64), 

;; Campaign Targeting Settings
;; demographic targeting 
demo: (string-ascii 256),  
;; ethnographic targeting 
ethno: (string-ascii 256), 
;; psycographic targeting
psycho: (string-ascii 256),  
;; behavioral targeting
behavioral: (string-ascii 256),
;; crypto targeting, ownership of tokens, balances, etc
crypto: (string-ascii 256), 

;; future targeting -- ad holder for future modalities
;; this field is a json
future: (string-ascii 256),

;; geotargeting

;; geolocations is an array of Open Stree Map 
;; locations where the ad will be distributed
;; this field is a json
geolocations: (string-ascii 256),

;; geosettings
osm-id: uint, osm-type: (string-ascii 32),
radius: uint,   

;; ad booking

;; booking for real screens/billboards
;; array of Bitfari screens
;; where the ad will be distributed
;; this field is a json pointing to a 
;; collection of screens/billboards
screens: (string-ascii 256),

;; auditing
audited: bool, red-flag: bool, 

;; budget and payments
;; The remaining budget is updated daily
;; and is used for distributed booking in the case
;; of an ad-serving screen disconnection
budget: uint,

;; Promote ad showing to certain groups  
;; and remove the ads for certain keywords. (+ positive keywords, - negative keywords)
;; Please note that these are billboard/smart screen ads,
;; online ads have many more filtering/targeting options
keywords: (string-ascii 1024) })

;; A campaign might run for as little as 
;; one hour or years if the advertiser wishes 
(define-map schedules { ad-id: uint } 
                      { start-date: (string-ascii 16), start-time: (string-ascii 16)
                      , end-date: (string-ascii 16), end-time: (string-ascii 16)})
 
;; SIP009

;; SIP009: Transfer the token to a specified principal
 (define-public (transfer (ad-id uint) (owner principal) (recipient principal))
  (if
    (and 
      (is-eq (some tx-sender) (nft-get-owner? simple-ad ad-id))
      (is-eq owner tx-sender))
    (map-transfer ad-id owner recipient)
    ERR_TOKEN_TRANSFER))

;; SIP009: Get the owner of the specified token ID
 (define-read-only (get-owner (id uint))
   (ok (nft-get-owner? simple-ad id)))
 
;; SIP009: Get the last token ID
 (define-read-only (get-last-ad-id)
   (ok (var-get last-id)))

;; SIP009: Get the token URI
 (define-read-only (get-token-uri (ad-id uint))
  (ok (get json (map-get? ads {id: ad-id}))))

;; Private functions
;;
(define-private (is-owner (id uint) (advertiser principal))
   (is-eq advertiser (unwrap! (nft-get-owner? simple-ad id) false)))

;; Insert maps 
;;

;; Inserts a new ad entry
;; @returns bool 
(define-public (insert-ad (id uint)  
                (advertiser principal) (json (string-ascii 256)) 
                (network principal) (title (string-ascii 256)) 
                (copy (string-ascii 512)) (art-url (string-ascii 256))  
                (click-url (string-ascii 256)) (aural-url (string-ascii 256))
                (audited bool) (red-flag bool) (geolocations (string-ascii 256))
                (osm-id uint) (osm-type (string-ascii 32)) (radius uint)
                (action-url (string-ascii 256)) (action-code (string-ascii 64))
                (demo (string-ascii 256)) (behavioral (string-ascii 256)) 
                (ethno (string-ascii 256)) (psycho (string-ascii 256)) (crypto (string-ascii 256)) 
                (future (string-ascii 256)) (screens (string-ascii 256)) (budget uint) 
                (keywords (string-ascii 1024)))

    (begin

    (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
 
    (ok (map-insert ads 
            { id: id }
            { advertiser: advertiser , json: json, 
            network: network, title: title, copy: copy,
            art-url: art-url, click-url: click-url,
            aural-url: aural-url, audited: audited, red-flag: red-flag,
            geolocations: geolocations, osm-id: osm-id, osm-type: osm-type, radius: radius,
            action-url: action-url, action-code: action-code, demo: demo, behavioral: behavioral,
            ethno: ethno, psycho: psycho, future: future, crypto: crypto,
            screens: screens, budget: budget, keywords: keywords }))))

;; Read-only functions
;;

;; Returns version 
;; of the smart contract
;; @returns string-ascii
(define-read-only (get-version) 
    VERSION)

;; Returns the smart contract 
;; manpage - a manual
;; @returns url/string-ascii
(define-read-only (get-man) 
    MANPAGE)

;;  Getters
;; ------------------------------------------------------------------------------------------------------------------

;; Get the last token ID
(define-read-only (get-ad-id)
  (ok (var-get last-id)))

;; Get the advertiser associated with this ad
(define-read-only (get-advertiser (id uint))
  (default-to CONTRACT_OWNER (get advertiser (map-get? ads { id: id }))))

;; Get the title associated with this ad
(define-read-only (get-title (id uint))
   (default-to "" (get title (map-get? ads { id: id }))))

;; Get the copy associated with this ad
(define-read-only (get-copy (id uint))
   (default-to "" (get copy (map-get? ads { id: id }))))

;; Get the network associated with this ad
(define-read-only (get-network (id uint))
   (default-to CONTRACT_OWNER (get network (map-get? ads { id: id }))))

;; Get red flags, if any
(define-read-only (get-red-flag (id uint))
   (default-to false (get red-flag (map-get? ads { id: id }))))

;; Get audited status 
(define-read-only (get-audited (id uint))
   (default-to false (get audited (map-get? ads { id: id }))))

;; Get osm id, if applicable
(define-read-only (get-osm-id (id uint))
   (default-to u0 (get osm-id (map-get? ads { id: id }))))  

;; Get osm type, if applicable
(define-read-only (get-osm-type (id uint))
   (default-to "way" (get osm-type (map-get? ads { id: id }))))  

;; Get radius, if applicable
(define-read-only (get-radius (id uint))
   (default-to u1 (get radius (map-get? ads { id: id }))))  

;; Get action url, if applicable
(define-read-only (get-action-url (id uint))
   (default-to "" (get action-url (map-get? ads { id: id }))))  

;; Get action code, if applicable
(define-read-only (get-action-code (id uint))
   (default-to "" (get action-code (map-get? ads { id: id })))) 

;; Get demographic information
(define-read-only (get-demo (id uint))
   (default-to "" (get demo (map-get? ads { id: id }))))  

;; Get behavioral information
(define-read-only (get-behavioral (id uint))
   (default-to "" (get behavioral (map-get? ads { id: id }))))  

;; Get crypto information
(define-read-only (get-crypto (id uint))
   (default-to "" (get crypto (map-get? ads { id: id }))))  

;; Get ethnographic information
(define-read-only (get-ethno (id uint))
   (default-to "" (get ethno (map-get? ads { id: id }))))  

;; Get psychographic information
(define-read-only (get-psycho (id uint))
   (default-to "" (get psycho (map-get? ads { id: id }))))  

;; Get future targeting parameters
(define-read-only (get-future (id uint))
   (default-to "" (get future (map-get? ads { id: id }))))  

;; Get booked screens/billboards
(define-read-only (get-screens (id uint))
   (default-to "" (get screens (map-get? ads { id: id }))))   

;; Get the running times associated with this ad
(define-read-only (day-starts (id uint))
  (default-to "" (get start-date (map-get? schedules { ad-id: id }))))
 
(define-read-only (time-starts (id uint))
  (default-to "" (get start-time (map-get? schedules { ad-id: id }))))

;; Get the finishing times associated with this ad
(define-read-only (day-ends (id uint))
  (default-to "" (get end-date (map-get? schedules { ad-id: id }))))
 
(define-read-only (time-ends (id uint))
  (default-to "" (get end-time (map-get? schedules { ad-id: id }))))

;; Get the art-url associated with this campaign
;; only accepts links from whitelisted sources or ipfs 
(define-read-only (get-art-url (id uint))
  (default-to "" (get art-url (map-get? ads { id: id }))))

;; Get the click-url associated with this campaign
(define-read-only (get-click-url (id uint))
  (default-to "" (get click-url (map-get? ads { id: id }))))

;; Get the aural-url associated with this campaign
(define-read-only (get-aural-url (id uint))
  (default-to "" (get aural-url (map-get? ads { id: id }))))
 
;; Get the budget associated with this campaign
(define-read-only (get-budget (id uint))
  (default-to u0 (get budget (map-get? ads { id: id }))))

;; Get Ad Geolocations
;; @returns string-ascii/url 
(define-read-only (get-geolocations (id uint)  )
  (default-to "" (get geolocations (map-get? ads {id: id }))))

;; Get the positive and negative keywords associated with this campaign
(define-read-only (get-keywords (id uint))
  (default-to "" (get keywords (map-get? ads { id: id }))))

;; Get min fees 
;; Returns minimum fees
;; @returns uint 
(define-read-only (get-fees)
    (var-get fees))

;; Get ad details 
;; @returns map 
(define-read-only (get-ad (id uint))
  (map-get? ads {id: id}))

;; Asset specific public functions
;;

;; Set fees 
;; Returns minimum fees
;; @returns uint 
(define-public (set-fees (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set fees new-fee))))  

;; Roots
;; ads can be minted to the Bitfari API
;; or to IPFS for full decentralization

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

;; Updating ads
;;

;; Updates an ad
;; @returns bool 
(define-public (update-ad (id uint)  
                (id uint)  
                (advertiser principal) (json (string-ascii 256)) 
                (network principal) (title (string-ascii 256)) 
                (copy (string-ascii 512)) (art-url (string-ascii 256))  
                (click-url (string-ascii 256)) (aural-url (string-ascii 256))
                (audited bool) (red-flag bool) (geolocations (string-ascii 256))
                (osm-id uint) (osm-type (string-ascii 32)) (radius uint)
                (action-url (string-ascii 256)) (action-code (string-ascii 64))
                (demo (string-ascii 256)) (behavioral (string-ascii 256)) 
                (ethno (string-ascii 256)) (psycho (string-ascii 256)) (crypto (string-ascii 256)) 
                (future (string-ascii 256)) (screens (string-ascii 256)) (budget uint) 
                (keywords (string-ascii 1024)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-set ads { id: id }
            { advertiser: advertiser, json: json, 
            network: network, title: title, 
            art-url: art-url, behavioral: behavioral, budget: budget, click-url: click-url,
            copy: copy, crypto: crypto, demo: demo, ethno: ethno, future: future, psycho: psycho,
            aural-url: aural-url, audited: audited, red-flag: red-flag,
            geolocations: geolocations, osm-id: osm-id, osm-type: osm-type, radius: radius,
            action-url: action-url, action-code: action-code,   
            screens: screens,  keywords: keywords }))))

;; Transfers an ad
;; @returns bool 

(define-private (map-transfer (ad-id uint) (owner principal) (recipient principal))
(begin
    (map-set ads { id: ad-id }
          { advertiser: recipient, json: (get-json ad-id), 
            network: (get-network ad-id), title: (get-title ad-id), copy: (get-copy ad-id),
            art-url: (get-art-url ad-id), click-url: (get-click-url ad-id),
            aural-url: (get-aural-url ad-id), audited: (get-audited ad-id), red-flag: (get-red-flag ad-id),
            geolocations: (get-geolocations ad-id), osm-id: (get-osm-id ad-id),
            osm-type: (get-osm-type ad-id), radius: (get-radius ad-id),
            action-url: (get-action-url ad-id), action-code: (get-action-code ad-id), demo: (get-demo ad-id),
            ethno: (get-ethno ad-id), psycho: (get-psycho ad-id), future: (get-future ad-id),
            crypto: (get-crypto ad-id), behavioral: (get-behavioral ad-id),
            screens: (get-screens ad-id), budget: (get-budget ad-id), keywords: (get-keywords ad-id)})
   (nft-transfer? simple-ad ad-id owner recipient)))

;; JSON
;; ;; @returns json/string ascii 256
(define-read-only (get-json (ad-id uint))
  (default-to "none" (get json (map-get? ads { id: ad-id }))))

;; BURNING AND DELETING
;;
;; Burn deletes a token, removing it from the wallet
;; this is non-reversible

;; Three map delete utilities are provided to remove
;; orphan records created by token burning operations.

;; These functions are meant to be executed in tandem
;; by an authorized client.

;; Burns a ad - in case of mistakes, 
;; privacy requests, etc
;; @returns bool or err
(define-public (burn (ad-id uint))
  (begin
    (if (is-owner ad-id tx-sender)
      (match (nft-burn? simple-ad ad-id tx-sender)
        success (ok true)
        error (err error)) ERR_NOT_AUTHORIZED)))

;; Delete a listing in the ad map
;; @returns bool 
(define-public (delete-ad (id uint)  )
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-delete ads { id: id }))))

;; Get Roots

;; Web3 IPFS
;; @returns string-ascii 
(define-read-only (get-ipfs-root)
  (var-get ipfs-root))
 
;; Web2 JSON
;; @returns string-ascii 
(define-read-only (get-json-root)
  (var-get json-root))

;; Minting

;; Mints an ad
;; @returns bool 
 (define-private (mint 
                (id uint)  
                (advertiser principal) (json (string-ascii 256)) 
                (network principal) (title (string-ascii 256)) 
                (copy (string-ascii 512)) (art-url (string-ascii 256))  
                (click-url (string-ascii 256)) (aural-url (string-ascii 256))
                (audited bool) (red-flag bool) (geolocations (string-ascii 256))
                (osm-id uint) (osm-type (string-ascii 32)) (radius uint)
                (action-url (string-ascii 256)) (action-code (string-ascii 64))
                (demo (string-ascii 256)) (behavioral (string-ascii 256)) 
                (ethno (string-ascii 256)) (psycho (string-ascii 256)) (crypto (string-ascii 256)) 
                (future (string-ascii 256)) (screens (string-ascii 256)) (budget uint) 
                (keywords (string-ascii 1024)))
 
        (let ((next-id (+ u1 (var-get last-id))))

        ;; Check osm id + type is not registered
        (asserts! (is-none (map-get? ads {id: id })) ERR_ALREADY_MINTED)

        ;; To avoid double entries, keep straightforward ownership records, etc.
        (asserts! (map-insert ads 
            { id: id } 
            { advertiser: advertiser , json: json, 
            network: network, title: title, copy: copy,
            art-url: art-url, click-url: click-url,
            aural-url: aural-url, audited: audited, red-flag: red-flag,
            geolocations: geolocations, osm-id: osm-id, osm-type: osm-type, radius: radius,
            action-url: action-url, action-code: action-code, demo: demo, behavioral: behavioral,
            ethno: ethno, psycho: psycho, future: future, crypto: crypto,
            screens: screens, budget: budget, keywords: keywords }) ERR_CANT_MAP_AD)
 
        ;; Finally, mint after asserts and children record creation
        ;; a new id is assigned to this token
        (match (nft-mint? simple-ad next-id advertiser)
            success
            (begin
            (var-set last-id next-id)       
            (ok true))
            error (err error))))
  
;; ;; Book Ad
;; ;; @returns bool 
(define-public (publish-ad (id uint) (amount-stx uint) 
                (advertiser principal) (json (string-ascii 256)) 
                (network principal) (title (string-ascii 256)) 
                (copy (string-ascii 512)) (art-url (string-ascii 256))  
                (click-url (string-ascii 256)) (aural-url (string-ascii 256))
                (audited bool) (red-flag bool) (geolocations (string-ascii 256))
                (osm-id uint) (osm-type (string-ascii 32)) (radius uint)
                (action-url (string-ascii 256)) (action-code (string-ascii 64))
                (demo (string-ascii 256)) (behavioral (string-ascii 256)) 
                (ethno (string-ascii 256)) (psycho (string-ascii 256)) (crypto (string-ascii 256)) 
                (future (string-ascii 256)) (screens (string-ascii 256)) (budget uint) 
                (keywords (string-ascii 1024)))
  (if ( >= amount-stx (var-get min-stx))
  (begin    
  (try! (stx-transfer? amount-stx tx-sender CONTRACT_OWNER))
  (try! (as-contract (mint id advertiser json network title   
                            copy art-url click-url aural-url  
                            audited red-flag geolocations  
                            osm-id osm-type radius
                            action-url action-code demo   
                            behavioral ethno psycho crypto 
                            future screens budget keywords )))
  (ok true)) ERR_PRICE_TOO_LOW))
