;; use the SIP009 interface
;; (impl-trait .nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant token-name "sf-v2.4")
(define-constant token-symbol "SFAN")
(define-non-fungible-token superfandom-nft uint)

;; 
(define-data-var last-token-id uint u0)
(define-data-var administrator principal tx-sender)
(define-map nft-data uint {metadata-url: (string-ascii 256), 
  creator-fandom-id: (string-ascii 40), owner-fandom-id: (string-ascii 40),  mint-block-height: uint,
  redemption-count: uint, 
  beneficiaries: (list 10 {superFandomId: (string-ascii 40), share: uint})})

;; constants
(define-constant not-allowed (err u10))
(define-constant not-found (err u11))

(define-constant transfer-not-supported (err u406)) ;; if operation is not supported yet

;; the contract administrator can change the contract administrator
(define-public (transfer-administrator (new-administrator principal))
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (var-set administrator new-administrator)
        (ok true)
    )
)

(define-public (mint-token (metadataUrl (string-ascii 256)) (creatorSuperFandomId (string-ascii 40)) (ownerSuperFandomId (string-ascii 40)) (redemptionCount uint) 
  (beneficiaries (list 10 {superFandomId: (string-ascii 40), share: uint})))
  (let 
    (
      (next-id (+ u1 (var-get last-token-id)))
    )
    (asserts! (is-administrator) not-allowed)
    (try! (as-contract (nft-mint? superfandom-nft next-id tx-sender)))
    (map-insert nft-data next-id {metadata-url: metadataUrl, creator-fandom-id: creatorSuperFandomId,
      owner-fandom-id: ownerSuperFandomId, mint-block-height: block-height, redemption-count: redemptionCount,
      beneficiaries: beneficiaries})
    (var-set last-token-id next-id)
    (print {action: "mint-token", token-id: next-id, tx-sender: tx-sender})
    (ok next-id)
  )
)

(define-public (transfer (tokenId uint) (owner principal) (recipient principal))
  transfer-not-supported
)

(define-public (burn-token (tokenId uint))
  (begin
    (asserts! (is-administrator) not-allowed)
    (unwrap! (as-contract (nft-burn? superfandom-nft tokenId tx-sender)) not-found)
    (map-delete nft-data tokenId)
    (print {action: "burn-token", token-id: tokenId, tx-sender: tx-sender})
    (ok true)
  )
)

(define-public (change-fandom-owner (tokenId uint) (newOwnerSuperFandomId (string-ascii 40)))
  (begin
    (asserts! (is-administrator) not-allowed)
    (let 
      (
        (token-data (unwrap! (map-get? nft-data tokenId) not-found))
      ) 
      (map-set nft-data tokenId (merge token-data {owner-fandom-id: newOwnerSuperFandomId}))
      (print {action: "change-fandom-owner", token-id: tokenId, tx-sender: tx-sender, new-owner-fandom-id: newOwnerSuperFandomId})
      (ok true)
    )
  )
)

(define-public (redeem (tokenId uint) (ownerSuperFandomId (string-ascii 40)))
  (begin
    (asserts! (is-administrator) not-allowed)
    (let 
      (
        (token-data (unwrap! (map-get? nft-data tokenId) not-found))
        (token-owner-fandom-id (get owner-fandom-id token-data))
        (creator-fandom-id (get creator-fandom-id token-data))
        (redemption-count (get redemption-count token-data))
      ) 
      (asserts! (> redemption-count u0) not-allowed)
      (asserts! (is-eq ownerSuperFandomId token-owner-fandom-id) not-allowed)
      (asserts! (not (is-eq creator-fandom-id ownerSuperFandomId)) not-allowed)
      (map-set nft-data tokenId (merge token-data {redemption-count: (- redemption-count u1)}))
      (print {action: "redeem", token-id: tokenId, tx-sender: tx-sender, redemption-count: (- redemption-count u1)})
      (ok (- redemption-count u1))
    )
  )
)

(define-public (update-beneficiaries (tokenId uint) 
  (beneficiaries (list 10 {superFandomId: (string-ascii 40), share: uint})))
  (begin
    (asserts! (is-administrator) not-allowed)
    (let 
      (
        (token-data (unwrap! (map-get? nft-data tokenId) not-found))
      ) 
      (map-set nft-data tokenId (merge token-data {beneficiaries: beneficiaries}))
      (print {action: "update-beneficiaries", token-id: tokenId, tx-sender: tx-sender, beneficiaries: beneficiaries})
      (ok true)
    )
  )
)

(define-public (update-token-uri (tokenId uint) (newMetadataURL (string-ascii 256)))
  (begin
    (asserts! (is-administrator) not-allowed)
    (let 
      (
        (token-data (unwrap! (map-get? nft-data tokenId) not-found))
      ) 
      (map-set nft-data tokenId (merge token-data {metadata-url: newMetadataURL}))
      (print {action: "update-token-uri", token-id: tokenId, tx-sender: tx-sender, metadata-url: newMetadataURL})
      (ok true)
    )
  )
)


(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? superfandom-nft token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))
  

(define-read-only (get-token-uri (token-id uint))
  (ok (get metadata-url (map-get? nft-data token-id)))
)

(define-read-only (get-owner-fandom-id (token-id uint))
  (get owner-fandom-id (map-get? nft-data token-id))
)

(define-read-only (get-administrator)
  (var-get administrator)
)

(define-read-only (is-administrator)
  (is-eq (var-get administrator) tx-sender)
)

(define-read-only (get-redemption-count (token-id uint))
  (get redemption-count (map-get? nft-data token-id))
)

(define-read-only (get-beneficiaries (token-id uint))
  (get beneficiaries (map-get? nft-data token-id))
)

(define-read-only (get-token-data (token-id uint))
  (map-get? nft-data token-id)
)
