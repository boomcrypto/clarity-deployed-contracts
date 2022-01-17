(define-non-fungible-token boom uint)
(define-data-var last-id uint u0)
(define-data-var last-series-id uint u0)

(define-map meta uint
  (tuple
    (series-id uint)
    (number uint)
    (name (string-utf8 80))
    (uri (string-ascii 2048))
    (mime-type (string-ascii 129))
    (hash (buff 64))
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
    error false
  )
)

(define-private (inc-last-series-id)
  (let ((series-id
    (+ u1 (var-get last-series-id))))
    (begin
      (var-set last-series-id series-id)
      series-id
    )))

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

    (match (get-series-meta-raw? series-id)
      entry (and
              (or (is-eq creator tx-sender) (is-eq creator contract-caller))
              (is-eq creator (get creator entry))
              (is-eq creator-name (get creator-name entry))
              (is-eq series-name (get series-name entry))
              (is-eq uri (get uri entry)))
      false
    )
)

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
      (series-id uint) (series-name (string-utf8 80)) (series-uri (string-ascii 2048)) (series-mime-type (string-ascii 129)) (count uint) (ids (list 10 uint)))))
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
            hash: hash}))
      (asserts-panic
        (map-insert index-by-series-item {series-id: series-id, number: number} id))
      (update-series-meta series-id creator creator-name series-name series-uri series-mime-type)
      {creator: creator, creator-name: creator-name, series-id: series-id, series-name: series-name, series-uri: series-uri, series-mime-type: series-mime-type,
      count: (+ u1 count), ids: (unwrap-panic (as-max-len? (append ids id) u10))})))


(define-public (mint-series (creator principal) (creator-name (optional (tuple (namespace (buff 20)) (name (buff 48)))))
  (existing-series-id (optional uint)) (series-name (string-utf8 80)) (series-uri (string-ascii 2048)) (series-mime-type (string-ascii 129))
  (copies (list 10 (tuple (name (string-utf8 80)) (number uint) (uri (string-ascii 2048)) (mime-type (string-ascii 129)) (hash (buff 64))))))
  (let ((series-id (match existing-series-id
                      id (begin
                            (asserts! (same-series-meta id creator creator-name series-name series-uri) (err {kind: "permission-denied", code: u0}))
                            id)
                      (begin
                        (asserts! (is-creator creator creator-name) (err {kind: "not-creator", code: u1}))
                        (inc-last-series-id)))))
    (let ((context
      (fold mint-boom copies {creator: creator, creator-name: creator-name, series-id: series-id, series-name: series-name, series-uri: series-uri, series-mime-type: series-mime-type,
      count: u0, ids: (list)})))
      (ok {count: (get count context), ids: (get ids context), series-id: series-id}))))

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
  {uri: "https://boom.money/images/boom10.png", name: "Boom Collectible", mime-type: "image/png"}
)

(define-read-only (get-series-meta-raw? (series-id uint))
    (map-get? series-meta series-id))

(define-read-only (get-meta? (id uint))
  (map-get? meta id))

(define-read-only (get-meta-by-serial?
    (series-id uint)
    (number uint))
    (match (map-get? index-by-series-item {series-id: series-id, number: number})
      id
        (map-get? meta id)
      none))

(define-read-only  (last-token-id)
  (ok (var-get last-id)))

(define-read-only  (last-token-id-raw)
  (var-get last-id))

(define-read-only (last-series-id-raw)
  (var-get last-series-id)
)

(define-private (asserts-panic (value bool))
  (unwrap-panic (if value (some value) none)))
