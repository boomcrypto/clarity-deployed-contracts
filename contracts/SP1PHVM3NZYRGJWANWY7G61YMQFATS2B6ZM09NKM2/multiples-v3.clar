(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant ERR-EMPTY-STRING u103)
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
(define-map item-bids { collection-id: (string-ascii 256), item-id: uint, order: uint } { order: uint, buyer: principal, offer: uint })
(define-map collection-bids { collection-id: (string-ascii 256), order: uint } { order: uint, buyer: principal, offer: uint })
(define-map multiple-bids { collection-id: (string-ascii 256), order: uint } { order: uint, ids: (list 5000 uint), buyer: principal, offer: uint, trait: (string-ascii 256) })
(define-map bidder { buyer: principal } { balance: uint })
(define-map listed-item-ids { collection-id: (string-ascii 256) } { ids: (list 5000 uint) })

(define-data-var last-collection-id uint u0)
(define-data-var admins (list 100 principal) (list 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2 'SP2WQQG79CYFP29WV8V1KF8SNAKZVCRXY0J7G3HE9))
(define-data-var order-number uint u0)
(define-data-var removing-item-id uint u0)
(define-data-var shutoff-valve bool false)
(define-data-var bid-cost uint u0)

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
  (address principal)
  (commission uint)
  (royalty uint)
  (royalty-address principal)
)
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
    (map-set collections { id: id} {
      name: name,
      artist: royalty-address,
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
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
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
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
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
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (remove-item-listing collection-id item-id sender))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

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
    (order (var-get order-number))
    (item (get-item-for-sale collection-id item-id))
    (balance (get balance (get-bidder tx-sender)))
  )
    (asserts! (> amount u0) (err ERR-BID-NOT-HIGH-ENOUGH))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (var-get bid-cost) u0)
          (begin
            (try! (stx-transfer? (var-get bid-cost) tx-sender CONTRACT-OWNER))
          )
          true
        )
        (print (+ u1 order))
        (map-set item-bids { collection-id: collection-id, item-id: item-id, order: (+ order u1) } { order: (+ order u1), buyer: tx-sender, offer: amount })
        (map-set bidder { buyer: tx-sender } { balance: (+ balance amount) })
        (var-set order-number (+ u1 order))
        (print {
          type: "marketplace",
          action: "bid-item",
          order: (+ u1 order),
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (collection-bid (collection-id (string-ascii 256)) (amount uint))
  (let (
    (order (var-get order-number))
    (bid (get-collection-bid collection-id order))
    (balance (get balance (get-bidder tx-sender)))
    (prev-bidder (get buyer bid))
    (prev-bidder-balance (get balance (get-bidder prev-bidder)))
    (prev-bid (get offer bid))
  )
    (asserts! (> amount u0) (err ERR-BID-NOT-HIGH-ENOUGH))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (var-get bid-cost) u0)
          (begin
            (try! (stx-transfer? (var-get bid-cost) tx-sender CONTRACT-OWNER))
          )
          true
        )
        (print (+ u1 order))
        (map-set collection-bids { collection-id: collection-id, order: (+ order u1) } { order: (+ order u1), buyer: tx-sender, offer: amount })
        (var-set order-number (+ u1 order))
        (map-set bidder { buyer: tx-sender } { balance: (+ balance amount) })
        (print {
          type: "marketplace",
          action: "collection-bid",
          order: (+ u1 order),
          data: { collection-id: collection-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (multiple-bid (collection-id (string-ascii 256)) (amount uint) (ids (list 5000 uint)) (trait (string-ascii 256)))
  (let (
    (order (var-get order-number))
    (bid (get-multiple-bid collection-id order))
    (balance (get balance (get-bidder tx-sender)))
  )
    (asserts! (> amount u0) (err ERR-BID-NOT-HIGH-ENOUGH))
    (asserts! (> (len ids) u0) (err ERR-EMPTY-STRING))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (stx-transfer? (var-get bid-cost) tx-sender CONTRACT-OWNER))
          )
          true
        )
        (print (+ u1 order))
        (map-set multiple-bids { collection-id: collection-id, order: (+ order u1) } { order: (+ order u1), ids: ids, buyer: tx-sender, offer: amount, trait: trait })
        (map-set bidder { buyer: tx-sender } { balance: (+ balance amount) })
        (var-set order-number (+ u1 order))

        (print {
          type: "marketplace",
          action: "multiple-bid",
          order: (+ u1 order),
          trait: trait,
          data: { collection-id: collection-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (collection-id (string-ascii 256)) (item-id uint) (order uint))
  (let (
    (bid (get-item-bid collection-id item-id order))
    (amount (get offer bid))
    (sender tx-sender)
    (balance (get balance (get-bidder tx-sender)))
  )
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= balance amount) (err ERR-NOT-AUTHORIZED))
    (match (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) sender))
      success (begin
        (map-delete item-bids { collection-id: collection-id, item-id: item-id, order: order })
        (map-set bidder { buyer: tx-sender } { balance: (- balance amount) })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          order: order,
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (withdraw-multiple-bid (collection-id (string-ascii 256)) (order uint))
  (let (
    (bid (get-multiple-bid collection-id order))
    (amount (get offer bid))
    (sender tx-sender)
    (balance (get balance (get-bidder tx-sender)))
    (trait-name (get trait bid))
  )
    
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= balance amount) (err ERR-NOT-AUTHORIZED))
    (match (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) sender))
      success (begin
        (map-delete multiple-bids { collection-id: collection-id, order: order })
        (map-set bidder { buyer: tx-sender } { balance: (- balance amount) })
        (print {
          type: "marketplace",
          action: "withdraw-multiple-bid",
          order: order,
          trait: trait-name,
          data: { collection-id: collection-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (admin-unbid (collection-id (string-ascii 256)) (item-id uint) (order uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id order))
    (amount (get offer bid))
    (sender tx-sender)
    (balance (get balance (get-bidder (get buyer bid))))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= balance amount) (err ERR-NOT-AUTHORIZED))
    (match (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid)))
      success (begin
        (map-delete item-bids { collection-id: collection-id, item-id: item-id, order: order })
        (map-set bidder { buyer: (get buyer bid) } { balance: (- balance amount) })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          order: order,
          data: { collection-id: collection-id, item-id: item-id, buyer: (get buyer bid) }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint) (order uint))
  (if (> (get price (get-item-for-sale collection-id item-id)) u0)
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
  )
    
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (get seller item)))))
    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (map-delete item-bids { collection-id: collection-id, item-id: item-id, order: order })
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })

    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-bid",
      order: order,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (bid (get-item-bid collection-id item-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (print (unwrap-panic (get address collection-entry)))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (print commission)
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (unwrap-panic (contract-call? collection get-owner item-id))))))
    (print (get buyer bid))
    
    (try! (contract-call? collection transfer item-id tx-sender (get buyer bid)))
    (map-delete item-bids { collection-id: collection-id, item-id: item-id, order: order })
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })
    
    (print {
      type: "marketplace",
      action: "accept-bid",
      order: order,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
  )
)


