;; @contract Boom NFTs
;; @version 3
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token boom uint)
(define-data-var last-id uint u0)
(define-data-var last-series-id uint u0)

;; temporal variable
(define-data-var current-buyer (optional principal) none)

(define-map meta uint
  (tuple
    (series-id uint)
    (number uint)
    (name (string-utf8 80))
    (uri (string-ascii 2048))
    (mime-type (string-ascii 129))
    (hash (buff 64))
    (listed bool)
    (price (optional uint))
    ))

(define-map index-by-series-item
  (tuple
    (series-id uint)
    (number uint))
  uint)

(define-map series-meta uint
  (tuple
    (creator principal)
    (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
    (series-name (string-utf8 80))
    (count uint)
    (uri (string-ascii 2048))
    (mime-type (string-ascii 129))
    ))

(define-private (owns-name (user principal) (username (tuple (namespace (buff 20)) (name (buff 48)))))
  (match (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve (get namespace username) (get name username))
    details (is-eq user (get owner details))
    error false))

(define-private (inc-last-series-id)
  (let ((series-id (+ u1 (var-get last-series-id))))    
      (var-set last-series-id series-id)
      series-id))

(define-private (is-creator (creator principal)
  (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48))))))
  (and
    (or (is-eq creator tx-sender) (is-eq creator contract-caller))
    (match creator-name
      username (owns-name creator username)
      true )))

