;; Draft/test contract an upcoming BNSx auction house

;; Life Cycle of an auction
;; 1. Auction starts immediately with an expiration of 5 days
;; 2. If there are 0 bids, the auction ends after 5 days
;; 3. If there is at least n bid then we need to check within the last 24 hours (144 blocks) if there is a new bid:
;;  If there is: extend the auction by 24 hours
;;      If there is another bid within the last 24 hours: extend the auction by
;;  If there isn't: end the auction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-trait nft-trait 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.nft-trait.nft-trait)

;;;;;;;;;;;;;;;;;
;;; Constants ;;;
;;;;;;;;;;;;;;;;;

;; Blocks In Day(s)
(define-constant one-day u144)
(define-constant five-days (* u5 one-day))

;; Min reserve bid
(define-constant min-reserve-bid u5000000)

;; Min bid increase %
(define-constant min-bid-increase u10)

;; Auction House Fees
(define-constant bid-fee u1000000)

;; Null list of u0 - u99 (100)
(define-constant null-list (list 
    u0 u1 u2 u3 u4 u5 u6 u7 u8 u9
    u10 u11 u12 u13 u14 u15 u16 u17 u18 u19
    u20 u21 u22 u23 u24 u25 u26 u27 u28 u29
    u30 u31 u32 u33 u34 u35 u36 u37 u38 u39
    u40 u41 u42 u43 u44 u45 u46 u47 u48 u49
    u50 u51 u52 u53 u54 u55 u56 u57 u58 u59
    u60 u61 u62 u63 u64 u65 u66 u67 u68 u69
    u70 u71 u72 u73 u74 u75 u76 u77 u78 u79
    u80 u81 u82 u83 u84 u85 u86 u87 u88 u89
    u90 u91 u92 u93 u94 u95 u96 u97 u98 u99
))

;;;;;;;;;;;;
;;; Vars ;;;
;;;;;;;;;;;;

;; List of all admin principals
(define-data-var admins (list 5 principal) (list tx-sender))

;; List of all live auctions - all BNSX contracts on auction
(define-data-var live-auctions (list 1000 uint) (list ))

;; Auction House Status
(define-data-var auctions-status bool true)

;; Bid Status
(define-data-var bids-status bool true)

;; Only xBNS
(define-data-var only-xbns bool true)

;; Helper uint for filter
(define-data-var helper-uint uint u0)

;;;;;;;;;;;;
;;; Maps ;;;
;;;;;;;;;;;;

