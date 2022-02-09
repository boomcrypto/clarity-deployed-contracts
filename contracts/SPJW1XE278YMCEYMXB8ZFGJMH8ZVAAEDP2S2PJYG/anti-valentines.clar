;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token anti-valentines uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-WHITELIST-MINT u105)
(define-constant ERR-UNWRAP u106)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u21)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var valentines-counter uint u0)
(define-data-var valentines-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://QmVyNUssKs5yXEDkSbUHM5hJXDooVy7P8iotR5ZSdGhfPv/{id}.json")
(define-data-var rotation uint u1)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; public functions
(define-public (mint (index uint))
  (let (
    (count (var-get valentines-counter))
    (genesis-owner (unwrap! (contract-call? .genesis-64 get-owner index) (err ERR-UNWRAP)))
    (wabbits-owner (unwrap! (contract-call? .zombie-wabbits get-owner index) (err ERR-UNWRAP)))
    (genesis-item (contract-call? .stacks-art-market-v2 get-item-for-sale u22 index))
    (wabbits-item (contract-call? .stacks-art-market-v2 get-item-for-sale u10 index))
    (current-balance (get-balance tx-sender))
  )
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))
    (asserts!
      (or
        (and
          (is-some genesis-owner)
          (is-eq (unwrap-panic genesis-owner) tx-sender)
        )
        (and
          (is-some wabbits-owner)
          (is-eq (unwrap-panic wabbits-owner) tx-sender)
        )
        (and
          (is-some (get seller genesis-item))
          (is-eq (unwrap-panic (get seller genesis-item)) tx-sender)
        )
        (and
          (is-some (get seller wabbits-item))
          (is-eq (unwrap-panic (get seller wabbits-item)) tx-sender)
        )
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (< current-balance u1) (err ERR-WHITELIST-MINT))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get valentines-counter))
    (idx (var-get valentines-index))
    (random-valentines-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (try! (nft-mint? anti-valentines random-valentines-id tx-sender))
    (var-set valentines-counter (+ count u1))
    (if (is-eq u0 (var-get rotation))
      (begin
        (var-set rotation u1)
        (var-set valentines-index (+ u1 (var-get valentines-index)))
      )
      (var-set rotation u0)
    )

    (map-set token-count tx-sender (+ current-balance u1))
    (ok random-valentines-id)
  )
)

(define-public (burn (index uint))
  (let (
    (current-balance (get-balance tx-sender))
  )
    (asserts! (is-sender-owner index) (err ERR-NOT-AUTHORIZED))
    (match (nft-burn? anti-valentines index tx-sender)
      success (begin
        (map-set token-count tx-sender (- current-balance u1))
        (ok true)
      )
      error (err error)
    )
  )
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? anti-valentines id sender recipient)
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
  (ok (var-get valentines-counter))
)

(define-public (freeze-metadata)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set metadata-frozen true))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-uri (value (string-ascii 256)))
  (begin
    (asserts! (is-eq false (var-get metadata-frozen)) (err ERR-NOT-AUTHORIZED))

    (if (is-eq tx-sender CONTRACT-OWNER)
      (ok (var-set token-uri value))
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-read-only (get-token-uri (id uint))
  (ok (some (var-get token-uri)))
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? anti-valentines index))
)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)
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
    (owner (unwrap! (nft-get-owner? anti-valentines id) (err ERR-NOT-FOUND)))
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
    (owner (unwrap! (nft-get-owner? anti-valentines id) false))
  )
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)
