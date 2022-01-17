;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token frontier uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-MINT-NOT-ENABLED u102)
(define-constant ERR-WHITELIST-MINT u103)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u768)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var frontier-counter uint u0)
(define-data-var frontier-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://<REVEAL_AFTER_MINT>")
(define-data-var creator-address principal 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD)
(define-data-var rotation uint u1)
(define-data-var public-mint-enabled bool false)
(define-map token-count principal uint)

;; public functions
(define-public (whitelist-mint (index uint))
  (let (
    (count (var-get frontier-counter))
    (owner (unwrap! (unwrap! (contract-call? .blocks get-owner index) (err ERR-NOT-AUTHORIZED)) (err ERR-NOT-AUTHORIZED)))
    (item (contract-call? .stacks-art-market-v2 get-item-for-sale u7 index))
    (current-balance (get-balance tx-sender))
  )
    (asserts! (< count u512) (err ERR-ALL-MINTED))
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
    (asserts! (< current-balance u5) (err ERR-WHITELIST-MINT))

    (try! (mint-next u32000000 u27000000))
    (ok true)
  )
)

(define-public (whitelist-mint-five (index uint))
  (begin
    (try! (whitelist-mint index))
    (try! (whitelist-mint index))
    (try! (whitelist-mint index))
    (try! (whitelist-mint index))
    (try! (whitelist-mint index))
    (ok true)
  )
)

(define-public (mint)
  (let (
    (count (var-get frontier-counter))
  )
    (asserts! (var-get public-mint-enabled) (err ERR-MINT-NOT-ENABLED))
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next u40000000 u35000000))
    (ok true)
  )
)

(define-private (mint-next (mint-price uint) (artist-price uint))
  (let (
    (count (var-get frontier-counter))
    (idx (var-get frontier-index))
    (random-frontier-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (match (stx-transfer? mint-price tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? frontier random-frontier-id tx-sender))
        (var-set frontier-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set frontier-index (+ u1 (var-get frontier-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? artist-price (as-contract tx-sender) (var-get creator-address))))

        (map-set token-count tx-sender (+ current-balance u1))
        (ok random-frontier-id)
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
      (match (nft-burn? frontier index tx-sender)
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
      (match (nft-transfer? frontier index owner recipient)
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
  (ok (var-get frontier-counter))
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
  (ok (nft-get-owner? frontier index))
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
  (is-eq user (unwrap! (nft-get-owner? frontier index) false))
)
