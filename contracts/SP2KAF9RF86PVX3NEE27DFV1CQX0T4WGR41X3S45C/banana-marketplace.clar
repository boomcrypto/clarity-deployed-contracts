(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-map collections { id: (string-ascii 256) } {
  name: (string-ascii 256),
  artist: principal,
  address: (optional principal),
  commission: uint,
  royalty: uint,
  royalty-address: (optional principal)
})
(define-map item-for-sale { collection-id: (string-ascii 256), item-id: uint } { seller: (optional principal), price: uint })
(define-map items-by-seller { collection-id: (string-ascii 256), seller: principal } { ids: (list 2500 uint) })
(define-map items-listed uint { collection-id: (list 2500 (string-ascii 256)), ids: (list 2500 uint) })
(define-map item-bids { collection-id: (string-ascii 256), item-id: uint } { buyer: principal, offer: uint })
(define-map collection-bids { collection-id: (string-ascii 256) } { buyer: principal, offer: uint })
(define-map bidder { buyer: principal } { balance: uint })
(define-map listed-item-ids { collection-id: (string-ascii 256) } { ids: (list 5000 uint) })

;; (define-data-var listed-ids uint (list u5 u15 u18 u21 u27))
(define-data-var last-collection-id uint u0)
(define-data-var listed-items (list 1000 (string-ascii 300)) (list ))
(define-data-var removing-item-id uint u0)
(define-data-var removing-item (string-ascii 300) "")
(define-data-var volume uint u0)
(define-data-var sales uint u0)
(define-data-var bananas-burned uint u0)
(define-data-var burn-rate uint u3000)
(define-data-var is-active bool true)
(define-data-var admin principal 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y)
(define-data-var vault principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.banana-vault)

;; Private functions
(define-private (remove-item-listing (collection-id (string-ascii 256)) (item-id uint) (sender principal))
  (if true
    (let (
      (collection-entry (get-collection-by-id collection-id))
      (item-ids (unwrap-panic (get-item-ids-by-seller collection-id sender)))
      (all-item-ids (get-listed-item-ids collection-id))
    )
      (var-set removing-item-id item-id)
      (map-set listed-item-ids { collection-id: collection-id }
        { ids: (filter remove-item-id all-item-ids) }
      )
      (map-set items-by-seller { collection-id: collection-id, seller: sender }
        { ids: (filter remove-item-id item-ids) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

;; Public functions
(define-public (add-collection
  (id (string-ascii 256))
  (name (string-ascii 256))
  (address principal)
  (commission uint)
  (royalty uint)
  (royalty-address principal)
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set collections { id: id} {
      name: name,
      artist: royalty-address,
      address: (some address),
      commission: commission,
      royalty: royalty,
      royalty-address: (some royalty-address)
    })
    (var-set last-collection-id (+ u1 (var-get last-collection-id)))
    (ok true)
  )
)

(define-public (list-item (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint) (price uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
    (item-ids (unwrap-panic (get-item-ids-by-seller collection-id tx-sender)))
    (all-item-ids (get-listed-item-ids collection-id))
    (all-items (var-get listed-items))
  )
    (asserts! (var-get is-active) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq tx-sender (unwrap-panic item-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection-id: collection-id, item-id: item-id } { seller: (some tx-sender), price: price })
    (map-set items-by-seller { collection-id: collection-id, seller: tx-sender }
      { ids: (unwrap-panic (as-max-len? (append item-ids item-id) u2500)) }
    )
    (map-set listed-item-ids { collection-id: collection-id }
      { ids: (unwrap-panic (as-max-len? (append all-item-ids item-id) u5000)) }
    )
    (if (< item-id u5001)
      (var-set listed-items (unwrap-panic (as-max-len? (append (var-get listed-items) (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id)))) u1000)))
      (var-set listed-items (unwrap-panic (as-max-len? (append (var-get listed-items) (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion-v2 lookup (- item-id u5001))))) u1000)))
    )
    ;; (map-set items-listed u1
    ;;   { collection-id: (unwrap-panic (as-max-len? (append all-item-ids collection-id) u2500)) }
    ;; )

    (print {
      type: "marketplace",
      action: "list-item",
      data: { collection-id: collection-id, item-id: item-id, seller: tx-sender, price: price }
    })
    (contract-call? collection transfer item-id tx-sender (as-contract tx-sender))
  )
)

(define-public (change-price (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint) (price uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
  )
    (asserts! (var-get is-active) (err ERR-NOT-AUTHORIZED))
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection-id: collection-id, item-id: item-id } { seller: (some tx-sender), price: price })
    (print {
      type: "marketplace",
      action: "change-price",
      data: { collection-id: collection-id, item-id: item-id, seller: sender, price: price }
    })
    (ok true)
  )
)

