(define-non-fungible-token boom uint)
(define-data-var last-id uint u0)

(define-map meta uint
  (tuple
    (creator principal)
    (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
    (series-name (string-utf8 80))
    (number uint)
    (name (string-utf8 80))
    (uri (string-ascii 2048))
    (mime-type (string-ascii 129))
    (hash (buff 64))
    ))

(define-map index-by-series-item
  (tuple
    (creator principal)
    (series-name (string-utf8 80))
    (number uint))
  uint)

(define-map series-meta
 (tuple
    (creator principal)
    (series-name (string-utf8 80))
  )
  (tuple
    (count uint)
    (uri (string-ascii 2048))))

(define-private (update-series-meta (creator principal)
    (series-name (string-utf8 80)) (uri (string-ascii 2048)))
  (match (map-get? series-meta {creator: creator, series-name: series-name})
    entry (map-set series-meta {creator: creator, series-name: series-name}
      {count: (+ u1 (get count entry)), uri: (get uri entry)})
    (map-insert series-meta {creator: creator, series-name: series-name}
      {count: u1, uri: uri})))

(define-private (mint-boom (entry (tuple (name (string-utf8 80)) (number uint) (uri (string-ascii 2048)) (mime-type (string-ascii 129)) (hash (buff 64))))
    (context (tuple (creator principal) (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48))))) (series-name (string-utf8 80)) (count uint) (ids (list 10 uint)))))
  (let
    ((id (+ u1 (var-get last-id)))
      (creator (get creator context))
      (creator-name (get creator-name context))
      (series-name (get series-name context))
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
          {creator: creator,
            creator-name: creator-name,
            series-name: series-name,
            number: number,
            name: (get name entry),
            uri: uri,
            mime-type: mime-type,
            hash: hash}))
      (asserts-panic
        (map-insert index-by-series-item {creator: creator, series-name: series-name, number: number} id))
      (update-series-meta creator series-name uri)
      {creator: creator, creator-name: creator-name, series-name: series-name, count: (+ u1 count), ids: (unwrap-panic (as-max-len? (append ids id) u10))})))


(define-public (mint-series (creator principal) (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48))))) (series-name (string-utf8 80)) (copies (list 10 (tuple (name (string-utf8 80)) (number uint) (uri (string-ascii 2048)) (mime-type (string-ascii 129)) (hash (buff 64))))))
  (let ((context
      (fold mint-boom copies {creator: creator, creator-name: creator-name, series-name: series-name, count: u0, ids: (list)})))
    (ok {count: (get count context), ids: (get ids context)})))

;; error codes
;; (err u1) -- sender does not own the asset
;; (err u2) -- sender and recipient are the same principal
;; (err u3) -- asset identified by asset-identifier does not exist
;; (err u4) -- sender is not tx sender or contract caller
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (if (or (is-eq sender tx-sender) (is-eq sender contract-caller))
    (match (nft-transfer? boom id sender recipient)
      success (ok success)
      error (err {kind: "nft-transfer-failed", code: error}))
    (err {kind: "permission-denied", code: u4})))

(define-public (burn (id uint))
  (match (get-owner-raw? id)
    owner (if (or (is-eq owner tx-sender) (is-eq owner contract-caller))
      (nft-burn? boom id owner)
      (err u4))
    (err u3)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? boom id)))

(define-read-only (get-owner-raw? (id uint))
  (nft-get-owner? boom id))

(define-read-only (get-boom-meta)
  {uri: "boom10.png", name: "Boom NFT (max per series: 10)"}
)

(define-read-only (get-series-meta? (creator principal) (series-name (string-utf8 80)))
    (map-get? series-meta {creator: creator, series-name: series-name}))

(define-read-only (get-meta?
    (creator principal)
    (series-name (string-utf8 80))
    (number uint))
    (match (map-get? index-by-series-item {creator: creator, series-name: series-name, number: number})
      id
        (map-get? meta id)
      none))

(define-read-only  (last-token-id)
  (ok (var-get last-id)))

(define-read-only  (last-token-id-raw)
  (var-get last-id))

(define-private (asserts-panic (value bool))
  (unwrap-panic (if value (some value) none)))
