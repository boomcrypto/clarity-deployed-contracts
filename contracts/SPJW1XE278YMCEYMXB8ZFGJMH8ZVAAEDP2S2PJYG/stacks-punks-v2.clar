;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token stacks-punks uint)

;; constants
(define-constant PUNK-IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var punk-index uint u0)
(define-data-var punk-counter uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-punk-uri (string-ascii 256) "")
(define-map punks { id: uint } { minted: bool })
(define-map punks-by-owner { owner: principal } { ids: (list 2500 uint) })
(define-data-var removing-punk-id uint u0)
(define-data-var cost-per-mint uint u10000000)
(define-data-var rotation uint u0)

;; public functions
(define-public (claim-v1-punks)
  (let (
    (punk-ids (unwrap! (contract-call? .stacks-punks get-punks-by-owner tx-sender) (err u0)))
  )
    (map migrate-v1 punk-ids)
    (ok true)
  )
)

(define-public (mint)
  (let (
    (count (var-get punk-counter))
    (rot (var-get rotation))
    (index (var-get punk-index))
    (next-index (+ (* rot u2000) index))
  )
    (asserts! (<= count u10000) (err ERR-ALL-MINTED))
    (if (is-eq none (unwrap-panic (contract-call? .stacks-punks get-owner next-index)))
      (begin
        (try! (mint-with-id next-index))
        (try! (set-next-rotation))
        (claim-v1-punks)
      )
      (begin
        (try! (mint-with-id (+ u1 next-index)))
        (try! (set-next-rotation))
        (claim-v1-punks)
      )
    )
  )
)

(define-private (set-next-rotation)
  (let (
    (rot (var-get rotation))
  )
    (if true
      (begin
        (if (< rot u4)
          (var-set rotation (+ u1 rot))
          (begin
            (var-set rotation u0)
            (var-set punk-index (+ u1 (var-get punk-index)))
          )
        )
        (ok true)
      )
      (err u0)
    )
  )
)

(define-private (mint-with-id (random-punk-id uint))
  (let (
    (count (var-get punk-counter))
    (punk-ids (unwrap-panic (get-punks-by-owner tx-sender)))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? stacks-punks random-punk-id tx-sender))
        (var-set punk-counter (+ count u1))
        (map-set punks { id: random-punk-id } { minted: true })
        (map-set punks-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append punk-ids random-punk-id) u2500)) }
        )
        (ok random-punk-id)
      )
      error (err error)
    )
  )
)

(define-private (migrate-v1 (random-punk-id uint))
  (let (
    (count (var-get punk-counter))
    (punk-ids (unwrap-panic (get-punks-by-owner tx-sender)))
  )
    (try! (nft-mint? stacks-punks random-punk-id tx-sender))
    (try! (contract-call? .stacks-punks burn random-punk-id))
    (var-set punk-counter (+ count u1))
    (map-set punks { id: random-punk-id } { minted: true })
    (map-set punks-by-owner { owner: tx-sender }
      { ids: (unwrap-panic (as-max-len? (append punk-ids random-punk-id) u2500)) }
    )
    (ok random-punk-id)
  )
)

(define-read-only (get-punks-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? punks-by-owner { owner: owner })
  )
)

(define-public (get-punks-by-owner (owner principal))
  (ok (get ids (get-punks-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? stacks-punks index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? stacks-punks index owner recipient)
      success (let ((punk-ids (unwrap-panic (get-punks-by-owner recipient))))
        (map-set punks-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append punk-ids index) u2500)) }
        )
        (try! (remove-punk owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-punk (owner principal) (punk-id uint))
  (if true
    (let ((punk-ids (unwrap-panic (get-punks-by-owner owner))))
      (var-set removing-punk-id punk-id)
      (map-set punks-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-punk punk-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-punk (punk-id uint))
  (if (is-eq punk-id (var-get removing-punk-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get punk-counter))
)

(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-punk-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-punk-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri (id uint))
  (if (not (is-eq id u0))
    (ok (some (var-get token-punk-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? stacks-punks index))
)

(define-read-only (stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (stx-balance-of (address principal))
  (stx-get-balance address)
)

(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; private functions

(define-private (is-owner (index uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? stacks-punks index) false))
)

;; initialize
(var-set token-punk-uri "https://www.stackspunks.com/assets/punks.json")
(var-set token-uri "https://www.stackspunks.com/assets/punks.json")
