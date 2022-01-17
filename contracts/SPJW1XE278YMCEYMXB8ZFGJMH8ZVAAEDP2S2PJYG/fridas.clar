;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token fridas uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u1000)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var fridas-counter uint u0)
(define-data-var fridas-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://QmYDiSBASWjrqY2QonWcWMo9ryGGPBQ6W9e9pArvcoBcx5")
(define-data-var cost-per-mint uint u30000000)
(define-data-var creator-address principal 'SP25TXCVKJMPP634P14HVF5C4G8GFZCF2J53YCTWJ)
(define-data-var rotation uint u1)
(define-map token-count principal uint)

;; public functions
(define-public (mint)
  (let (
    (count (var-get fridas-counter))
  )
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get fridas-counter))
    (idx (var-get fridas-index))
    (random-fridas-id
      (if (is-eq (var-get rotation) u0)
        (+ u0 idx)
        (- (- ITEM-COUNT u1) (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? fridas random-fridas-id tx-sender))
        (var-set fridas-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set fridas-index (+ u1 (var-get fridas-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u25000000 (as-contract tx-sender) (var-get creator-address))))

        (map-set token-count tx-sender (+ current-balance u1))
        (ok random-fridas-id)
      )
      error (err error)
    )
  )
)

(define-public (burn (index uint))
  (let (
    (current-balance (get-balance tx-sender))
  )
    (if (is-owner index tx-sender)
      (match (nft-burn? fridas index tx-sender)
        success (begin
          (map-set token-count tx-sender (- current-balance u1))
          (ok true)
        )
        error (err error)
      )
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (let (
    (current-balance-owner (get-balance tx-sender))
    (current-balance-recipient (get-balance recipient))
  )
    (if (and (is-owner index owner) (is-owner index tx-sender))
      (match (nft-transfer? fridas index owner recipient)
        success (begin
          (map-set token-count tx-sender (- current-balance-owner u1))
          (map-set token-count recipient (+ current-balance-recipient u1))
          (ok true)
        )
        error (err error)
      )
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get fridas-counter))
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
  (ok (nft-get-owner? fridas index))
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

;; private functions

(define-private (is-owner (index uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? fridas index) false))
)
