(use-trait nft-trait .biddable-nft-trait.biddable-nft)

;; bids map
;; if nft-id is `none`, the bid is a collection bid
;;    and can be accepted by anyone holding a token from
;;    that collection.

(define-map bids
  uint
  { 
    collection: principal, 
    nft-id: (optional uint), 
    bid-amount: uint, 
    buyer: principal, 
    seller: (optional principal), 
    expiration-block: uint, 
    action-event-index: uint 
  }
)

(define-constant contract-address (as-contract tx-sender))
(define-constant contract-owner tx-sender)
(define-constant err-contract-not-authorized u101)
(define-constant err-placing-bids-disabled u102)
(define-constant err-accepting-bids-disabled u103)
(define-constant err-withdrawing-bids-disabled u104)
(define-constant err-user-not-authorized u105)
(define-constant err-no-bid-found u106)
(define-constant err-bid-expired u107)
(define-constant err-wrong-collection u108)
(define-constant err-wrong-nft-id u109)
(define-constant err-royalty-issue u110)

(define-data-var placing-bids-enabled bool true)
(define-data-var accepting-bids-enabled bool true)
(define-data-var withdrawing-bids-enabled bool true)
(define-data-var commission uint u200)
(define-data-var id uint u0)

(define-public (place-bid (collection <nft-trait>) (nft-id (optional uint)) (amount uint) (expiration uint) (memo (optional (string-ascii 256))))
  (let ((block block-height)
        (next-bid-id (var-get id))
        (nft-owner 
          (if (is-some nft-id) 
            (get-owner collection (unwrap-panic nft-id))
            none)
        ) 
        (nft {collection: (contract-of collection), nft-id: nft-id, bid-amount: amount, buyer: tx-sender, seller: nft-owner, expiration-block: (+ expiration block), action-event-index: u0}))
    (asserts! (var-get placing-bids-enabled) 
              (err err-placing-bids-disabled))

    (try! (stx-transfer? amount tx-sender contract-address))
    (map-set bids next-bid-id nft)
    (var-set id (+ next-bid-id u1))

    (print { 
      action: "place-bid",
      payload: {
        bid_id: next-bid-id,
        action_event_index: (get action-event-index nft),
        collection_id: collection,
        ;; asset_id: asset-id',
        token_id: nft-id,
        bidder_address: tx-sender,
        seller_address: nft-owner,
        bid_amount: amount, 
        expiration_block: (get expiration-block nft),
        memo: memo
      }
    })

    (ok next-bid-id)
  )
)

(define-public (withdraw-bid (bid-id uint))
  (let ((previous-bid (get-bid bid-id))
        (previous-bidder (get buyer previous-bid))
        (previous-bid-action-event-index (get action-event-index previous-bid))
        (previous-bid-amount (get bid-amount previous-bid)))
    (asserts! (var-get withdrawing-bids-enabled) 
              (err err-withdrawing-bids-disabled))
    (asserts! (> previous-bid-amount u0) (err err-no-bid-found))
    (asserts! (or (is-eq previous-bidder tx-sender) (is-eq contract-owner tx-sender))
              (err err-user-not-authorized))

    (map-delete bids bid-id)

    (print {
      action: "withdraw-bid",
      payload: {
        bid_id: bid-id,
        action_event_index: (+ u1 previous-bid-action-event-index),
        collection_id: (get collection previous-bid),
        token_id: (get nft-id previous-bid),
        bidder_address: previous-bidder,
        seller_address: (get seller previous-bid),
        bid_amount: previous-bid-amount,
        expiration_block: (get expiration-block previous-bid) 
      }
    })

    (as-contract (stx-transfer? previous-bid-amount contract-address previous-bidder))
  )
)

