;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token happy-welsh uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u2000)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var welsh-counter uint u0)
(define-data-var welsh-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://QmTZ7BtjVrxGnELvzb2HXv3K7mf6PQ4Mvgz7nvpWdFKtCQ/{id}.json")
(define-data-var cost-per-mint uint u50000000)
(define-data-var marketplace-commission uint u5000000)
(define-data-var creator-address principal 'SP28W4CM7T6RYGXHDA0BQPBYNKYSTSFCP0M6FJB0T)
(define-data-var rotation uint u1)
(define-data-var market-enabled bool false)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; public functions
(define-public (mint)
  (let (
    (count (var-get welsh-counter))
  )
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-public (mint-three)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)
  )
)

(define-public (mint-five)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get welsh-counter))
    (idx (var-get welsh-index))
    (random-welsh-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? happy-welsh random-welsh-id tx-sender))
        (var-set welsh-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set welsh-index (+ u1 (var-get welsh-index)))
          )
          (var-set rotation u0)
        )
        (try!
          (as-contract
            (stx-transfer? (- (var-get cost-per-mint) (var-get marketplace-commission)) (as-contract tx-sender) (var-get creator-address))
          )
        )

        (map-set token-count tx-sender (+ current-balance u1))
        (ok random-welsh-id)
      )
      error (err error)
    )
  )
)

(define-public (burn (index uint))
  (let (
    (current-balance (get-balance tx-sender))
  )
    (asserts! (is-sender-owner index) (err ERR-NOT-AUTHORIZED))
    (match (nft-burn? happy-welsh index tx-sender)
      success (begin
        (map-set token-count tx-sender (- current-balance u1))
        (ok true)
      )
      error (err error)
    )
  )
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? happy-welsh id sender recipient)
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
  (ok (var-get welsh-counter))
)

(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
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

(define-public (enable-market)
  (if (or
    (is-eq tx-sender CONTRACT-OWNER)
    (is-eq tx-sender (var-get creator-address))
  )
    (ok (var-set market-enabled true))
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
  (ok (nft-get-owner? happy-welsh index))
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
    (asserts! (var-get market-enabled) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (var-get market-enabled) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)
  )
)

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let (
    (owner (unwrap! (nft-get-owner? happy-welsh id) (err ERR-NOT-FOUND)))
    (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
    (price (get price listing))
  )
    (asserts! (var-get market-enabled) (err ERR-NOT-AUTHORIZED))
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
    (owner (unwrap! (nft-get-owner? happy-welsh id) false))
  )
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)
