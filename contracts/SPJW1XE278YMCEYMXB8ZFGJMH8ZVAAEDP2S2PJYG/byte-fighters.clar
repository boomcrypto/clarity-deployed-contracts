;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token byte-fighters uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var fighter-counter uint u0)
(define-data-var fighter-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-fighter-uri (string-ascii 256) "")
(define-map fighters-map { id: uint } { minted: bool })
(define-map fighters-by-owner { owner: principal } { ids: (list 2500 uint) })
(define-data-var removing-fighter-id uint u0)
(define-data-var cost-per-mint uint u20000000)
(define-data-var creator-address principal 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570)
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get fighter-counter))
  )
    (asserts! (<= count u1000) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get fighter-counter))
    (idx (var-get fighter-index))
    (fighter-ids (unwrap-panic (get-fighters-by-owner tx-sender)))
    (random-fighter-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- u1000 (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? byte-fighters random-fighter-id tx-sender))
        (var-set fighter-counter (+ count u1))
        (map-set fighters-map { id: random-fighter-id } { minted: true })
        (map-set fighters-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append fighter-ids random-fighter-id) u2500)) }
        )
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set fighter-index (+ u1 (var-get fighter-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u15000000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-fighter-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-fighters-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? fighters-by-owner { owner: owner })
  )
)

(define-public (get-fighters-by-owner (owner principal))
  (ok (get ids (get-fighters-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? byte-fighters index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? byte-fighters index owner recipient)
      success (let ((fighter-ids (unwrap-panic (get-fighters-by-owner recipient))))
        (map-set fighters-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append fighter-ids index) u2500)) }
        )
        (try! (remove-fighter owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-fighter (owner principal) (fighter-id uint))
  (if true
    (let ((fighter-ids (unwrap-panic (get-fighters-by-owner owner))))
      (var-set removing-fighter-id fighter-id)
      (map-set fighters-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-fighter fighter-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-fighter (fighter-id uint))
  (if (is-eq fighter-id (var-get removing-fighter-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get fighter-counter))
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

(define-public (set-token-fighter-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-fighter-uri value))
    (err ERR-NOT-AUTHORIZED)
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
  (if (not (is-eq id u0))
    (ok (some (var-get token-fighter-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? byte-fighters index))
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
  (is-eq user (unwrap! (nft-get-owner? byte-fighters index) false))
)

;; initialize
(var-set token-fighter-uri "https://www.stacksart.com/assets/fighters.json")
(var-set token-uri "https://www.stacksart.com/assets/fighters.json")