;; Map of live auctions
(define-map auction uint {
    ;; Seller
    seller: principal,
    ;; 5 Days After Start or Deploy (tbd)
    normal-end-height: uint,
    ;; New End Height If Extended (aka there's a valid bid in remaining 24 hours)
    next-extend-end-height: (optional uint),
    ;; Uint that tracks id of latest/winning bid
    winning-bid: (optional uint),
    ;; Min. bid price (aka reserve price)
    reserve-price: (optional uint), 
})

;; Map of auction bids
(define-map auction-bids {item: uint, bid-id: uint} {
    ;; Principal of bidder
    bidder: principal,
    ;; Bid amount in STX
    bid: uint,
})

;; Map of user
(define-map user principal {
    ;; List of active user actions
    auctions: (list 1000 uint),
    ;; List of active user bids
    bids: (list 1000 uint),
})




;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-Only Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get Live Auction
(define-read-only (get-auction (item-id uint))
    (map-get? auction item-id)
)

;; Get Bid
(define-read-only (get-bid (item-id  uint) (bid-id uint))
    (map-get? auction-bids {item: item-id, bid-id: bid-id})
)

;; Get Bid History 
;; Fetch all bids for an auction
(define-read-only (get-bid-history (item-id uint))
    (let 
        (
            (current-auction (unwrap! (map-get? auction item-id) (err "err-auction-not-found")))
            (current-auction-winning-bid (unwrap! (get winning-bid current-auction) (err "err-winning-bid-not-found")))
        )
        (ok (get bid-history (fold map-from-null-list-to-bid-history null-list {item-id: item-id, highest-bid: current-auction-winning-bid, bid-history: (list )})))
    )
)

;; Fold from null list to list of auction history
(define-private (map-from-null-list-to-bid-history (bid-id uint) (result {item-id: uint, highest-bid: uint, bid-history: (list 100 {bid-id: uint, bidder: principal, bid: uint})}))
    (match (map-get? auction-bids {item: (get item-id result), bid-id: bid-id})
        some-bid
            (merge 
                result 
                {bid-history: (unwrap! (as-max-len? (append (get bid-history result) {
                    bid-id: bid-id,
                    bidder: (get bidder some-bid),
                    bid: (get bid some-bid),
                }) u100) result)}
            )
        ;; none response
            result
    )
)

;; Get User
(define-read-only (get-user (user-principal principal))
    (map-get? user user-principal)
)

;; Get All Live Auctions
(define-read-only (get-all-live-auctions)
    (var-get live-auctions)
)

;; Get Auctions & Bids Status
(define-read-only (get-auctions-and-bids-status) {
    auction-status: (var-get auctions-status), 
    bids-status: (var-get bids-status)
})



;;;;;;;;;;;;;;;;;;;;;
;;;; Write Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Create Auction
;; @desc: Creates a 5-day auction for a bns or bnsX item
;; @param: item-principal: principal - principal of the collection contract, item-id:uint - id of the  reserve-price:uint - reserve price of the item, 
(define-public (create-auction (item uint) (optional-reserve-price (optional uint)))
    (let 
        (
            (current-user (map-get? user tx-sender))
            (current-auction (map-get? auction item))
            (current-live-auctions (var-get live-auctions))
            (current-reserve-price (match optional-reserve-price param-price param-price min-reserve-bid))
            (current-owner (unwrap! (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-owner item) (err "err-item-owner-not-found")))
        )

        ;; Assert that auctions are live
        (asserts! (var-get auctions-status) (err "err-auctions-inactive"))

        ;; Assert that map-get? for item returns none
        (asserts! (is-none current-auction) (err "err-auction-already-exists"))

        ;; Assert that item is owned by tx-sender
        (asserts! (is-eq current-owner (some tx-sender)) (err "err-not-item-owner"))

        ;; Assert that reserve price is equal to or greater than min reserve price
        (asserts! (>= current-reserve-price min-reserve-bid) (err "err-reserve-price-too-low"))
        
        ;; Transfer item to contract
        (unwrap! (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry transfer item tx-sender (as-contract tx-sender)) (err "err-item-transfer-failed"))

        ;; Update relevant maps
        ;; Update auction map
        (map-set auction item {
            seller: tx-sender,
            normal-end-height: (+ block-height five-days),
            next-extend-end-height: none,
            reserve-price: (some current-reserve-price),
            winning-bid: none,
        })

        ;; Set or update user map
        (match current-user
            existing-user
                (map-set user tx-sender (merge 
                    existing-user 
                    { auctions: (unwrap! (as-max-len? (append (get auctions existing-user) item) u1000) (err "err-user-auctions-overflow")) }
                ))
            (map-set user tx-sender { bids: (list ), auctions: (list item) })
        )

        ;; Update live auctions
        (ok (var-set live-auctions (unwrap! (as-max-len? (append current-live-auctions item) u1000) (err "err-live-auctions-overflow"))))

    )
)

;; Create Bid
;; @desc: Creates a bid for a live auction
;; @param: item-principal: principal - principal of the collection contract, item-id:uint - id of the item, bid:uint - bid amount in STX
(define-public (create-bid (item-id uint) (bid-amount uint))
    (let 
        (
            (current-user (default-to { auctions: (list ), bids: (list ) } (map-get? user tx-sender)))
            (current-user-bids (get bids current-user))
            (current-user-auctions (get auctions current-user))
            (current-auction (unwrap! (map-get? auction item-id) (err "err-auction-not-found")))
            (current-auction-winning-bid (get winning-bid current-auction))
            (current-auction-normal-end-height (get normal-end-height current-auction))
            (current-auction-next-extend-end-height (get next-extend-end-height current-auction))
            (current-live-auctions (var-get live-auctions))
        )

        ;; Assert that bids are live
        (asserts! (var-get bids-status) (err "err-bids-inactive"))

        ;; Assert that auction isn't over height-wise
        (match current-auction-next-extend-end-height
            some-branch
                (asserts! (<= block-height (unwrap! current-auction-next-extend-end-height (err "err-auction-extended-empty"))) (err "err-auction-over-extended"))
            (asserts! (<= block-height current-auction-normal-end-height) (err "err-auction-over-normal"))
        )

        ;; Check for an existing current-auction-winning-bid
        (match current-auction-winning-bid

            winning-bid-id
            ;; N Bid, aka a winning bid uint id already exists
            (let 
                (
                    (current-winning-bid (unwrap! (map-get? auction-bids {item: item-id, bid-id: winning-bid-id}) (err "err-winning-bid-not-found")))
                    (current-winning-amount (get bid current-winning-bid))
                    (current-winning-bidder (get bidder current-winning-bid))
                    (next-winning-bid-id (+ u1 winning-bid-id))
                ) 

                ;; Assert that bid amount is greater than current bid + min bid increase
                (asserts! (> bid-amount (+ current-winning-amount (* current-winning-amount (/ min-bid-increase u100)))) (err "err-bid-too-low"))

                ;; Update relevant maps
                ;; Auction map
                (map-set auction item-id (merge 
                    current-auction 
                    { winning-bid: (some (+ u1 winning-bid-id)) }
                ))
                ;; Update bid history
                (map-set auction-bids {item: item-id, bid-id: (+ u1 winning-bid-id)} {
                    bidder: tx-sender,
                    bid: bid-amount,
                })
                ;; Update user map
                (map-set user tx-sender (merge 
                    current-user 
                    { bids: (unwrap! (as-max-len? (append current-user-bids (+ u1 winning-bid-id)) u1000) (err "err-user-bids-overflow")) }
                ))

                ;; Return escrowed bid amount to previous bidder
                (unwrap! (as-contract (stx-transfer? current-winning-amount tx-sender current-winning-bidder)) (err "err-escrowed-bid-return-failed"))

                ;; Has this auction been extended?
                (match current-auction-next-extend-end-height
                    ;; Already extended
                    current-extended-end-height
                        ;; Extended, extend again by 24 hours
                        (map-set auction item-id (merge 
                            current-auction 
                            { next-extend-end-height: (some (+ current-extended-end-height one-day)) }
                        ))
                    ;; In original 5 day period, check if bid is within last 24 hours
                    (if (< (- current-auction-normal-end-height block-height) one-day)
                        ;; Within last 24 hours, update next-extend-end-height from original end height
                        (map-set auction item-id (merge 
                            current-auction 
                            { next-extend-end-height: (some (+ current-auction-normal-end-height one-day)) }
                        ))
                        ;; If not, do nothing
                        (map-set auction item-id (merge 
                            current-auction 
                            { next-extend-end-height: none }
                        ))
                    )
                )

                ;; Update auction map
                ;; Need to update extend height here if bid is placed within 24 hours of auction end
                (if (>= (- current-auction-normal-end-height block-height) one-day)
                    (map-set auction item-id (merge 
                        current-auction 
                        { next-extend-end-height: (some (+ block-height one-day)) }
                    ))
                    (map-set auction item-id (merge 
                        current-auction 
                        { next-extend-end-height: none }
                    ))
                )
                
            )

            ;; First Bid
            (begin

                ;; Assert that bid amount is greater than or equal to reserve price
                (asserts! (> bid-amount (unwrap! (get reserve-price current-auction) (err "err-reserve-price-not-found"))) (err "err-bid-too-low"))

                ;; Update relevant maps
                ;; Update auction map
                (map-set auction item-id (merge 
                    current-auction 
                    { 
                        winning-bid: (some u0), 
                    }
                ))
                ;; Update bid history
                (map-set auction-bids {item: item-id, bid-id: u0} {
                    bidder: tx-sender,
                    bid: bid-amount,
                })
                ;; Update user map
                (map-set user tx-sender (merge 
                    current-user 
                    { bids: (unwrap! (as-max-len? (append current-user-bids u0) u1000) (err "err-user-bids-overflow")) }
                ))
            )

        )

        ;; Transfer bid amount to contract
        (ok (unwrap! (stx-transfer? bid-amount tx-sender (as-contract tx-sender)) (err "err-bid-transfer-failed")))

    )
)


;;;;;;;;;;;;;;;;;;;;;
;;;; Close Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Close Auction Private
;; @desc: A private close auction function that is called whenever a public function is called
;; status tbd

;; Manual Auction Close
;; @desc: Manually closes an auction
;; @param: item-id:uint - id of the item
(define-public (close-auction-manual (item-id uint))
    (let 
        (
            (current-auction (unwrap! (map-get? auction item-id) (err "err-auction-not-found")))
            (current-auction-seller (get seller current-auction))
            (current-auction-winning-bid (get winning-bid current-auction))
            (current-auction-normal-end-height (get normal-end-height current-auction))
            (current-auction-next-extend-end-height (get next-extend-end-height current-auction))
            (current-live-auctions (var-get live-auctions))
        )

        ;; Assert that auction is over
        (asserts! (or (>= block-height current-auction-normal-end-height) (>= block-height (unwrap! current-auction-next-extend-end-height (err "err-auction-extended-empty")))) (err "err-auction-not-over"))

        ;; Check if there is a winning bid
        (match current-auction-winning-bid
            winning-bid
                (let 
                    (
                        (current-winning-bid (unwrap! (map-get? auction-bids {item: item-id, bid-id: winning-bid}) (err "err-winning-bid-not-found")))
                        (current-winning-amount (get bid current-winning-bid))
                        (current-winning-bidder (get bidder current-winning-bid))
                    )

                    ;; Send winning bid to seller
                    (unwrap! (as-contract (stx-transfer? current-winning-amount tx-sender current-auction-seller)) (err "err-winning-bid-transfer-failed"))

                    ;; Send item to winning bidder
                    (unwrap! (as-contract (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry transfer item-id tx-sender current-winning-bidder)) (err "err-item-transfer-failed"))
                )
                
            ;; No winning bid, send item back to seller
            (unwrap! (as-contract (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry transfer item-id tx-sender current-auction-seller)) (err "err-item-transfer-failed"))
        )

        ;; Delete auction from auction map
        (map-delete auction item-id)

        ;; Var-set helper-uint to item-id
        (var-set helper-uint item-id)

        ;; Var-set live-auctions by filtering out item-id
        (ok (var-set live-auctions (filter remove-uint current-live-auctions)))

    )
)

;; Helper filter function 
(define-private (remove-uint (num uint))
    (if (is-eq num (var-get helper-uint))
        false
        true
    )
)

;;;;;;;;;;;;;;;;;;;;;
;;;; Admin Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Flip Auctions
;; @desc: Flips the ability to create new auctions
;; @param: status:bool - true/false
(define-public (flip-auctions (status bool))
    (begin 
        ;; Assert that tx-sender is an admin using is-some & index-of
        (asserts! (is-some (index-of (var-get admins) tx-sender )) (err "err-not-admin"))
        ;; Update auctions-status
        (ok (var-set auctions-status status))
    )
)

;; Flip Bids
;; @desc: Flips the ability to create new bids
;; @param: status:bool - true/false
(define-public (flip-bids (status bool))
    (begin 
        ;; Assert that tx-sender is an admin using is-some & index-of
        (asserts! (is-some (index-of (var-get admins) tx-sender )) (err "err-not-admin"))
        ;; Update bids-status
        (ok (var-set bids-status status))
    )
)

;; Emergency Close Auction
;; @desc: Emergency unlists an auction
;; @param: item-principal: principal - principal of the collection contract, item-id:uint - id of the item
(define-public (emergency-close-auction (item-id uint))
    (let 
        (
            (current-auction (unwrap! (map-get? auction item-id) (err "err-auction-not-found")))
            (current-auction-seller (get seller current-auction))
            (current-auction-winning-bid (get winning-bid current-auction))
            (current-auction-normal-end-height (get normal-end-height current-auction))
            (current-auction-next-extend-end-height (get next-extend-end-height current-auction))
            (current-live-auctions (var-get live-auctions))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of
        (asserts! (is-some (index-of (var-get admins) tx-sender )) (err "err-not-admin"))

        ;; Check if there is a winning bid
        (match current-auction-winning-bid
            winning-bid
                (let 
                    (
                        (current-winning-bid (unwrap! (map-get? auction-bids {item: item-id, bid-id: winning-bid}) (err "err-winning-bid-not-found")))
                        (current-winning-amount (get bid current-winning-bid))
                        (current-winning-bidder (get bidder current-winning-bid))
                    )

                    ;; Send winning bid to seller
                    (unwrap! (as-contract (stx-transfer? current-winning-amount tx-sender current-auction-seller)) (err "err-winning-bid-transfer-failed"))

                    ;; Send item to winning bidder
                    (unwrap! (as-contract (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry transfer item-id tx-sender current-winning-bidder)) (err "err-item-transfer-failed"))
                )
                
            ;; No winning bid, send item back to seller
            (unwrap! (as-contract (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry transfer item-id tx-sender current-auction-seller)) (err "err-item-transfer-failed"))
        )

        ;; Delete auction from auction map
        (map-delete auction item-id)

        ;; Var-set helper-uint to item-id
        (var-set helper-uint item-id)

        ;; Var-set live-auctions by filtering out item-id
        (ok (var-set live-auctions (filter remove-uint current-live-auctions)))

    )
)