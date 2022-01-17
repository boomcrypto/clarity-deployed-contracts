;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token genesis-64 uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-MINT-NOT-ENABLED u102)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u64)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var genesis-counter uint u0)
(define-data-var genesis-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://<REVEAL_AFTER_MINT>")
(define-data-var creator-address principal 'SP2BN54RFN13H1VVV7E651G77D4FM9B5GX1RTH2TS)
(define-data-var rotation uint u1)
(define-data-var public-mint-enabled bool false)
(define-map token-count principal uint)

;; public functions
(define-public (whitelist-mint (index uint))
  (let (
    (count (var-get genesis-counter))
    (owner (unwrap! (unwrap! (contract-call? .zombie-wabbits get-owner index) (err ERR-NOT-AUTHORIZED)) (err ERR-NOT-AUTHORIZED)))
    (item (contract-call? .stacks-art-market-v2 get-item-for-sale u10 index))
  )
    (asserts! (<= count u25) (err ERR-ALL-MINTED))
    (asserts!
      (or
        (is-eq owner tx-sender)
        (and
          (is-some (get seller item))
          (is-eq (unwrap-panic (get seller item)) tx-sender)
        )
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (try! (mint-next u75000000 u55000000))
    (ok true)
  )
)

(define-public (mint)
  (let (
    (count (var-get genesis-counter))
  )
    (asserts! (var-get public-mint-enabled) (err ERR-MINT-NOT-ENABLED))
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next u150000000 u110000000))
    (ok true)
  )
)

(define-private (mint-next (mint-price uint) (artist-price uint))
  (let (
    (count (var-get genesis-counter))
    (idx (var-get genesis-index))
    (random-genesis-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (match (stx-transfer? mint-price tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? genesis-64 random-genesis-id tx-sender))
        (var-set genesis-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set genesis-index (+ u1 (var-get genesis-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? artist-price (as-contract tx-sender) (var-get creator-address))))

        (map-set token-count tx-sender (+ current-balance u1))
        (ok random-genesis-id)
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
      (match (nft-burn? genesis-64 index tx-sender)
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
      (match (nft-transfer? genesis-64 index owner recipient)
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
  (ok (var-get genesis-counter))
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

(define-public (enable-public-mint)
  (if (or
    (is-eq tx-sender CONTRACT-OWNER)
    (is-eq tx-sender (var-get creator-address))
  )
    (ok (var-set public-mint-enabled true))
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
  (ok (nft-get-owner? genesis-64 index))
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
  (is-eq user (unwrap! (nft-get-owner? genesis-64 index) false))
)
