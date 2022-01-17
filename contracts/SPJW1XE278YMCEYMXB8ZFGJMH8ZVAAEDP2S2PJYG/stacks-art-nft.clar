;; Stacks Art NFTs
;; Used for auctions and minting single NFTs
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token stacks-art uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)

;; variables
(define-constant LIST_5 (list
  true true true true true
))
(define-constant LIST_10 (list
  true true true true true true true true true true
))
(define-constant LIST_20 (list
  true true true true true true true true true true
  true true true true true true true true true true
))
(define-constant LIST_30 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))
(define-constant LIST_40 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))
(define-constant LIST_50 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))
(define-constant LIST_100 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))

(define-data-var CONTRACT-OWNER principal tx-sender)
(define-data-var last-id uint u1)
(define-data-var last-series-id uint u1)
(define-map metadata { id: uint } {
  amount: uint,                       ;; amount of NFTs exist (default 1)
  series-id: uint,                    ;; ID in the series
  series-index: uint,                 ;; index in the series (if amount > 1)
  creator: principal,                 ;; creator address
  name: (string-utf8 256),            ;; name of the NFT
  image: (string-ascii 256),          ;; IPFS/AR image URI
  uri: (string-ascii 256),            ;; IPFS/AR metadata URI
  mime-type: (string-ascii 256),      ;; JPG/GIF/MP4/...
  hash: (buff 64),                    ;; unique hash of the file
  frozen: bool                        ;; entry can be changed or not
})

(define-read-only (get-metadata (id uint))
  (default-to
    { amount: u0, series-id: u0, series-index: u0, creator: (var-get CONTRACT-OWNER), name: u"", image: "", uri: "", mime-type: "", hash: 0x00, frozen: false }
    (map-get? metadata { id: id })
  )
)

(define-public (mint
  (amount uint)
  (series-index uint)
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
  (frozen bool)
)
  (let (
    (id (var-get last-id))
  )
    (try! (mint-internal (var-get last-series-id) amount series-index creator name image uri mime-type hash frozen))
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok id)
  )
)

(define-private (mint-internal
  (series-id uint)
  (amount uint)
  (series-index uint)
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
  (frozen bool)
)
  (let (
    (id (var-get last-id))
  )
    (map-set metadata { id: id } {
      amount: amount,
      series-id: series-id,
      series-index: series-index,
      creator: creator,
      name: name,
      image: image,
      uri: uri,
      mime-type: mime-type,
      hash: hash,
      frozen: frozen
    })
    (try! (nft-mint? stacks-art id tx-sender))
    (var-set last-id (+ id u1))
    (ok id)
  )
)

;; Mint a series of NFTs
(define-private (mint-n
  (i bool)
  (data
    {
      amount: uint,
      series-index: uint,
      creator: principal,
      name: (string-utf8 256),
      image: (string-ascii 256),
      uri: (string-ascii 256),
      mime-type: (string-ascii 256),
      hash: (buff 64)
    }
  )
)
  (begin
    (asserts!
      (is-ok (mint-internal
          (var-get last-series-id)
          (get amount data)
          (+ u1 (get series-index data))
          (get creator data)
          (get name data)
          (get image data)
          (get uri data)
          (get mime-type data)
          (get hash data)
          true
        )
      )
      data
    )
    (merge data { series-index: (+ u1 (get series-index data)) })
  )
)

(define-public (mint-custom
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
  (amount uint)
  (iterator (list 200 bool))
)
  (let (
    (result
      (fold mint-n iterator
        { amount: amount, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-five
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_5
        { amount: u5, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-ten
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_10
        { amount: u10, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-twenty
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_20
        { amount: u20, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-thirty
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_30
        { amount: u30, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-forty
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_40
        { amount: u40, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (ok true)
  )
)

(define-public (mint-fifty
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_50
        { amount: u50, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (mint-one-hundred
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (result
      (fold mint-n LIST_100
        { amount: u100, series-index: u0, creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }
      )
    )
  )
    (print result)
    (var-set last-series-id (+ (var-get last-series-id) u1))
    (ok true)
  )
)

(define-public (update-metadata
  (id uint)
  (creator principal)
  (name (string-utf8 256))
  (image (string-ascii 256))
  (uri (string-ascii 256))
  (mime-type (string-ascii 256))
  (hash (buff 64))
)
  (let (
    (data (get-metadata id))
  )
    (asserts! (is-eq contract-caller (get creator data)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (get frozen data)) (err ERR-NOT-AUTHORIZED))

    (map-set metadata { id: id } (merge data { creator: creator, name: name, image: image, uri: uri, mime-type: mime-type, hash: hash }))
    (ok true)
  )
)

(define-public (freeze-metadata (id uint))
  (let (
    (data (get-metadata id))
  )
    (asserts!
      (or
        (is-eq contract-caller (get creator data))
        (is-eq contract-caller (var-get CONTRACT-OWNER))
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (map-set metadata { id: id } (merge data { frozen: true }))
    (ok true)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? stacks-art index owner recipient)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (burn (id uint))
  (begin
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? stacks-art id tx-sender)
  )
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? stacks-art id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-image-uri (id uint))
  (ok (some (get image (get-metadata id))))
)

(define-read-only (get-token-uri (id uint))
  (ok (some (get uri (get-metadata id))))
)

(define-private (is-owner (index uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? stacks-art index) false))
)
