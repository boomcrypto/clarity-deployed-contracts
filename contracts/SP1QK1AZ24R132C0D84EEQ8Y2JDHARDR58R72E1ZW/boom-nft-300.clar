;; @contract Boom NFTs
;; @version 3

;; testnet: ST2PABAF9FTAJYNFZH93XENAJ8FVY99RRM4DF2YCW.nft-trait.nft-trait
;; testnet: ST000000000000000000002AMW42H.bns

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token boom uint)
(define-data-var last-id uint u0)
(define-data-var last-series-id uint u0)

;; scoped variable for boom-mint function
(define-data-var ctx-mint {series-id: uint, creator: principal} {series-id: u0, creator: tx-sender})

(define-map meta uint
  {series-id: uint,
  number: uint})

(define-map index-by-series-item
  {series-id: uint,
    number: uint}
  uint)

(define-map series-meta uint
  {creator: principal,
    creator-name: (optional {namespace: (buff 20), name: (buff 48)}),
    name: (string-utf8 80),
    count: uint,
    uri: (string-ascii 256),
    hash: (optional (buff 64))})

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

(define-private (mint-boom (number uint))
  (let ((id (+ u1 (var-get last-id)))
        (series-id (get series-id (var-get ctx-mint)))
        (creator (get creator (var-get ctx-mint))))
      (unwrap-panic (nft-mint? boom id creator))
      (var-set last-id id)
      (map-insert meta id
          {series-id: series-id,
            number: number})
      (map-insert index-by-series-item {series-id: series-id, number: number} id)))

;; @desc mints a list of NFTs belonging to the same NFT series
;; @param creator; the minter and owner to be of the NFTs 
;; @param creator-name; optional BNS name belonging to creator
;; @param name; short name of series
;; @param uri; identifier for series meta data
;; @param hash; optional hash of content for series
;; @param size; supply of NFTs of series
;; @post boom; will be minted for new owner
(define-public (mint-series (creator principal) (creator-name (optional {namespace: (buff 20), name: (buff 48)}))
  (name (string-utf8 80)) (uri (string-ascii 256)) (hash (optional (buff 64))) (ids (list 300 uint)))
  (let ((series-id (inc-last-series-id))
    (size (len ids)))  
    (asserts! (is-creator creator creator-name) err-not-creator)
    ;; set scoped variable for mint-boom call
    (var-set ctx-mint {series-id: series-id, creator: creator})    
    (map mint-boom ids)
    (map-insert series-meta series-id
      {creator: creator,
      creator-name: creator-name,
      name: name,
      count: size,
      uri: uri,
      hash: hash})
    (ok series-id)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) err-permission-denied)
    (nft-transfer? boom id sender recipient)))

(define-public (burn (id uint))
  (let ((owner (unwrap! (nft-get-owner? boom id) err-no-nft)))
    ;; only current owner can burn 
    (asserts! (or (is-eq owner tx-sender) (is-eq owner contract-caller)) err-permission-denied)
    (nft-burn? boom id owner)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? boom id)))

(define-read-only (get-contract-meta)
  {uri: "https://boom.money/images/boom10.png", name: "Boom Collectible"})

(define-read-only (get-series-meta (series-id uint))
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

(define-read-only (get-token-uri (nft-id uint))
  (let ((nft-series-id (get series-id (unwrap! (map-get? meta nft-id) (ok none))))
        (series-meta-data (map-get? series-meta nft-series-id)))
    (ok (get uri series-meta-data))))

(define-read-only  (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-last-series-id)
  (var-get last-series-id))

;; errors
(define-constant err-not-creator (err u400))
(define-constant err-permission-denied (err u403))
(define-constant err-no-nft (err u404))
