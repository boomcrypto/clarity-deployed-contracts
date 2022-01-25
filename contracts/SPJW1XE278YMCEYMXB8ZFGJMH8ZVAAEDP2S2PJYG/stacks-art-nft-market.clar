;; Buy and Sell Stacks Art NFTs
;; 2.5% commission to StacksArt
;; 0-10% royalties to creator of NFT (default 5%)
;; Remainder to seller of item
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant ERR-LISTINGS-DISABLED u103)
(define-constant CONTRACT-OWNER tx-sender)

(define-map item-for-sale { nft-id: uint } { seller: (optional principal), price: uint })
(define-map item-bids { nft-id: uint } { buyer: principal, offer: uint })
(define-map item-royalties { nft-id: uint } { commission: uint, royalty: uint })

(define-data-var listings-enabled bool true)

(define-read-only (get-item-royalty (nft-id uint))
  (default-to
    { commission: u250, royalty: u500 }
    (map-get? item-royalties { nft-id: nft-id })
  )
)

(define-read-only (get-item-for-sale (nft-id uint))
  (default-to
    { seller: none, price: u99000000000000 }
    (map-get? item-for-sale { nft-id: nft-id })
  )
)

(define-read-only (get-item-bid (nft-id uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? item-bids { nft-id: nft-id })
  )
)

;;;;;;;;;;;;;;;;;;;;;;
;; public functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-public (list-item (nft-id uint) (price uint))
  (let (
    (item-owner (unwrap-panic (contract-call? .stacks-art-nft get-owner nft-id)))
  )
    (asserts! (var-get listings-enabled) (err ERR-LISTINGS-DISABLED))
    (asserts! (is-eq tx-sender (unwrap-panic item-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { nft-id: nft-id } { seller: (some tx-sender), price: price })
    (map-delete item-bids { nft-id: nft-id })

    (print {
      type: "marketplace",
      action: "list-item",
      data: { nft-id: nft-id, seller: tx-sender, price: price }
    })
    (contract-call? .stacks-art-nft transfer nft-id tx-sender (as-contract tx-sender))
  )
)

(define-public (change-price (nft-id uint) (price uint))
  (let (
    (item (get-item-for-sale nft-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { nft-id: nft-id } { seller: (some tx-sender), price: price })
    (print {
      type: "marketplace",
      action: "change-price",
      data: { nft-id: nft-id, seller: sender, price: price }
    })
    (ok true)
  )
)

(define-public (unlist-item (nft-id uint))
  (let (
    (item (get-item-for-sale nft-id))
    (sender tx-sender)
    (bid (get-item-bid nft-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))

    (map-delete item-for-sale { nft-id: nft-id })

    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { nft-id: nft-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { nft-id: nft-id }
    })
    (as-contract (contract-call? .stacks-art-nft transfer nft-id tx-sender sender))
  )
)

(define-public (bid-item (nft-id uint) (amount uint))
  (let (
    (item (get-item-for-sale nft-id))
    (bid (get-item-bid nft-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
            (map-delete item-bids { nft-id: nft-id })
          )
          true
        )
        (map-set item-bids { nft-id: nft-id } { buyer: tx-sender, offer: amount })
        (print {
          type: "marketplace",
          action: "bid-item",
          data: { nft-id: nft-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (nft-id uint))
  (let (
    (item (get-item-for-sale nft-id))
    (bid (get-item-bid nft-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender sender))
      success (begin
        (map-delete item-bids { nft-id: nft-id })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          data: { nft-id: nft-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (nft-id uint))
  (let (
    (item (get-item-for-sale nft-id))
    (bid (get-item-bid nft-id))
    (metadata (contract-call? .stacks-art-nft get-metadata nft-id))
    (royalty-entry (get-item-royalty nft-id))
    (commission (/ (* (get offer bid) (get commission royalty-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty royalty-entry)) u10000))    
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (stx-transfer? commission tx-sender CONTRACT-OWNER)))
    (try! (as-contract (stx-transfer? royalty tx-sender (get creator metadata))))
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) tx-sender (unwrap-panic (get seller item)))))
    (map-delete item-for-sale { nft-id: nft-id })
    (map-delete item-bids { nft-id: nft-id })

    (try! (as-contract (contract-call? .stacks-art-nft transfer nft-id tx-sender (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-bid",
      data: { nft-id: nft-id }
    })
    (ok true)
  )
)

(define-public (buy-item (nft-id uint))
  (let (
    (item-owner (unwrap-panic (contract-call? .stacks-art-nft get-owner nft-id)))
    (item (get-item-for-sale nft-id))
    (sender tx-sender)
    (metadata (contract-call? .stacks-art-nft get-metadata nft-id))
    (royalty-entry (get-item-royalty nft-id))
    (commission (/ (* (get price item) (get commission royalty-entry)) u10000))
    (royalty (/ (* (get price item) (get royalty royalty-entry)) u10000))
    (bid (get-item-bid nft-id))
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
        (map-delete item-bids { nft-id: nft-id })
      )
      true
    )
    (if (> royalty u0)
      (try! (stx-transfer? royalty sender (get creator metadata)))
      true
    )

    (map-delete item-for-sale { nft-id: nft-id })
    (try! (as-contract (contract-call? .stacks-art-nft transfer nft-id tx-sender sender)))

    (print {
      type: "marketplace",
      action: "buy-item",
      data: { nft-id: nft-id }
    })
    (ok true)
  )
)

(define-public (admin-unlist (nft-id uint))
  (let (
    (item (get-item-for-sale nft-id))
    (bid (get-item-bid nft-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))

    (map-delete item-for-sale { nft-id: nft-id })
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { nft-id: nft-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "admin-unlist",
      data: { nft-id: nft-id }
    })
    (as-contract (contract-call? .stacks-art-nft transfer nft-id tx-sender (unwrap-panic (get seller item))))
  )
)

(define-public (admin-remove-bid (nft-id uint))
  (let (
    (item (get-item-for-sale nft-id))
    (bid (get-item-bid nft-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid)))
      success (begin
        (map-delete item-bids { nft-id: nft-id })
        (print {
          type: "marketplace",
          action: "admin-remove-bid",
          data: { nft-id: nft-id, buyer: (get buyer bid) }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (toggle-listings-enabled)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set listings-enabled (not (var-get listings-enabled)))
    (ok true)
  )
)

(define-public (set-sale-commission (nft-id uint) (commission uint))
  (let (
    (royalty-entry (get-item-royalty nft-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set item-royalties { nft-id: nft-id } (merge royalty-entry { commission: commission }))
    (ok true)
  )
)

(define-public (set-royalty (nft-id uint) (royalty uint))
  (let (
    (royalty-entry (get-item-royalty nft-id))
    (metadata (contract-call? .stacks-art-nft get-metadata nft-id))
  )
    (asserts!
      (or
        (is-eq tx-sender CONTRACT-OWNER)
        (is-eq tx-sender (get creator metadata))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (map-set item-royalties { nft-id: nft-id } (merge royalty-entry { royalty: royalty }))
    (ok true)
  )
)
