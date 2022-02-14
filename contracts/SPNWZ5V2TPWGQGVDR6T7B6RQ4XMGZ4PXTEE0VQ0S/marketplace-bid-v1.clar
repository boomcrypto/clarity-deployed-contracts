(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; bids map
;; if nft-id is `none`, the bid is a collection bid
;;    and can be accepted by anyone holding a token from
;;    that collection.

(define-map bids
  { collection: principal, nft-id: (optional uint) }
  { bid-amount: uint, buyer: principal }
)

(define-constant contract-address (as-contract tx-sender))
(define-constant contract-owner tx-sender)
(define-constant err-contract-not-authorized u1)
(define-constant err-bid-too-low u2)
(define-constant err-placing-bids-disabled u3)
(define-constant err-accepting-bids-disabled u4)
(define-constant err-withdrawing-bids-disabled u5)
(define-constant err-user-not-authorized u6)
(define-constant err-no-bid-found u7)

(define-data-var placing-bids-enabled bool true)
(define-data-var accepting-bids-enabled bool true)
(define-data-var withdrawing-bids-enabled bool true)
(define-data-var commission uint u200)

(define-public (place-bid (collection principal) (nft-id (optional uint)) (amount uint))
  (let ((nft { collection: collection, nft-id: nft-id })
        (previous-bid (get-bid collection nft-id))
        (previous-bidder (get buyer previous-bid ))
        (previous-bid-amount (get bid-amount previous-bid))
    )
    (asserts! (var-get placing-bids-enabled) 
              (err err-placing-bids-disabled))
    (asserts! (contract-call? .nft-oracle is-trusted collection)
              (err err-contract-not-authorized))
    (asserts! (> amount previous-bid-amount) (err err-bid-too-low))

    (map-set bids nft { bid-amount: amount, buyer: tx-sender })
    (try! (stx-transfer? amount tx-sender contract-address))
    (if (> previous-bid-amount u0)
        (as-contract (stx-transfer? previous-bid-amount contract-address previous-bidder))
        (ok true))
  )
)

(define-public (withdraw-bid (collection principal) (nft-id (optional uint)))
  (let ((nft { collection: collection, nft-id: nft-id })
        (previous-bid (get-bid collection nft-id))
        (previous-bidder (get buyer previous-bid ))
        (previous-bid-amount (get bid-amount previous-bid)))
    (asserts! (var-get withdrawing-bids-enabled) 
              (err err-withdrawing-bids-disabled))
    (asserts! (> previous-bid-amount u0) (err err-no-bid-found))
    (asserts! (or (is-eq previous-bidder tx-sender) (is-eq contract-owner tx-sender))
              (err err-user-not-authorized))

    (map-delete bids nft)
    (as-contract (stx-transfer? previous-bid-amount contract-address previous-bidder))
  )
)

(define-public (accept-bid (collection <nft-trait>) (nft-id uint) (is-collection-bid bool))
  (let ((wrapped-nft-id (if is-collection-bid none (some nft-id)))
        (nft { collection: (contract-of collection), nft-id: wrapped-nft-id })
        (bid (get-bid (contract-of collection) wrapped-nft-id))
        (bidder (get buyer bid))
        (bid-amount (get bid-amount bid))
        (nft-owner (unwrap! (get-owner collection nft-id) (err err-user-not-authorized)))
        (royalty (get-royalty (contract-of collection)))
        (royalty-address (get address royalty))
        (commission-amount (/ (* bid-amount (var-get commission)) u10000))
        (royalty-amount (/ (* bid-amount (get percent royalty)) u10000))
        (to-owner-amount (- (- bid-amount commission-amount) royalty-amount)))
    (asserts! (var-get accepting-bids-enabled) 
              (err err-accepting-bids-disabled))
    (asserts! (contract-call? .nft-oracle is-trusted (contract-of collection))
              (err err-contract-not-authorized))
    (asserts! (> bid-amount u0) (err err-no-bid-found))
    (asserts! (is-eq tx-sender nft-owner) (err err-user-not-authorized))

    (map-delete bids nft)
    (try! (contract-call? collection transfer nft-id tx-sender bidder))
    (and (> to-owner-amount u0)
         (try! (as-contract (stx-transfer? to-owner-amount contract-address nft-owner))))
    (and (> commission-amount u0)
         (try! (as-contract (stx-transfer? commission-amount contract-address contract-owner))))
    (if (> royalty-amount u0)
      (as-contract (stx-transfer? royalty-amount contract-address royalty-address))
      (ok true))
  )
)

(define-read-only (get-bid (collection principal) (nft-id (optional uint)))
  (default-to
    { buyer: contract-owner, bid-amount: u0 }
    (map-get? bids { collection: collection, nft-id: nft-id })
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