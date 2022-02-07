;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token ghost-rock-dozen-v2 uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u12)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var ghost-counter uint u12)
(define-data-var token-uri (string-ascii 256) "ipfs://QmRSMrjge7D6fPnVAK5GS9GAraJD8CsDSycDCNqMJFr3ng/{id}.json")
(define-data-var creator-address principal 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; public functions
(define-public (burn (index uint))
  (let (
    (current-balance (get-balance tx-sender))
  )
    (asserts! (is-sender-owner index) (err ERR-NOT-AUTHORIZED))
    (match (nft-burn? ghost-rock-dozen-v2 index tx-sender)
      success (begin
        (map-set token-count tx-sender (- current-balance u1))
        (ok true)
      )
      error (err error)
    )
  )
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? ghost-rock-dozen-v2 id sender recipient)
    success
      (let (
        (sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient))
      )
        (map-set token-count sender (- sender-balance u1))
        (map-set token-count recipient (+ recipient-balance u1))
        (ok success)
      )
    error (err error)
  )
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get ghost-counter))
)

(define-public (freeze-metadata)
  (if (or
    (is-eq tx-sender CONTRACT-OWNER)
    (is-eq tx-sender (var-get creator-address))
  )
    (ok (var-set metadata-frozen true))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-uri (value (string-ascii 256)))
  (begin
    (asserts! (is-eq false (var-get metadata-frozen)) (err ERR-NOT-AUTHORIZED))

    (if (or
      (is-eq tx-sender CONTRACT-OWNER)
      (is-eq tx-sender (var-get creator-address))
    )
      (ok (var-set token-uri value))
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-public (set-creator-address (address principal))
  (if (or
    (is-eq tx-sender CONTRACT-OWNER)
    (is-eq tx-sender (var-get creator-address))
  )
    (ok (var-set creator-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri (id uint))
  (ok (some (var-get token-uri)))
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? ghost-rock-dozen-v2 index))
)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)
  )
)

(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let (
    (listing  {price: price, commission: (contract-of comm)})
  )
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)
  )
)

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let (
    (owner (unwrap! (nft-get-owner? ghost-rock-dozen-v2 id) (err ERR-NOT-FOUND)))
    (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
    (price (get price listing))
  )
    (asserts! (is-eq (contract-of comm) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)

;; private functions

(define-private (is-sender-owner (id uint))
  (let (
    (owner (unwrap! (nft-get-owner? ghost-rock-dozen-v2 id) false))
  )
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

;; initialize
(try! (nft-mint? ghost-rock-dozen-v2 u1 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u2 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u3 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u4 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u5 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u6 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u7 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u8 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u9 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u10 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u11 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(try! (nft-mint? ghost-rock-dozen-v2 u12 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N))
(map-set token-count 'SP3AV5F9Y2BAPJ0HMAF49PFCBG7J23YC2E9M07K6N u12)
