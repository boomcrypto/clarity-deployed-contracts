(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token byzantion-auctions uint)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-AUCTION-NOT-OVER (err u1001))
(define-constant ERR-AUCTION-OVER (err u1002))
(define-constant ERR-RESERVE-NOT-MET (err u1003))
(define-constant ERR-BID-TOO-LOW (err u1004))
(define-constant ERR-AUCTION-NOT-LIVE (err u1005))
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var last-id uint u0)
(define-data-var commission uint u1500)
(define-data-var target-block uint u10)
(define-data-var reserve uint u100000)
(define-data-var active bool false)
(define-data-var artist-address principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)
(define-data-var commission-address principal 'SPTPHTX9A267V9CR8AY45Q6X38WANP1BA5PJ9J7H)
(define-data-var admin principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

(define-map metadata uint { uri: (string-ascii 100) })
(define-map bids { item-id: uint } { buyer: principal, offer: uint })

(define-public (bid (amount uint))
  (let (
    (next-id (+ (var-get last-id) u1))
    (bid-object (get-bid next-id))
    (offer (get offer bid-object))
    (buyer (get buyer bid-object))
    (target (var-get target-block))
    (reserve-price (var-get reserve))
  )
    (asserts! (<= block-height target) ERR-AUCTION-OVER)
    (asserts! (> amount offer) ERR-BID-TOO-LOW)
    (asserts! (>= amount reserve-price) ERR-BID-TOO-LOW)
    (asserts! (is-eq (var-get active) true) ERR-AUCTION-NOT-LIVE)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> offer u0)
          (begin
            (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
            (map-set bids { item-id: next-id } { buyer: tx-sender, offer: amount })
          )
          (map-set bids { item-id: next-id } { buyer: tx-sender, offer: amount })
        )
        (ok next-id)
    )
    error (err error)
    )
  )
)

(define-read-only (get-bid (item-id uint))
    (default-to
        { buyer: 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK, offer: u0 }
        (map-get? bids { item-id: item-id })
    )
)

(define-public (auction-ended)
  (let (
    (next-id (+ (var-get last-id) u1))
    (bid-object (get-bid next-id))
    (offer (get offer bid-object))
    (buyer (get buyer bid-object))
    (commiss (/ (* offer (var-get commission)) u10000))
    (target (var-get target-block))
    (reserve-price (var-get reserve))
    (artist (var-get artist-address))
    (commission-addr (var-get commission-address))
    (admin-address (var-get admin))
  )
    (asserts! (> block-height target) ERR-AUCTION-NOT-OVER)
    (asserts! (>= offer reserve-price) ERR-RESERVE-NOT-MET)
    (asserts! (or (is-eq tx-sender artist) (is-eq tx-sender admin-address)) (err ERR-NOT-AUTHORIZED))
    (begin
        (try! (as-contract (stx-transfer? commiss (as-contract tx-sender) commission-addr)))
        (try! (as-contract (stx-transfer? (- offer commiss) (as-contract tx-sender) (var-get artist-address))))
        (try! (nft-mint? byzantion-auctions next-id buyer))
        (map-delete bids { item-id: next-id } )
        (var-set last-id next-id)
    )
    (ok next-id)
  )
)

(define-public (admin-unbid)
    (let (
        (next-id (+ (var-get last-id) u1))
        (bid-object (get-bid next-id))
        (offer (get offer bid-object))
        (buyer (get buyer bid-object))
        (admin-address (var-get admin))
    )
        (begin
            (asserts! (is-eq tx-sender admin-address) (err ERR-NOT-AUTHORIZED))
            (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
              (map-delete bids { item-id: next-id } )
              (ok true)
        )
    )
)

(define-public (burn (value uint))
    (let (
        (admin-address (var-get admin))
    )
        (if (is-eq tx-sender (unwrap-panic (nft-get-owner? byzantion-auctions value)))
          (begin
            (try! (nft-burn? byzantion-auctions value (as-contract tx-sender)))
            (ok true)
          )
          (err ERR-NOT-AUTHORIZED)
        )
))

(define-public (mint-and-burn (value uint))
  (let (
    (admin-address (var-get admin))
  )
    (if (is-eq tx-sender admin-address)
      (begin
        (try! (nft-mint? byzantion-auctions value (as-contract tx-sender)))
        (try! (nft-burn? byzantion-auctions value (as-contract tx-sender)))
        (var-set last-id (+ (var-get last-id) u1))
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
))


(define-public (set-reserve (value uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set reserve value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-commisssion (value uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-active (value bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set active value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-mint-time (value uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set target-block value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set artist-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-commission-address (value principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set commission-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-admin (value principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (add-metadata (meta (string-ascii 100)) (item-id uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (map-set metadata item-id {
      uri: meta
      }))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? byzantion-auctions token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender (var-get admin))
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? byzantion-auctions token-id)))


;; Gets commission
(define-read-only (get-commission)
  (ok (var-get commission))
)

;; Gets artist address
(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

;; Gets artist address
(define-read-only (get-auction-end)
  (ok (var-get target-block)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (get uri (unwrap-panic (map-get? metadata token-id)))))
)