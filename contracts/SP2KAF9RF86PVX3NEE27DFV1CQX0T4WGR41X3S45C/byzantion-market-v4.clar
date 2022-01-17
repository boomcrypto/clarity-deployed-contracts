(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (use-trait nft-trait 'ST2PABAF9FTAJYNFZH93XENAJ8FVY99RRM4DF2YCW.nft-trait.nft-trait)

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
(define-map item-bids { collection-id: (string-ascii 256), item-id: uint } { buyer: principal, offer: uint })
(define-map listed-item-ids { collection-id: (string-ascii 256) } { ids: (list 5000 uint) })

(define-data-var last-collection-id uint u0)
(define-data-var removing-item-id uint u0)

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
        { ids: (unwrap-panic (as-max-len? (filter remove-item-id all-item-ids) u5000)) }
      )
      (map-set items-by-seller { collection-id: collection-id, seller: sender }
        { ids: (unwrap-panic (as-max-len? (filter remove-item-id item-ids) u2500)) }
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
  (artist principal)
  (address principal)
  (commission uint)
  (royalty uint)
  (royalty-address principal)
)
  (begin
    (asserts!
      (or
        (is-eq tx-sender CONTRACT-OWNER)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (map-set collections { id: id} {
      name: name,
      artist: artist,
      address: (some address),
      commission: (if (is-eq tx-sender CONTRACT-OWNER)
        commission
        u250
      ),
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
  )
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
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
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
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (remove-item-listing collection-id item-id sender))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) sender))
  )
)

(define-public (bid-item (collection-id (string-ascii 256)) (item-id uint) (amount uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
  )
    
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
            (map-delete item-bids { collection-id: collection-id, item-id: item-id })
          )
          true
        )
        (map-set item-bids { collection-id: collection-id, item-id: item-id } { buyer: tx-sender, offer: amount })
        (print {
          type: "marketplace",
          action: "bid-item",
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (collection-id (string-ascii 256)) (item-id uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
    (sender tx-sender)
  )
    
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) sender))
      success (begin
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
  )
    
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (get seller item)))))
    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-bid",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
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
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic item-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (if (not (is-eq sender (unwrap-panic (get seller item))))
      (try! (stx-transfer? (- (- (get price item) commission) royalty) sender (unwrap-panic (get seller item))))
      true
    )
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )
    (if (and (is-some (get royalty-address collection-entry)) (> royalty u0))
      (try! (stx-transfer? royalty sender (unwrap-panic (get royalty-address collection-entry))))
      true
    )

    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) sender)))

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
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
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

(define-public (set-sale-commission (collection-id (string-ascii 256)) (commission uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (merge collection-entry {
      commission: commission
    })
    (ok true)
  )
)

(define-public (set-royalty (collection-id (string-ascii 256)) (royalty uint) (royalty-address principal))
  (let (
    (collection-entry (get-collection-by-id collection-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (merge collection-entry {
      royalty: royalty,
      royalty-address: (some royalty-address)
    })
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
    { seller: none, price: u99000000000000 }
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

(define-read-only (get-item-entry-by-seller (collection-id (string-ascii 256)) (seller principal))
  (default-to
    { ids: (list ) }
    (map-get? items-by-seller { collection-id: collection-id, seller: seller })
  )
)