(define-public (accept-bid (bid-id uint) (collection <nft-trait>) (nft-id uint))
  (let ((bid (get-bid bid-id))
        (bid-nft-id (get nft-id bid))
        (bid-collection (get collection bid))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (bid-action-event-index (get action-event-index bid))
        (expiration-block (get expiration-block bid))
        (nft-owner (unwrap! (get-owner collection nft-id) (err err-user-not-authorized)))
        (royalty-percent (unwrap! (get-royalty-amount collection) (err err-royalty-issue)))
        (royalty-address (unwrap! (get-royalty-address collection) (err err-royalty-issue)))
        (commission-amount (/ (* bid-amount (var-get commission)) u10000))
        (royalty-amount (/ (* bid-amount royalty-percent) u10000))
        (to-owner-amount (- (- bid-amount commission-amount) royalty-amount))
        (block block-height))
    (asserts! (var-get accepting-bids-enabled) 
              (err err-accepting-bids-disabled))
    (asserts! (> bid-amount u0) (err err-no-bid-found))
    (asserts! (is-eq (contract-of collection) bid-collection) (err err-wrong-collection))
    (asserts! (or 
                (is-none bid-nft-id) 
                (and (is-some bid-nft-id) (is-eq (unwrap-panic bid-nft-id) nft-id))) 
              (err err-wrong-nft-id))
    (asserts! (is-eq tx-sender nft-owner) (err err-user-not-authorized))
    (asserts! (> expiration-block block) (err err-bid-expired))

    (map-delete bids bid-id)
    (try! (contract-call? collection transfer nft-id tx-sender bidder))
    (and (> to-owner-amount u0)
        (try! (as-contract (stx-transfer? to-owner-amount contract-address nft-owner))))
    (and (> commission-amount u0)
        (try! (as-contract (stx-transfer? commission-amount contract-address contract-owner))))
    (and (> royalty-amount u0)
        (try! (as-contract (stx-transfer? royalty-amount contract-address royalty-address))))

    (print { 
      action: "accept-bid",
      payload: {
        bid_id: bid-id,
        action_event_index: (+ u1 bid-action-event-index),
        collection_id: collection,
        token_id: nft-id,
        bidder_address: bidder,
        seller_address: nft-owner,
        bid_amount: bid-amount, 
        expiration_block: expiration-block,
        royalty: {
          recipient_address: royalty-address,
          percent: royalty-percent
        }
      }
    })

    (ok true)
  )
)

(define-public (change-bid-amount-and-expiration (bid-id uint) (new-amount uint) (new-expiration uint))
  (let ((bid (get-bid bid-id))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (bid-collection (get collection bid))
        (bid-nft-id (get nft-id bid))
        (bid-action-event-index (get action-event-index bid))
        (seller (get seller bid))
        (block block-height)
        (new-bid (merge bid {bid-amount: new-amount, expiration-block: (+ new-expiration block), action-event-index: (+ u1 bid-action-event-index)})))
    (asserts! (var-get accepting-bids-enabled) 
              (err err-accepting-bids-disabled))
    (asserts! (> bid-amount u0) (err err-no-bid-found))
    (asserts! (is-eq tx-sender bidder) (err err-user-not-authorized))

    (if (is-eq bid-amount new-amount)
      true
      (if (< new-amount bid-amount)
        (try! (as-contract (stx-transfer? (- bid-amount new-amount) contract-address bidder)))
        (try! (stx-transfer? (- new-amount bid-amount) tx-sender contract-address))
      )
    )

    (map-set bids bid-id new-bid)

    (print { 
      action: "change-bid-amount-and-expiration",
      payload: {
        bid_id: bid-id,
        action_event_index: (get action-event-index new-bid), 
        collection_id: bid-collection,
        ;; asset_id: asset-id',
        token_id: bid-nft-id,
        bidder_address: bidder,
        seller_address: seller,
        bid_amount: (get bid-amount new-bid), 
        expiration_block: (get expiration-block new-bid),
      }
    })

    (ok true)
  )
)

(define-public (set-placing-bids-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
        (ok (var-set placing-bids-enabled enabled))
    )
)

(define-public (set-accepting-bids-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
        (ok (var-set accepting-bids-enabled enabled))
    )
)

(define-public (set-withdrawing-bids-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
        (ok (var-set withdrawing-bids-enabled enabled))
    )
)

(define-read-only (get-bid (bid-id uint))
  (default-to
    {collection: tx-sender, nft-id: none, buyer: contract-owner, seller: none, bid-amount: u0, expiration-block: block-height, action-event-index: u0}
    (map-get? bids bid-id)
  )
)

(define-private (get-owner (nft <nft-trait>) (nft-id uint))
  (unwrap-panic (contract-call? nft get-owner nft-id))
)

(define-private (get-royalty-amount (collection <nft-trait>))
  (contract-call? collection get-royalty-percent)
)

(define-private (get-royalty-address (collection <nft-trait>))
  (contract-call? collection get-artist-address)
)