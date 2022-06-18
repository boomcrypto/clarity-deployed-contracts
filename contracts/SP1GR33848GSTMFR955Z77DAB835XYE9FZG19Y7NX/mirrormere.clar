(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

;; Non Fungible Token, using sip-009
(define-non-fungible-token mirrormere uint)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-TOKEN-NOT-MINTED u404)
(define-constant ERR-AUCTION-NOT-OVER (err u1001))
(define-constant ERR-AUCTION-OVER (err u1002))
(define-constant ERR-RESERVE-NOT-MET (err u1003))
(define-constant ERR-BID-TOO-LOW (err u1004))
(define-constant ERR-AUCTION-NOT-LIVE (err u1005))
(define-constant ERR-NOT-FOUND u1006)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var last-id uint u0)
(define-data-var commission-percentage uint u1000)
(define-data-var active bool false)
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var admin (list 1000 principal) (list 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C 'SP26K3JHN9YP2QDST5MFC3GYQY6V4Z523AGHANHMF 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX ))

(define-map metadata uint { uri: (string-ascii 100) })
(define-map bids uint { buyer: principal, offer: uint })
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-map items uint {artist: principal, royalty: uint, name: (string-ascii 256), reserve: uint, start-block: uint, end-block: uint})

(define-public (bid (item-id uint) (amount uint))
  (let (
    (bid-object (get-bid item-id))
    (item-object (unwrap! (map-get? items item-id) (err u2)))
    (offer (get offer bid-object))
    (buyer (get buyer bid-object))
    (start (get start-block item-object))
    (target (get end-block item-object))
    (reserve-price (get reserve item-object))
  )
    (asserts! (>= block-height start) ERR-AUCTION-NOT-LIVE)
    (asserts! (<= block-height target) ERR-AUCTION-OVER)
    (asserts! (> amount offer) ERR-BID-TOO-LOW)
    (asserts! (>= amount reserve-price) ERR-BID-TOO-LOW)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> offer u0)
          (begin
            (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
            (map-set bids item-id { buyer: tx-sender, offer: amount })
          )
          (map-set bids item-id { buyer: tx-sender, offer: amount })
        )
        (ok item-id)
    )
      error (err error)      
    )
  )
)

(define-read-only (get-bid (item-id uint))
    (default-to
        { buyer: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, offer: u0 }
        (map-get? bids item-id )
    )
)

(define-public (auction-ended (item-id uint))
  (let (
    (bid-object (map-get? bids item-id))
    (item-object (map-get? items item-id))
    (offer (unwrap-panic (get offer bid-object)))
    (buyer (unwrap-panic (get buyer bid-object)))
    (commiss (/ (* offer (var-get commission-percentage)) u10000))
    (commission-addr (var-get commission-address))
    (target (unwrap-panic (get end-block item-object)))
    (reserve-price (unwrap-panic (get reserve item-object)))
    (artist (unwrap-panic (get artist (map-get? items item-id))))
    (current-balance (get-balance tx-sender))
    (allowed (is-some (index-of (var-get admin) tx-sender)))
  )
    (asserts! (> block-height target) ERR-AUCTION-NOT-OVER)
    (asserts! (>= offer reserve-price) ERR-RESERVE-NOT-MET)
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (begin
        (try! (as-contract (stx-transfer? commiss (as-contract tx-sender) commission-addr)))
        (try! (as-contract (stx-transfer? (- offer commiss) (as-contract tx-sender) artist)))
        (try! (nft-mint? mirrormere item-id buyer))
        (map-set token-count buyer (+ current-balance u1))
        (map-delete bids item-id )
        (var-set last-id item-id)
    )
    (ok item-id)
  )
)