(define-private (same-series-meta (series-id uint) (creator principal)
    (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
    (series-name (string-utf8 80)) (uri (string-ascii 2048)))

    (match (get-series-meta-raw series-id)
      entry (and
              (or (is-eq creator tx-sender) (is-eq creator contract-caller))
              (is-eq creator (get creator entry))
              (is-eq creator-name (get creator-name entry))
              (is-eq series-name (get series-name entry))
              (is-eq uri (get uri entry)))
      false))

(define-private (update-series-meta (series-id uint) (creator principal)
    (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
    (series-name (string-utf8 80)) (uri (string-ascii 2048)) (mime-type (string-ascii 129)))
  (match (map-get? series-meta series-id)
    entry (map-set series-meta series-id
      {creator: (get creator entry),
      creator-name: (get creator-name entry),
      series-name: (get series-name entry),
      count: (+ u1 (get count entry)),
      uri: (get uri entry),
      mime-type: (get mime-type entry)})
    (map-insert series-meta series-id
      {creator: creator,
      creator-name: creator-name,
      series-name: series-name,
      count: u1,
      uri: uri,
      mime-type: mime-type})))

(define-private (mint-boom (entry (tuple (number uint) (name (string-utf8 80)) (uri (string-ascii 2048)) (mime-type (string-ascii 129)) (hash (buff 64))))
    (context (tuple (creator principal) (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
      (series-id uint) (series-name (string-utf8 80)) (series-uri (string-ascii 2048)) (series-mime-type (string-ascii 129)) (count uint) (ids (list 50 uint)))))
  (let
    ((id (+ u1 (var-get last-id)))
      (creator (get creator context))
      (creator-name (get creator-name context))
      (series-id (get series-id context))
      (series-name (get series-name context))
      (series-uri (get series-uri context))
      (series-mime-type (get series-mime-type context))
      (count (get count context))
      (ids (get ids context))
      (number (get number entry))
      (uri (get uri entry))
      (mime-type (get mime-type entry))
      (hash (get hash entry)))
    (begin
      (unwrap-panic (nft-mint? boom id creator))
      (asserts-panic (var-set last-id id))
      (asserts-panic
        (map-insert meta id
          {series-id: series-id,
            number: number,
            name: (get name entry),
            uri: uri,
            mime-type: mime-type,
            hash: hash,
            listed: false,
            price: none}))
      (asserts-panic
        (map-insert index-by-series-item {series-id: series-id, number: number} id))
      (update-series-meta series-id creator creator-name series-name series-uri series-mime-type)
      {creator: creator, creator-name: creator-name, series-id: series-id, series-name: series-name, series-uri: series-uri, series-mime-type: series-mime-type,
      count: (+ u1 count), ids: (unwrap-panic (as-max-len? (append ids id) u10))})))


;; @desc mints a list of NFTs belonging to the same NFT series
;; @param creator; the minter and owner to be of the NFTs 
;; @param creator-name; optional BNS name belonging to creator
;; @param existing-series-id; if set the series will be continued
;; @param series-name; short name of series
;; @param series-uri; identifier for series meta data
;; @param series-mime-type; mime type of associated digital content for series
;; @param copies; list of details for individual copies of the series
;; @post boom; will be minted for new owner
(define-public (mint-series (creator principal) (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
  (existing-series-id (optional uint)) (series-name (string-utf8 80)) (series-uri (string-ascii 2048)) (series-mime-type (string-ascii 129))
  (copies (list 50 (tuple (name (string-utf8 80)) (number uint) (uri (string-ascii 2048)) (mime-type (string-ascii 129)) (hash (buff 64))))))
  (let ((series-id (match existing-series-id
                      id (begin
                            (asserts! (same-series-meta id creator creator-name series-name series-uri) err-permission-denied)
                            id)
                      (begin
                        (asserts! (is-creator creator creator-name) err-not-creator)
                        (inc-last-series-id)))))
    (let ((context
      (fold mint-boom copies {creator: creator, creator-name: creator-name, series-id: series-id, series-name: series-name, series-uri: series-uri, series-mime-type: series-mime-type,
      count: u0, ids: (list)})))
      (ok {count: (get count context), ids: (get ids context), series-id: series-id}))))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (let ((buyer (var-get current-buyer)))
    ;; rule 1: current owner can transfer
    (asserts! (or (is-some buyer) (is-eq sender tx-sender) (is-eq sender contract-caller)) err-permission-denied)
    ;; rule 2: buyer of listed nft can transfer
    (asserts! (or (is-none buyer) (is-eq recipient (unwrap! buyer err-fatale))) err-not-paid)
    (var-set current-buyer none)
    (nft-transfer? boom id sender recipient)))

(define-public (burn (id uint))
  (let ((owner (unwrap! (get-owner-raw id) err-no-nft)))
    ;; rule 1: only unlisted nfts can be burnt
    (asserts! (not (get listed (unwrap! (map-get? meta id) err-fatale))) err-listing)
    ;; rule 2: only current owner can burn 
    (asserts! (or (is-eq owner tx-sender) (is-eq owner contract-caller)) err-permission-denied)
    (nft-burn? boom id owner)))

(define-public (list-nft (id uint) (price uint))
  (let ((nft (unwrap! (map-get? meta id) err-no-nft))
      (owner (unwrap! (get-owner-raw id) err-no-nft)))
    (asserts! (or (is-eq owner tx-sender) (is-eq owner contract-caller)) err-permission-denied)
    (map-set meta id (merge nft {price: (some price), listed: true}))    
    (print {id: id, price: (some price), listed: true})
    (ok true)))

(define-public (unlist-nft (id uint))
  (let ((nft (unwrap! (map-get? meta id) err-no-nft))
      (owner (unwrap! (get-owner-raw id) err-no-nft)))
    (asserts! (or (is-eq owner tx-sender) (is-eq owner contract-caller)) err-permission-denied)
    (map-set meta id (merge nft {price: none, listed: false}))    
    (print {id: id, price: none, listed: false})
    (ok true)))

(define-public (buy (id uint))
  (let ((nft (unwrap! (map-get? meta id) err-no-nft))
    (owner (unwrap! (nft-get-owner? boom id) err-no-nft)))
    (var-set current-buyer (some tx-sender))    
    ;; rule 1: nft must be listed
    (asserts! (get listed (unwrap! (map-get? meta id) err-fatale)) err-listing)    
    (map-set meta id (merge nft {price: none, listed: false}))    
    (print {id: id, price: none, listed: false})    
    (try! (stx-transfer? (unwrap! (get price nft) err-listing) owner tx-sender))
    (transfer id owner tx-sender)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? boom id)))

(define-read-only (get-owner-raw (id uint))
  (nft-get-owner? boom id))

(define-read-only (get-boom-meta)
  {uri: "https://boom.money/images/boom10.png", name: "Boom Collectible", mime-type: "image/png"}
)

(define-read-only (get-series-meta-raw (series-id uint))
    (map-get? series-meta series-id))

(define-read-only (get-meta (id uint))
  (map-get? meta id))

(define-read-only (get-meta-by-serial
    (series-id uint)
    (number uint))
    (match (map-get? index-by-series-item {series-id: series-id, number: number})
      id
        (map-get? meta id)
      none))

(define-read-only (get-token-uri (id uint))
  (ok (some "ipfs://Qmmm---/$id")))

(define-read-only  (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only  (last-token-id-raw)
  (var-get last-id))

(define-read-only (last-series-id-raw)
  (var-get last-series-id))

(define-private (asserts-panic (value bool))
  (unwrap-panic (if value (some value) none)))

;; errors
(define-constant err-not-creator (err u400))
(define-constant err-permission-denied (err u403))
(define-constant err-no-nft (err u404))
(define-constant err-listing (err u405))
(define-constant err-not-paid (err u406))
(define-constant err-fatale (err u500))

;; native error codes
;; (err u1000) -- sender does not own the asset
;; (err u2000) -- sender and recipient are the same principal
;; (err u3000) -- asset identified by asset-identifier does not exist
;; (err u4000) -- sender is not tx sender or contract caller