(define-public (unlist-item (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
    (bid (get-item-bid collection-id item-id))
    (listed (var-get listed-items))
  )
    (asserts! (var-get is-active) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    
    (try! (remove-item-listing collection-id item-id sender))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    ;; (print (filter (not (is-eq (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id))))) (var-get listed-items)))
    (if (< item-id u5001)
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id))))
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion-v2 lookup (- item-id u5001)))))
    )
    (var-set listed-items (filter remove-item listed))
    ;; (if (< item-id u5001)
    ;;   (var-set listed-items (filter (not (is-eq (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id))))) (var-get listed-items)))
    ;;   (var-set listed-items (filter (not (is-eq (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion-v2 lookup (- item-id u5001)))))) (var-get listed-items)))
    ;; )
    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id tx-sender sender))
  )
)

(define-private (remove-item (item-id (string-ascii 300)))
  (if (is-eq item-id (var-get removing-item))
    false
    true
  )
)

(define-public (buy-item (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
    (commission (/ (* (get price item) (get commission collection-entry)) u10000))
    (royalty (/ (* (get price item) (get royalty collection-entry)) u10000))
    (bid (get-item-bid collection-id item-id))
    (to-burn (/ (* (get price item) u300) u10000))
    (to-vault (/ (* (get price item) (- u1000 u300)) u10000))
    (listed (var-get listed-items))
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic item-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (var-get is-active) (err ERR-NOT-AUTHORIZED))
    (if (> to-burn u0)
      (begin
        (try! (contract-call? .btc-monkeys-bananas burn to-burn))
        (if (not (is-eq sender (unwrap-panic (get seller item))))
          (try! (contract-call? .btc-monkeys-bananas transfer to-vault sender (var-get vault) none))
          true
        )
      )
      (begin
        (if (not (is-eq sender (unwrap-panic (get seller item))))
          (try! (contract-call? .btc-monkeys-bananas transfer to-vault sender (var-get vault) none))
          true
        )
      )
    )

    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (var-set volume (+ (var-get volume) (get price item)))
    (var-set sales (+ (var-get sales) u1))
    (var-set bananas-burned (+ (var-get bananas-burned) (/ (* (get price item) u300) u10000)))
    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) sender)))
    (if (< item-id u5001)
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id))))
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion-v2 lookup (- item-id u5001)))))
    )
    (var-set listed-items (filter remove-item listed))
    (print {
      type: "marketplace",
      action: "buy-item",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
)

(define-public (admin-unlist (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
    (listed (var-get listed-items))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (var-get is-active) (err ERR-NOT-AUTHORIZED))

    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (if (< item-id u5001)
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion lookup item-id))))
      (var-set removing-item (concat (concat collection-id "::") (unwrap-panic (contract-call? .conversion-v2 lookup (- item-id u5001)))))
    )
    (var-set listed-items (filter remove-item listed))
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "admin-unlist",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) (unwrap-panic (get seller item))))
  )
)


(define-public (shutoff (switch bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set is-active switch)
    (ok true)
  )
)

(define-public (set-burn-rate (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set burn-rate amount)
    (ok true)
  )
)

(define-public (set-admin (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set admin address)
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-collection-by-id (collection-id (string-ascii 256)))
  (default-to
    { name: "null", address: none, commission: u0, royalty: u0, royalty-address: none }
    (map-get? collections { id: collection-id })
  )
)
(define-read-only (get-listed-item-ids (collection-id (string-ascii 256)))
  (default-to
    (list )
    (get ids (map-get? listed-item-ids { collection-id: collection-id }))
  )
)

(define-read-only (get-item-for-sale (collection-id (string-ascii 256)) (item-id uint))
  (default-to
    { seller: none, price: u0 }
    (map-get? item-for-sale { collection-id: collection-id, item-id: item-id })
  )
)

(define-read-only (get-item-ids-by-seller (collection-id (string-ascii 256)) (seller principal))
  (ok (get ids (get-item-entry-by-seller collection-id seller)))
)

(define-read-only (get-item-bid (collection-id (string-ascii 256)) (item-id uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? item-bids { collection-id: collection-id, item-id: item-id })
  )
)

(define-read-only (get-collection-bid (collection-id (string-ascii 256)))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? collection-bids { collection-id: collection-id })
  )
)

(define-read-only (get-listed-items)
  (var-get listed-items)
)

(define-read-only (get-stats)
  (list (var-get sales) (var-get volume) (var-get bananas-burned))
)

(define-read-only (get-burned-bananas)
  (ok (var-get bananas-burned))
)

(define-read-only (get-volume)
  (ok (var-get volume))
)

(define-read-only (get-sales)
  (ok (var-get sales))
)

(define-read-only (get-bidder (buyer principal))
  (default-to
    { balance: u0 }
    (map-get? bidder { buyer: buyer })
  )
)

(define-read-only (get-item-entry-by-seller (collection-id (string-ascii 256)) (seller principal))
  (default-to
    { ids: (list ) }
    (map-get? items-by-seller { collection-id: collection-id, seller: seller })
  )
)