;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token nimbus uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u30)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var nimbus-counter uint u0)
(define-data-var nimbus-index uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://QmPRc25oCzNzraGwQcKMrn3Uu6K9BRj3KW6KqJCN1qzrHW")
(define-data-var cost-per-mint uint u250000000)
(define-data-var creator-address principal 'SPVVB6WRVE757VKEB2T0X5ZY4DMFJAX248XXQHHW)
(define-data-var rotation uint u1)
(define-map token-count principal uint)

;; public functions
(define-public (mint)
  (let (
    (count (var-get nimbus-counter))
  )
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get nimbus-counter))
    (idx (var-get nimbus-index))
    (random-nimbus-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
    (current-balance (get-balance tx-sender))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? nimbus random-nimbus-id tx-sender))
        (var-set nimbus-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set nimbus-index (+ u1 (var-get nimbus-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u180000000 (as-contract tx-sender) (var-get creator-address))))

        (map-set token-count tx-sender (+ current-balance u1))
        (ok random-nimbus-id)
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
      (match (nft-burn? nimbus index tx-sender)
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
      (match (nft-transfer? nimbus index owner recipient)
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
  (ok (var-get nimbus-counter))
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
  (ok (nft-get-owner? nimbus index))
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
  (is-eq user (unwrap! (nft-get-owner? nimbus index) false))
)
