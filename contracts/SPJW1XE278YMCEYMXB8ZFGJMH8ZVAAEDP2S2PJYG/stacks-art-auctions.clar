;; Auction StacksArt Pieces
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-NO-BID u101)
(define-constant ERR-ITEM-NOT-FOR-SALE u102)
(define-constant ERR-AUCTION-ENDED u103)
(define-constant ERR-AUCTION-NOT-OVER u104)
(define-constant ERR-AUCTION-NOT-LONG-ENOUGH u105)
(define-constant ERR-METADATA-NOT-FROZEN u106)
(define-constant ERR-ITEM-OWNER-NOT-FOUND u107)

(define-data-var CONTRACT-OWNER principal tx-sender)

(define-data-var enforce-frozen-metadata bool false)
(define-data-var standard-commission uint u1500)
(define-data-var standard-royalty uint u500)
(define-data-var last-auction-id uint u1)

(define-map auctions { auction-id: uint } {
  stacks-art-id: uint,                    ;; ID of the stacks-art NFT
  seller: principal,                      ;; address selling the item
  commission: uint,                       ;; commission
  royalty: uint,                          ;; secondary sales royalty
  minimum-price: uint,                    ;; Minimum price (e.g. to start the auction)
  end-block-height: (optional uint),      ;; when auction ends
  block-length: uint,                     ;; the length of the auction in blocks
  type: uint,                             ;; 1 - start immediately; 2 - start when minimum price is bid
  listed: bool,                           ;; indicates sell status
})
(define-map auction-bids { auction-id: uint } { buyer: principal, offer: uint })

(define-read-only (get-auction (auction-id uint))
  (default-to
    {
      stacks-art-id: u0,
      seller: (var-get CONTRACT-OWNER),
      commission: u9999,
      royalty: u0,
      minimum-price: u0,
      end-block-height: none,
      block-length: u0,
      type: u1,
      listed: false
    }
    (map-get? auctions { auction-id: auction-id })
  )
)

(define-read-only (get-auction-bid (auction-id uint))
  (default-to
    { buyer: (var-get CONTRACT-OWNER), offer: u0 }
    (map-get? auction-bids { auction-id: auction-id })
  )
)

;; Add a new auction
;; Length should be 1 day (144 blocks), 3 days (432 blocks) or 5 days (720 blocks)
(define-public (add-auction
  (stacks-art-id uint)
  (minimum-price uint)
  (block-length uint)
  (type uint)
)
  (let (
    (owner (unwrap! (unwrap-panic (contract-call? .stacks-art-nft get-owner stacks-art-id)) (err ERR-ITEM-OWNER-NOT-FOUND)))
    (metadata (contract-call? .stacks-art-nft get-metadata stacks-art-id))
    (id (var-get last-auction-id))
  )
    (asserts! (is-eq contract-caller owner) (err ERR-NOT-AUTHORIZED))
    (asserts! (or (not (var-get enforce-frozen-metadata)) (get frozen metadata)) (err ERR-METADATA-NOT-FROZEN))
    (asserts! (> block-length u1) (err ERR-AUCTION-NOT-LONG-ENOUGH))

    (map-set auctions { auction-id: id } {
      stacks-art-id: stacks-art-id,
      seller: owner,
      commission: (var-get standard-commission),
      royalty: (var-get standard-royalty),
      minimum-price: minimum-price,
      end-block-height: (if (is-eq type u1) (some (+ block-height block-length)) none),
      block-length: block-length,
      type: type,
      listed: true
    })
    (var-set last-auction-id (+ u1 id))

    (try! (contract-call? .stacks-art-nft transfer stacks-art-id tx-sender (as-contract tx-sender)))
    (ok id)
  )
)

