(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token test-nfts uint)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-AUCTION-NOT-OVER (err u1001))
(define-constant ERR-AUCTION-OVER (err u1002))
(define-constant ERR-RESERVE-NOT-MET (err u1003))
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var last-id uint u0)
(define-data-var commission uint u1200)
(define-data-var target-block uint u0)
(define-data-var reserve uint u2000000)
(define-data-var active bool true)
(define-data-var artist-address principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)

(define-map metadata uint { uri: (string-ascii 53) })
(define-map bids { item-id: uint } { buyer: principal, offer: uint })

(define-public (bid (amount uint))
    (let (
        (next-id (+ (var-get last-id) u1))
        (target (var-get target-block))
    )
    (asserts! (<= block-height target) ERR-AUCTION-OVER)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
     (map-set bids { item-id: next-id } { buyer: tx-sender, offer: amount })
     (ok next-id)
    )
    error (err error)
    )
    )
)

(define-read-only (get-bid)
    (let (
        (next-id (+ (var-get last-id) u1))
    )
     (ok (map-get? bids { item-id: next-id } ))
    )
)

(define-public (auction-ended)
    (let (
        (next-id (+ (var-get last-id) u1))
        (name (map-get? bids { item-id: next-id } ))
        (offer (unwrap-panic (get offer name)))
        (commiss (/ (* offer (var-get commission)) u10000))
        (buyer (unwrap-panic (get buyer name)))
        (target (var-get target-block))
        (reserve-price (var-get reserve))
        (artist (var-get artist-address))
    )
    (asserts! (> block-height target) ERR-AUCTION-NOT-OVER)
    (asserts! (>= offer reserve-price) ERR-RESERVE-NOT-MET)
    (begin
    (try! (as-contract (stx-transfer? commiss (as-contract tx-sender) CONTRACT-OWNER)))
    (try! (as-contract (stx-transfer? (- offer commiss) (as-contract tx-sender) (var-get artist-address))))
    (try! (nft-mint? test-nfts next-id buyer))
     (map-delete bids { item-id: next-id } )
     (var-set last-id next-id)
    )
    (ok next-id)
)
)

(define-public (admin-unbid)
    (let (
        (next-id (+ (var-get last-id) u1))
        (name (map-get? bids { item-id: next-id } ))
        (offer (unwrap-panic (get offer name)))
        (buyer (unwrap-panic (get buyer name)))
    )
    (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
     (map-delete bids { item-id: next-id } )
     (ok true)
    )
)
)

(define-public (burn (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
  (begin
    (try! (nft-mint? test-nfts value (as-contract tx-sender)))
    (try! (nft-burn? test-nfts value (as-contract tx-sender)))
    (var-set last-id (+ (var-get last-id) u1))
    (ok true)
  )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-reserve (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set reserve value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-commisssion (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-active (value bool))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set active value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (add-metadata (meta (string-ascii 53)))
(let (
        (next-id (+ (var-get last-id) u1))
    )
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (map-set metadata next-id {
      uri: meta
      }))
    (err ERR-NOT-AUTHORIZED)
  )
)
)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? test-nfts token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? test-nfts token-id)))


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