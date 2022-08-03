(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant ERR-EMPTY-STRING u103)
(define-constant ERR-PROJECT-NOT-WHITELISTED u104)
(define-constant CONTRACT-OWNER tx-sender)

(define-map collections { id: (string-ascii 256) } {
  name: (string-ascii 256),
  artist: principal,
  address: (optional principal),
  commission: uint,
  royalty: uint,
  royalty-address: (optional principal)
})
(define-map item-for-sale { collection-id: (string-ascii 256), amount: uint } { seller: (optional principal), price: uint })
(define-map block { order: uint } { seller: principal, price: uint, amount: uint, volume: uint })
(define-map bid-block { order: uint } { buyer: principal, price: uint, amount: uint, volume: uint })
(define-map items-by-seller { collection-id: (string-ascii 256), seller: principal } { ids: (list 2500 uint) })
(define-map item-bids { collection-id: (string-ascii 256), item-id: uint, order: uint } { order: uint, buyer: principal, offer: uint })
(define-map collection-bids { collection-id: (string-ascii 256), order: uint } { order: uint, buyer: principal, amount: uint, price: uint, volume: uint })
(define-map multiple-bids { collection-id: (string-ascii 256), order: uint } { order: uint, ids: (list 5000 uint), buyer: principal, offer: uint, trait: (string-ascii 256) })
(define-map bidder { buyer: principal } { balance: uint })
(define-map listed-item-ids { collection-id: (string-ascii 256) } { ids: (list 5000 uint) })

(define-data-var last-collection-id uint u0)
(define-data-var admins (list 100 principal) (list 'SP1GAFZC0KNZ1J7JDT0MBRJTF0P28E7XAS7YTTEFM))
(define-data-var order-number uint u0)
(define-data-var removing-item-id uint u0)
(define-data-var shutoff-valve bool false)
(define-data-var commission-percent uint u250)
(define-data-var bid-cost uint u0)

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

(define-public (list-item (collection <ft-trait>) (collection-id (string-ascii 256)) (amount uint) (price uint))
  (let (
    (order (+ u1 (var-get order-number)))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))
    (map-set block { order: order } { seller: tx-sender, price: price, amount: amount, volume: (/ (* price amount) u1000000) })

    (print {
      type: "marketplace",
      action: "list-item",
      data: { order: order, price: price, volume: (/ (* price amount) u1000000), amount: amount }
    })
    (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer amount tx-sender (as-contract tx-sender) none)
  )
)

(define-public (buy-item (collection <ft-trait>) (collection-id (string-ascii 256)) (order uint))
  (let (
    (price (get price (unwrap-panic (map-get? block { order: order } ))))
    (amount (get amount (unwrap-panic (map-get? block { order: order } ))))
    (volume (get volume (unwrap-panic (map-get? block { order: order } ))))
    (seller (get seller (unwrap-panic (map-get? block { order: order } ))))
    (sender tx-sender)
    (commission (/ (* volume (var-get commission-percent)) u10000))
    (payout (- volume (/ (* volume (var-get commission-percent)) u10000)))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (try! (stx-transfer? payout sender seller))
    (try! (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer amount (as-contract tx-sender) sender none)))
    (map-delete block { order: order })
    (print {
      type: "marketplace",
      action: "buy-item",
      data: { order: order, price: price, volume: volume, amount: amount }
    })
    (ok true)
  )
)

(define-public (unlist-item (collection <ft-trait>) (collection-id (string-ascii 256)) (order uint))
  (let (
    (price (get price (unwrap-panic (map-get? block { order: order } ))))
    (amount (get amount (unwrap-panic (map-get? block { order: order } ))))
    (volume (get volume (unwrap-panic (map-get? block { order: order } ))))
    (seller (get seller (unwrap-panic (map-get? block { order: order } ))))
    (sender tx-sender)
    (commission (/ (* volume (var-get commission-percent)) u10000))
    (payout (- volume (/ (* volume (var-get commission-percent)) u10000)))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq sender seller) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer amount (as-contract tx-sender) sender none)))
    (map-delete block { order: order })
    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { order: order, price: price, volume: volume, amount: amount }
    })
    (ok true)
  )
)

(define-public (collection-bid (collection-id (string-ascii 256)) (amount uint) (price uint))
  (let (
    (order (+ u1 (var-get order-number)))
  )
    (asserts! (> amount u0) (err ERR-BID-NOT-HIGH-ENOUGH))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (match (stx-transfer? (/ (* price amount) u1000000) tx-sender (as-contract tx-sender))
      success (begin
        (if (> (var-get bid-cost) u0)
          (begin
            (try! (stx-transfer? (var-get bid-cost) tx-sender CONTRACT-OWNER))
          )
          true
        )
        (map-set bid-block { order: order } { buyer: tx-sender, price: price, amount: amount, volume: (/ (* price amount) u1000000) })
        (var-set order-number order)
        (print {
          type: "marketplace",
          action: "collection-bid",
          order: order,
          data: { collection-id: collection-id, buyer: tx-sender, price: price, amount: amount, volume: (/ (* price amount) u1000000) }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (accept-collection-bid (collection <ft-trait>) (collection-id (string-ascii 256)) (order uint))
  (let (
    (price (get price (unwrap-panic (map-get? bid-block { order: order } ))))
    (amount (get amount (unwrap-panic (map-get? bid-block { order: order } ))))
    (volume (get volume (unwrap-panic (map-get? bid-block { order: order } ))))
    (buyer (get buyer (unwrap-panic (map-get? bid-block { order: order } ))))
    (commission (/ (* volume (var-get commission-percent)) u10000))
    (payout (- volume (/ (* volume (var-get commission-percent)) u10000)))
  )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (try! (as-contract (stx-transfer? payout (as-contract tx-sender) CONTRACT-OWNER)))
    (try! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer amount tx-sender buyer none))
    (map-delete bid-block { order: order })
    
    (print {
      type: "marketplace",
      action: "accept-collection-bid",
      order: order,
      data: { order: order, price: price, volume: volume, amount: amount }
    })
    (ok true)
  )
)

(define-public (withdraw-collection-bid (collection-id (string-ascii 256)) (order uint))
  (let (
    (price (get price (unwrap-panic (map-get? bid-block { order: order } ))))
    (amount (get amount (unwrap-panic (map-get? bid-block { order: order } ))))
    (volume (get volume (unwrap-panic (map-get? bid-block { order: order } ))))
    (buyer (get buyer (unwrap-panic (map-get? bid-block { order: order } ))))
    (sender tx-sender)
  )
    (asserts! (is-eq sender buyer) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (match (as-contract (stx-transfer? volume (as-contract tx-sender) sender))
      success (begin
        (map-delete bid-block { order: order })
        (print {
          type: "marketplace",
          action: "withdraw-collection-bid",
          order: order,
          data: { order: order, price: price, volume: volume, amount: amount }
        })
        (ok volume)
      )
      error (err error)
    )
  )
)

;; Read only functions
(define-read-only (get-collection-by-id (collection-id (string-ascii 256)))
  (default-to
    { name: "null", address: none, commission: u0, royalty: u0, royalty-address: none }
    (map-get? collections { id: collection-id })
  )
)
