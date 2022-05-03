(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; bids map
;; if nft-id is `none`, the bid is a collection bid
;;    and can be accepted by anyone holding a token from
;;    that collection.

(define-map bids
  uint
  { collection: principal, nft-id: (optional uint), bid-amount: uint, buyer: principal, expiration-block: uint }
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

(define-data-var placing-bids-enabled bool true)
(define-data-var accepting-bids-enabled bool true)
(define-data-var withdrawing-bids-enabled bool true)
(define-data-var commission uint u200)
(define-data-var id uint u0)

(define-public (place-bid (collection principal) (nft-id (optional uint)) (amount uint) (expiration uint) (memo (optional (buff 34))))
  (let ((block block-height)
        (next-bid-id (var-get id))
        (nft {collection: collection, nft-id: nft-id, bid-amount: amount, buyer: tx-sender, expiration-block: (+ expiration block)}))
    (asserts! (var-get placing-bids-enabled) 
              (err err-placing-bids-disabled))
    (asserts! (contract-call? .nft-oracle is-trusted collection)
              (err err-contract-not-authorized))

    (try! (stx-transfer? amount tx-sender contract-address))
    (map-set bids next-bid-id nft)
    (var-set id (+ next-bid-id u1))
    (print (merge nft {a: "place-bid", memo: memo}))
    (ok next-bid-id)
  )
)

(define-public (withdraw-bid (bid-id uint))
  (let ((previous-bid (get-bid bid-id))
        (previous-bidder (get buyer previous-bid))
        (previous-bid-amount (get bid-amount previous-bid)))
    (asserts! (var-get withdrawing-bids-enabled) 
              (err err-withdrawing-bids-disabled))
    (asserts! (> previous-bid-amount u0) (err err-no-bid-found))
    (asserts! (or (is-eq previous-bidder tx-sender) (is-eq contract-owner tx-sender))
              (err err-user-not-authorized))

    (map-delete bids bid-id)
    (print (merge previous-bid {a: "withdraw-bid"}))
    (as-contract (stx-transfer? previous-bid-amount contract-address previous-bidder))
  )
)

(define-public (accept-bid (bid-id uint) (collection <nft-trait>) (nft-id uint))
  (let ((bid (get-bid bid-id))
        (bid-nft-id (get nft-id bid))
        (bid-collection (get collection bid))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (expiration-block (get expiration-block bid))
        (nft-owner (unwrap! (get-owner collection nft-id) (err err-user-not-authorized)))
        (royalty (get-royalty (contract-of collection)))
        (royalty-address (get address royalty))
        (commission-amount (/ (* bid-amount (var-get commission)) u10000))
        (royalty-amount (/ (* bid-amount (get percent royalty)) u10000))
        (to-owner-amount (- (- bid-amount commission-amount) royalty-amount))
        (block block-height))
    (asserts! (var-get accepting-bids-enabled) 
              (err err-accepting-bids-disabled))
    (asserts! (contract-call? .nft-oracle is-trusted (contract-of collection))
              (err err-contract-not-authorized))
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
    (print (merge bid {a: "accept-bid"})) 
    (ok true)
  )
)

(define-public (change-bid-amount-and-expiration (bid-id uint) (new-amount uint) (new-expiration uint))
  (let ((bid (get-bid bid-id))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (block block-height)
        (new-bid (merge bid {bid-amount: new-amount, expiration-block: (+ new-expiration block)})))
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
    (print (merge new-bid {a: "change-bid-amount-and-expiration"})) 
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
    {collection: tx-sender, nft-id: none, buyer: contract-owner, bid-amount: u0, expiration-block: block-height }
    (map-get? bids bid-id)
  )
)

(define-private (get-owner (nft <nft-trait>) (nft-id uint))
  (unwrap-panic (contract-call? nft get-owner nft-id))
)

(define-private (get-royalty (collection principal))
  (default-to
    { address: contract-owner, percent: u0 }
    (contract-call? .nft-oracle get-royalty-amount collection))
)