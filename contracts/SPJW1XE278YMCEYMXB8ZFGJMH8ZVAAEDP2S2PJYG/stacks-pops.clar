;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token stacks-pops uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var pop-counter uint u0)
(define-data-var pop-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-pop-uri (string-ascii 256) "")
(define-map pops-map { id: uint } { minted: bool })
(define-map pops-by-owner { owner: principal } { ids: (list 2500 uint) })
(define-data-var removing-pop-id uint u0)
(define-data-var cost-per-mint uint u10000000)
(define-data-var creator-address principal 'SP1WGVYWSZJM1EKH1TYB2BH3W4ZPEJBMW1N2B9FG0)
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get pop-counter))
  )
    (asserts! (<= count u10000) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get pop-counter))
    (idx (var-get pop-index))
    (pop-ids (unwrap-panic (get-pops-by-owner tx-sender)))
    (random-pop-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- u10000 (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? stacks-pops random-pop-id tx-sender))
        (var-set pop-counter (+ count u1))
        (map-set pops-map { id: random-pop-id } { minted: true })
        (map-set pops-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append pop-ids random-pop-id) u2500)) }
        )
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set pop-index (+ u1 (var-get pop-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u8000000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-pop-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-pops-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? pops-by-owner { owner: owner })
  )
)

(define-public (get-pops-by-owner (owner principal))
  (ok (get ids (get-pops-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? stacks-pops index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? stacks-pops index owner recipient)
      success (let ((pop-ids (unwrap-panic (get-pops-by-owner recipient))))
        (map-set pops-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append pop-ids index) u2500)) }
        )
        (try! (remove-pop owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-pop (owner principal) (pop-id uint))
  (if true
    (let ((pop-ids (unwrap-panic (get-pops-by-owner owner))))
      (var-set removing-pop-id pop-id)
      (map-set pops-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-pop pop-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-pop (pop-id uint))
  (if (is-eq pop-id (var-get removing-pop-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get pop-counter))
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

(define-public (set-token-pop-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-pop-uri value))
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
    (ok (some (var-get token-pop-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? stacks-pops index))
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
  (is-eq user (unwrap! (nft-get-owner? stacks-pops index) false))
)

;; initialize
(var-set token-pop-uri "https://www.stacksart.com/assets/pops.json")
(var-set token-uri "https://www.stacksart.com/assets/pops.json")