(define-public (admin-unbid (item-id uint))
  (let (
    (bid-object (map-get? bids item-id))
    (offer (unwrap-panic (get offer bid-object)))
    (buyer (unwrap-panic (get buyer bid-object)))
    (allowed (is-some (index-of (var-get admin) tx-sender)))
  )
    (begin
      (asserts! allowed (err ERR-NOT-AUTHORIZED))
      (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
        (map-delete bids item-id )
        (ok true)
    )
  )
)

(define-public (burn (item-id uint))
  (let (
    (allowed (is-some (index-of (var-get admin) tx-sender)))
  )
    (asserts! (not (is-eq (nft-get-owner? mirrormere item-id) none)) (err ERR-TOKEN-NOT-MINTED))
    (if (is-eq tx-sender (unwrap-panic (nft-get-owner? mirrormere item-id)))
      (begin
        (try! (nft-burn? mirrormere item-id tx-sender))
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
))

(define-public (set-commission (value uint))
  (if (is-eq (var-get commission-address) tx-sender)
    (ok (var-set commission-percentage value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-item (id uint))
  (default-to 
    { artist: 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK, royalty: u0, name: "None", reserve: u0, start-block: u0, end-block: u0 }
    (map-get? items id)
  )
)

(define-public (set-item (id uint) (address principal) (royalty uint) (name (string-ascii 256)) (reserve uint) (start uint) (end uint) (meta (string-ascii 100)))
  (begin
    (try! (set-royalty-address id address))
    (try! (set-royalty-amount id royalty))
    (try! (set-name id name))
    (try! (set-reserve id reserve))
    (try! (set-start-block id start))
    (try! (set-end-block id end))
    (try! (set-metadata id meta))
    (var-set last-id id)
    (ok true)
  )
)

(define-public (set-royalty-address (id uint) (item-address principal))
  (let (
    (previous-address (get artist (get-item id)))
    (item-name (get name (get-item id)))
    (item-royalty (get royalty (get-item id)))
    (item-reserve (get reserve (get-item id)))
    (item-start (get start-block (get-item id)))
    (item-end (get end-block (get-item id)))
    (object { artist: item-address, royalty: item-royalty, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender previous-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-royalty-amount (id uint) (item-amount uint))
  (let (
    (item-address (get artist (get-item id)))
    (item-name (get name (get-item id)))
    (item-reserve (get reserve (get-item id)))
    (item-start (get start-block (get-item id)))
    (item-end (get end-block (get-item id)))
    (object { artist: item-address, royalty: item-amount, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender item-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-name (id uint) (item-name (string-ascii 256)))
  (let (
    (item-address (get artist (get-item id)))
    (item-royalty (get royalty (get-item id)))
    (item-reserve (get reserve (get-item id)))
    (item-start (get start-block (get-item id)))
    (item-end (get end-block (get-item id)))
    (object { artist: item-address, royalty: item-royalty, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender item-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-reserve (id uint) (item-reserve uint))
  (let (
    (item-address (get artist (get-item id)))
    (item-royalty (get royalty (get-item id)))
    (item-start (get start-block (get-item id)))
    (item-name (get name (get-item id)))
    (item-end (get end-block (get-item id)))
    (object { artist: item-address, royalty: item-royalty, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender item-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-start-block (id uint) (item-start uint))
  (let (
    (item-address (get artist (get-item id)))
    (item-royalty (get royalty (get-item id)))
    (item-reserve (get reserve (get-item id)))
    (item-name (get name (get-item id)))
    (item-end (get end-block (get-item id)))
    (object { artist: item-address, royalty: item-royalty, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender item-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-end-block (id uint) (item-end uint))
  (let (
    (item-address (get artist (get-item id)))
    (item-royalty (get royalty (get-item id)))
    (item-reserve (get reserve (get-item id)))
    (item-name (get name (get-item id)))
    (item-start (get start-block (get-item id)))
    (object { artist: item-address, royalty: item-royalty, name: item-name, reserve: item-reserve, start-block: item-start, end-block: item-end })
    (allowed (or (is-some (index-of (var-get admin) tx-sender)) (is-eq tx-sender item-address)))
  )
    (asserts! allowed (err ERR-NOT-AUTHORIZED))
    (map-set items id object)
    (ok true)
  )
)

(define-public (set-commission-address (value principal))
  (if (is-eq (var-get commission-address) tx-sender)
    (ok (var-set commission-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-admin (values (list 100 principal)))
  (if (is-some (index-of (var-get admin) tx-sender))
    (ok (var-set admin values))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-metadata (item-id uint) (meta (string-ascii 100)))
  (if (is-some (index-of (var-get admin) tx-sender))
    (ok (map-set metadata item-id {
      uri: meta
      }))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-some (index-of (var-get admin) tx-sender))
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? mirrormere token-id)))


;; Gets commission
(define-read-only (get-commission)
  (ok (var-get commission-percentage))
)

;; Gets artist address
(define-read-only (get-artist (id uint))
  (ok (get artist (get-item id)))
)

(define-read-only (get-auction-start (id uint))
  (ok (get start-block (get-item id)))
)

(define-read-only (get-auction-end (id uint))
  (ok (get end-block (get-item id)))
)

(define-read-only (get-royalty (id uint))
  (ok (get royalty (get-item id)))
)

(define-read-only (get-name (id uint))
  (ok (get name (get-item id)))
)

(define-read-only (get-reserve (id uint))
  (ok (get reserve (get-item id)))
)

;; Gets the last created token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (get uri (unwrap-panic (map-get? metadata token-id)))))
)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? mirrormere id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? mirrormere id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? mirrormere id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))


(begin
  (try! (set-item u1 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX u800 "Mirrormere" u1000000 u64449 u64676 "ipfs://QmWWnb8Fgp9JdWV1Q7F1HvvNZhkTTtmeq66K2Qcngfy93z/mirrormere/1.json"))
  (ok true)
)
