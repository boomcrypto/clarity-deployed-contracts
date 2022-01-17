;; Buy and Sell Stacks Art on the open market (non-verified)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-map commissions { collection: principal } { commission: uint, royalty: uint, royalty-address: (optional principal) })
(define-map item-for-sale { collection: principal, item-id: uint } { seller: (optional principal), price: uint })
(define-map item-bids { collection: principal, item-id: uint } { buyer: principal, offer: uint })

(define-read-only (get-item-for-sale (collection principal) (item-id uint))
  (default-to
    { seller: none, price: u99000000000000 }
    (map-get? item-for-sale { collection: collection, item-id: item-id })
  )
)

(define-read-only (get-item-bid (collection principal) (item-id uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? item-bids { collection: collection, item-id: item-id })
  )
)

(define-read-only (get-commission-for-collection (collection principal))
  (default-to
    { commission: u250, royalty: u500, royalty-address: (some CONTRACT-OWNER) }
    (map-get? commissions { collection: collection })
  )
)

;;;;;;;;;;;;;;;;;;;;;;
;; public functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-public (list-item (collection <nft-trait>) (item-id uint) (price uint))
  (let (
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
  )
    (asserts! (is-eq tx-sender (unwrap-panic item-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection: (contract-of collection), item-id: item-id } { seller: (some tx-sender), price: price })
    (map-delete item-bids { collection: (contract-of collection), item-id: item-id })

    (print {
      type: "marketplace",
      action: "list-item",
      data: { collection: collection, item-id: item-id, seller: tx-sender, price: price }
    })
    (contract-call? collection transfer item-id tx-sender (as-contract tx-sender))
  )
)

(define-public (change-price (collection <nft-trait>) (item-id uint) (price uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection: (contract-of collection), item-id: item-id } { seller: (some tx-sender), price: price })
    (print {
      type: "marketplace",
      action: "change-price",
      data: { collection: collection, item-id: item-id, seller: sender, price: price }
    })
    (ok true)
  )
)

(define-public (unlist-item (collection <nft-trait>) (item-id uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (sender tx-sender)
    (bid (get-item-bid (contract-of collection) item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))

    (map-delete item-for-sale { collection: (contract-of collection), item-id: item-id })

    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { collection: collection, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id tx-sender sender))
  )
)

(define-public (bid-item (collection <nft-trait>) (item-id uint) (amount uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (bid (get-item-bid (contract-of collection) item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
            (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
          )
          true
        )
        (map-set item-bids { collection: (contract-of collection), item-id: item-id } { buyer: tx-sender, offer: amount })
        (print {
          type: "marketplace",
          action: "bid-item",
          data: { collection: collection, item-id: item-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (collection <nft-trait>) (item-id uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (bid (get-item-bid (contract-of collection) item-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender sender))
      success (begin
        (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          data: { collection: collection, item-id: item-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (collection <nft-trait>) (item-id uint))
  (let (
    (commission-entry (get-commission-for-collection (contract-of collection)))
    (item (get-item-for-sale (contract-of collection) item-id))
    (bid (get-item-bid (contract-of collection) item-id))
    (commission (/ (* (get offer bid) (get commission commission-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty commission-entry)) u10000))    
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (stx-transfer? commission tx-sender CONTRACT-OWNER)))
    (if (is-some (get royalty-address commission-entry))
      (try! (as-contract (stx-transfer? royalty tx-sender (unwrap-panic (get royalty-address commission-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) tx-sender (unwrap-panic (get seller item)))))
    (map-delete item-for-sale { collection: (contract-of collection), item-id: item-id })
    (map-delete item-bids { collection: (contract-of collection), item-id: item-id })

    (try! (as-contract (contract-call? collection transfer item-id tx-sender (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-bid",
      data: { collection: collection, item-id: item-id }
    })
    (ok true)
  )
)

(define-public (buy-item (collection <nft-trait>) (item-id uint))
  (let (
    (commission-entry (get-commission-for-collection (contract-of collection)))
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
    (item (get-item-for-sale (contract-of collection) item-id))
    (sender tx-sender)
    (commission (/ (* (get price item) (get commission commission-entry)) u10000))
    (royalty (/ (* (get price item) (get royalty commission-entry)) u10000))
    (bid (get-item-bid (contract-of collection) item-id))
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic item-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))

    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (if (not (is-eq sender (unwrap-panic (get seller item))))
      (try! (stx-transfer? (- (- (get price item) commission) royalty) sender (unwrap-panic (get seller item))))
      true
    )
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
      )
      true
    )
    (if (and (is-some (get royalty-address commission-entry)) (> royalty u0))
      (try! (stx-transfer? royalty sender (unwrap-panic (get royalty-address commission-entry))))
      true
    )

    (map-delete item-for-sale { collection: (contract-of collection), item-id: item-id })
    (try! (as-contract (contract-call? collection transfer item-id tx-sender sender)))

    (print {
      type: "marketplace",
      action: "buy-item",
      data: { collection: collection, item-id: item-id }
    })
    (ok true)
  )
)

(define-public (admin-unlist (collection <nft-trait>) (item-id uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (bid (get-item-bid (contract-of collection) item-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))

    (map-delete item-for-sale { collection: (contract-of collection), item-id: item-id })
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "admin-unlist",
      data: { collection: collection, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id tx-sender (unwrap-panic (get seller item))))
  )
)

(define-public (admin-remove-bid (collection <nft-trait>) (item-id uint))
  (let (
    (item (get-item-for-sale (contract-of collection) item-id))
    (bid (get-item-bid (contract-of collection) item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid)))
      success (begin
        (map-delete item-bids { collection: (contract-of collection), item-id: item-id })
        (print {
          type: "marketplace",
          action: "admin-remove-bid",
          data: { collection: collection, item-id: item-id, buyer: (get buyer bid) }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (set-sale-commission (collection <nft-trait>) (commission uint))
  (let (
    (commission-entry (get-commission-for-collection (contract-of collection)))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set commissions { collection: (contract-of collection) } (merge commission-entry { commission: commission }))
    (ok true)
  )
)

(define-public (set-royalty (collection <nft-trait>) (royalty uint) (royalty-address principal))
  (let (
    (commission-entry (get-commission-for-collection (contract-of collection)))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set commissions { collection: (contract-of collection) } (merge commission-entry { royalty: royalty, royalty-address: (some royalty-address) }))
    (ok true)
  )
)
