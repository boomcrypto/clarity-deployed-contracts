(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token typeonchain uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant err-value-not-found (err u1000))
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALREADY-OWNER u1001)
(define-constant ERR-UNAVAILABLE u403)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? typeonchain token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? typeonchain token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
;;   (ok (some (unwrap! (get-map token-id) (err u10))))
  (ok (some (unwrap! (get-map token-id) (err u10))))
)

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
    (begin
        (try! (nft-mint? typeonchain next-id new-owner))
        (var-set last-id next-id)
        (ok next-id)
        )
  )
)

(define-read-only (get-map (token-id uint))
  (ok (concat "https://cloudflare-ipfs.com/ipfs/" (unwrap-panic (get avatar (map-get? wocDatabase {postId: token-id}))))))

;; metadata is onchain
(define-map wocDatabase {postId: uint} {avatar: (string-ascii 99), content: (string-ascii 99), price: uint, likes: uint, author: principal, owner: principal, createTime: uint, available: bool})

;; public functions
(define-public (createPost (avatar (string-ascii 99)) (content (string-ascii 99)) (price uint))
  (begin
    (unwrap-panic (ok (map-set wocDatabase {postId: (+ u1 (var-get last-id))} {avatar: avatar, content: content, price: price, likes: u0, author: tx-sender, owner: tx-sender, createTime: block-height, available: true})))
    (unwrap-panic (mint (as-contract tx-sender)))
    (ok "Post created")
  )
)

(define-read-only (getPost (postId uint))
    (ok (map-get? wocDatabase {postId: postId}))
)

(define-public (likePost (postId uint))
    (let (
        (currentLikes (unwrap! (get likes (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAvatar (unwrap! (get avatar (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentContent (unwrap! (get content (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentPrice (unwrap! (get price (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAuthor (unwrap! (get author (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentOwner (unwrap! (get owner (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentCreateTime (unwrap! (get createTime (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAvailable (unwrap! (get available (map-get? wocDatabase {postId: postId})) (err u1000)))
    )
        (begin
            (map-set wocDatabase {postId: postId} {avatar: currentAvatar, content: currentContent, price: currentPrice, likes: (+ currentLikes u1), author: currentAuthor, owner: currentOwner, createTime: currentCreateTime, available: currentAvailable})
            (ok "Post liked")
        )
    )
)

(define-public (updatePrice (postId uint) (newPrice uint))
    (let (
        (currentLikes (unwrap! (get likes (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAvatar (unwrap! (get avatar (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentContent (unwrap! (get content (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAuthor (unwrap! (get author (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentOwner (unwrap! (get owner (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentCreateTime (unwrap! (get createTime (map-get? wocDatabase {postId: postId})) (err u1000)))
    )
        (begin
            (asserts! (is-eq currentOwner tx-sender) (err ERR-NOT-AUTHORIZED))
            (map-set wocDatabase {postId: postId} {avatar: currentAvatar, content: currentContent, price: newPrice, likes: currentLikes, author: currentAuthor, owner: currentOwner, createTime: currentCreateTime, available: true})
            (ok "Post price updated")
        )
    )
)

(define-public (purchasePost (token-id uint))
    (let (
        (currentPrice (unwrap! (get price (map-get? wocDatabase {postId: token-id})) (err u1000)))
        (currentOwner (unwrap! (get owner (map-get? wocDatabase {postId: token-id})) (err u1000)))
        (currentAvailable (unwrap! (get available (map-get? wocDatabase {postId: token-id})) (err u1000)))
        )
        (begin
            (asserts! (not (is-eq currentOwner tx-sender)) (err ERR-ALREADY-OWNER))
            (asserts! (is-eq currentAvailable true) (err ERR-UNAVAILABLE))
            (unwrap-panic (stx-transfer? currentPrice tx-sender currentOwner))
            (unwrap-panic (updateOwner token-id tx-sender))
            (ok "Post purchased")
        )
    )
)

(define-private (updateOwner (postId uint) (newOwner principal))
    (let (
        (currentLikes (unwrap! (get likes (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAvatar (unwrap! (get avatar (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentContent (unwrap! (get content (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentPrice (unwrap! (get price (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentAuthor (unwrap! (get author (map-get? wocDatabase {postId: postId})) (err u1000)))
        (currentCreateTime (unwrap! (get createTime (map-get? wocDatabase {postId: postId})) (err u1000)))
    )
        (begin
            (map-set wocDatabase {postId: postId} {avatar: currentAvatar, content: currentContent, price: currentPrice, likes: currentLikes, author: currentAuthor, owner: newOwner, createTime: currentCreateTime, available: false})
            (ok "Post transferred")
        )
    )
)

;; utils
;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)