(define-public (accept-collection-bid (collection <nft-trait>) (collection-id (string-ascii 256)) (order uint) (item-id uint))
  (if (> (get price (get-item-for-sale collection-id item-id)) u0)
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-collection-bid collection-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
  )
    (print (contract-of collection))
    (print (unwrap-panic (get address collection-entry)))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (get seller item)))))
    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (map-delete collection-bids { collection-id: collection-id, order: order})
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })

    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-collection-bid",
      order: order,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (bid (get-collection-bid collection-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
  )
    (print (contract-of collection))
    (print (unwrap-panic (get address collection-entry)))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (print (unwrap-panic (get address collection-entry)))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (print commission)
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (unwrap-panic (contract-call? collection get-owner item-id))))))
    (print (get buyer bid))
    
    (try! (contract-call? collection transfer item-id tx-sender (get buyer bid)))
    (map-delete collection-bids { collection-id: collection-id, order: order })
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })
    
    (print {
      type: "marketplace",
      action: "accept-collection-bid",
      order: order,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
  )
)


(define-public (accept-multiple-bid (collection <nft-trait>) (collection-id (string-ascii 256)) (order uint) (item-id uint))
  (if (> (get price (get-item-for-sale collection-id item-id)) u0)
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-multiple-bid collection-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
    (trait-name (get trait bid))
  )
    (print (contract-of collection))
    (print (unwrap-panic (get address collection-entry)))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (get ids bid) item-id)) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (get seller item)))))
    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (map-delete collection-bids { collection-id: collection-id, order: order})
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })

    (try! (as-contract (contract-call? collection transfer item-id (as-contract tx-sender) (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-multiple-bid",
      order: order,
      trait: trait-name,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (bid (get-multiple-bid collection-id order))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
    (balance (get balance (get-bidder (get buyer bid))))
    (trait-name (get trait bid))
  )
    (print (contract-of collection))
    (print (unwrap-panic (get address collection-entry)))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (get ids bid) item-id)) (err ERR-NOT-AUTHORIZED))
    (print (unwrap-panic (get address collection-entry)))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (print commission)
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty (as-contract tx-sender) (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) (as-contract tx-sender) (unwrap-panic (unwrap-panic (contract-call? collection get-owner item-id))))))
    (print (get buyer bid))
    
    (try! (contract-call? collection transfer item-id tx-sender (get buyer bid)))
    (map-delete collection-bids { collection-id: collection-id, order: order })
    (map-set bidder { buyer: (get buyer bid) } { balance: (- balance (get offer bid)) })
    
    (print {
      type: "marketplace",
      action: "accept-multiple-bid",
      order: order,
      trait: trait-name,
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
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
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic item-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))

    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (if (not (is-eq sender (unwrap-panic (get seller item))))
      (try! (stx-transfer? (- (- (get price item) commission) royalty) sender (unwrap-panic (get seller item))))
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
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))

    (try! (remove-item-listing collection-id item-id (unwrap-panic (get seller item))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

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

(define-public (set-admins (admin-list (list 100 principal)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set admins admin-list)
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

(define-read-only (get-item-bid (collection-id (string-ascii 256)) (item-id uint) (order uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0, order: u0 }
    (map-get? item-bids { collection-id: collection-id, item-id: item-id, order: order })
  )
)

(define-read-only (get-collection-bid (collection-id (string-ascii 256)) (order uint))
  (default-to
    { order: u0, buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? collection-bids { collection-id: collection-id, order: order })
  )
)

(define-read-only (get-multiple-bid (collection-id (string-ascii 256)) (order uint))
  (default-to
    { order: u0, ids: (list ), buyer: CONTRACT-OWNER, offer: u0, trait: "" }
    (map-get? multiple-bids { collection-id: collection-id, order: order })
  )
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