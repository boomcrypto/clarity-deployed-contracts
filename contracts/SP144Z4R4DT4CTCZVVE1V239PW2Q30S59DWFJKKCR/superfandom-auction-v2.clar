;; superfandom-auction-v2

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; bids map
;; if nft-id is `none`, the bid is a collection bid
;;    and can be accepted by anyone holding a token from
;;    that collection.

(define-map bids
  {
    collection: principal, 
    nft-id: uint,
  }
  {  
    bid-amount: uint, 
    buyer: principal, 
    seller: (optional principal), 
    ;; expiration-block: uint, 
    action-event-index: uint,
    memo: (optional (string-ascii 256))
  }
)

(define-constant contract-address (as-contract tx-sender))
(define-constant contract-owner tx-sender)
(define-constant blocks-per-day u144)
(define-constant err-contract-not-authorized u101)
(define-constant err-placing-bids-disabled u102)
(define-constant err-accepting-bids-disabled u103)
(define-constant err-withdrawing-bids-disabled u104)
(define-constant err-user-not-authorized u105)
(define-constant err-no-bid-found u106)
(define-constant err-bid-expired u107)
(define-constant err-wrong-collection u108)
(define-constant err-wrong-nft-id u109)
(define-constant err-not-enough-bid-expiry u110)
(define-constant err-not-enough-bid-amount u111)

(define-data-var placing-bids-enabled bool true)
(define-data-var accepting-bids-enabled bool true)
(define-data-var commission uint u0)
(define-data-var id uint u0)

;; #[allow(unchecked_data)]
(define-public (place-bid (collection <nft-trait>) (nft-id uint) (amount uint) (memo (optional (string-ascii 256))))
  (let ((block block-height)
        (nft-owner (get-owner collection nft-id))  
        (nft { bid-amount: amount, buyer: tx-sender, seller: nft-owner, action-event-index: u0, memo: memo,
         })
        )
    
    (asserts! (var-get placing-bids-enabled) (err err-placing-bids-disabled))

    (match (map-get? bids {collection: (contract-of collection), nft-id: nft-id})
        bid (begin
                (asserts! (>= amount (+ (get bid-amount bid) u1000000)) (err err-not-enough-bid-amount))
                
                ;; Review for social engineering attack
                (map-delete bids {collection: (contract-of collection), nft-id: nft-id})
                (try! (as-contract (stx-transfer? (get bid-amount bid) contract-address (get buyer bid))))
                (unwrap-panic (private-place-bid collection nft-id nft))
            )
            (begin
                (asserts! (>= amount u1000000)
                          (err err-not-enough-bid-amount))
                (unwrap-panic (private-place-bid collection nft-id nft))
            )
            
    )
    (ok "Bid placed")
  )
)

;; Removed (expiration-block uint) from nft tuple
(define-private (private-place-bid (collection <nft-trait>) (nft-id uint)

    (nft (tuple
         (bid-amount uint) (buyer principal)
          
           (seller (optional principal)) 
         (action-event-index uint) (memo (optional (string-ascii 256)))
    ))
)
    (begin
        (map-set bids {collection: (contract-of collection), nft-id: nft-id} nft)
        (try! (stx-transfer? (get bid-amount nft) tx-sender contract-address))
        (print { 
            action: "place-bid",
            payload: {
                action_event_index: (get action-event-index nft),
                collection_id: (contract-of collection),
                token_id: nft-id,
                bidder_address: tx-sender,
                seller_address: (get seller nft),
                bid_amount: (get bid-amount nft), 
                memo: (get memo nft)
            }
        })
    (ok true)
    )
)

;; #[allow(unchecked_data)]
(define-public (accept-bid (collection <nft-trait>) (nft-id uint))
  (let ((bid (get-bid collection nft-id))
        (bid-nft-id nft-id)
        (bid-collection (contract-of collection))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (bid-action-event-index (get action-event-index bid))
        (nft-owner (unwrap! (get-owner collection nft-id) (err err-user-not-authorized)))
        (royalty (get-royalty (contract-of collection)))
        (royalty-address (get address royalty))
        (commission-amount (/ (* bid-amount (var-get commission)) u10000))
        (royalty-amount (/ (* bid-amount (get percent royalty)) u10000))
        (to-owner-amount (- (- bid-amount commission-amount) royalty-amount))
        (block block-height))
    (asserts! (var-get accepting-bids-enabled) 
              (err err-accepting-bids-disabled))
    (asserts! (> bid-amount u0) (err err-no-bid-found))
    (asserts! (is-eq (contract-of collection) bid-collection) (err err-wrong-collection))
    (asserts! (is-eq tx-sender nft-owner) (err err-user-not-authorized))

    (map-delete bids {collection: (contract-of collection), nft-id: nft-id})
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
        action_event_index: (+ u1 bid-action-event-index),
        collection_id: (contract-of collection),
        token_id: nft-id,
        bidder_address: bidder,
        seller_address: nft-owner,
        bid_amount: bid-amount, 
        royalty: {
          recipient_address: royalty-address,
          percent: (get percent royalty),
        }
      }
    })

    (ok true)
  )
)


;; #[allow(unchecked_data)]
(define-public (set-placing-bids-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
        (ok (var-set placing-bids-enabled enabled))
    )
)

;; #[allow(unchecked_data)]
(define-public (refund-bid (collection <nft-trait>) (nft-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
    (match (map-get? bids {collection: (contract-of collection), nft-id: nft-id})
        bid (begin
                
                (map-delete bids {collection: (contract-of collection), nft-id: nft-id})
                (try! (as-contract (stx-transfer? (get bid-amount bid) contract-address (get buyer bid))))
                (print {
                  amount-refunded: (get bid-amount bid),
                })
                (unwrap-panic (ok true))
               
            )
            (begin
                (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
                (unwrap-panic (ok true))
            )
            
    )
    (ok "Bid refunded")
  )
)

;; #[allow(unchecked_data)]
(define-public (set-accepting-bids-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
        (ok (var-set accepting-bids-enabled enabled))
    )
)

;; #[allow(unchecked_data)]
(define-public (set-commission (comm uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-user-not-authorized))
    (ok (var-set commission comm))))

(define-read-only (get-bid (collection <nft-trait>) (nft-id uint))
  (default-to
    {buyer: contract-owner, seller: none, bid-amount: u0,
      action-event-index: u0}
    (map-get? bids {collection: (contract-of collection), nft-id: nft-id})
  )
)

(define-private (get-owner (nft <nft-trait>) (nft-id uint))
  (unwrap-panic (contract-call? nft get-owner nft-id))
)

(define-private (get-royalty (collection principal))
  ;; (default-to
    { address: contract-owner, percent: u0 }
    ;; (contract-call? .nft-oracle-v2 get-royalty-amount collection))
)