;; Place a bid on an auction
;; Bids are final and cannot be withdrawn
(define-public (bid-auction (auction-id uint) (amount uint))
  (let (
    (auction (get-auction auction-id))
    (metadata (contract-call? .stacks-art-nft get-metadata (get stacks-art-id auction)))
    (bid (get-auction-bid auction-id))
  )
    (asserts! (get listed auction) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts!
      (or
        (is-none (get end-block-height auction))
        (< block-height (unwrap! (get end-block-height auction) (ok u0)))
      )
      (err ERR-AUCTION-ENDED)
    )
    (asserts! (>= amount (get minimum-price auction)) (err ERR-BID-NOT-HIGH-ENOUGH))
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (if (is-none (get end-block-height auction))
      (map-set auctions { auction-id: auction-id } (merge auction {
        end-block-height: (some (+ block-height (get block-length auction)))
      }))
      true
    )
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
            (map-delete auction-bids { auction-id: auction-id })
          )
          true
        )
        (map-set auction-bids { auction-id: auction-id } { buyer: tx-sender, offer: amount })
        (print {
          type: "stacks-art-auctions",
          action: "bid-auction",
          data: { auction-id: auction-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (end-auction (auction-id uint))
  (let (
    (auction (get-auction auction-id))
    (metadata (contract-call? .stacks-art-nft get-metadata (get stacks-art-id auction)))
    (bid (get-auction-bid auction-id))
    (commission (/ (* (get offer bid) (get commission auction)) u10000))
    (royalty (/ (* (get offer bid) (get royalty auction)) u10000))
  )
    (asserts! (get listed auction) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts!
      (and
        (is-some (get end-block-height auction))
        (>= block-height (unwrap-panic (get end-block-height auction)))
      )
      (err ERR-AUCTION-NOT-OVER)
    )

    (map-set auctions { auction-id: auction-id } (merge auction { listed: false }))
    (if (>= (get offer bid) (get minimum-price auction))
      (begin
        (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) tx-sender (get seller auction))))
        (try! (as-contract (stx-transfer? commission tx-sender (var-get CONTRACT-OWNER))))
        (if (> royalty u0)
          (try! (as-contract (stx-transfer? royalty tx-sender (get creator metadata))))
          true
        )
        (try! (as-contract (contract-call? .stacks-art-nft transfer (get stacks-art-id auction) tx-sender (get buyer bid))))
      )
      (begin
        ;; no bids - end auction, returning the item back to the owner
        (try! (as-contract (contract-call? .stacks-art-nft transfer (get stacks-art-id auction) tx-sender (get seller auction))))
      )
    )

    (print {
      type: "stacks-art-auctions",
      action: "end-auction",
      data: { auction-id: auction-id }
    })
    (ok auction-id)
  )
)

(define-public (admin-unlist (auction-id uint))
  (let (
    (auction (get-auction auction-id))
    (bid (get-auction-bid auction-id))
  )
    (asserts! (get listed auction) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))

    (map-delete auctions { auction-id: auction-id })
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete auction-bids { auction-id: auction-id })
      )
      true
    )

    (print {
      type: "stacks-art-auctions",
      action: "admin-unlist",
      data: { auction-id: auction-id }
    })
    (as-contract (contract-call? .stacks-art-nft transfer (get stacks-art-id auction) tx-sender (get seller auction)))
  )
)

(define-public (admin-remove-bid (auction-id uint))
  (let (
    (auction (get-auction auction-id))
    (bid (get-auction-bid auction-id))
  )
    (asserts! (get listed auction) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid)))
      success (begin
        (map-delete auction-bids { auction-id: auction-id })
        (print {
          type: "stacks-art-auctions",
          action: "admin-remove-bid",
          data: { auction-id: auction-id, buyer: (get buyer bid) }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (set-commission (auction-id uint) (commission uint))
  (let (
    (auction (get-auction auction-id))
  )
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))

    (map-set auctions { auction-id: auction-id } (merge auction { commission: commission }))
    (ok true)
  )
)

(define-public (set-royalty (auction-id uint) (royalty uint))
  (let (
    (auction (get-auction auction-id))
  )
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))

    (map-set auctions { auction-id: auction-id } (merge auction { royalty: royalty }))
    (ok true)
  )
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))

    (var-set CONTRACT-OWNER owner)
    (ok true)
  )
)

(define-public (set-enforce-frozen-metadata)
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get enforce-frozen-metadata)) (err ERR-NOT-AUTHORIZED))

    (var-set enforce-frozen-metadata true)
    (ok true)
  )
)
