;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token belles-witches uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var witch-counter uint u0)
(define-data-var witch-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-witch-uri (string-ascii 256) "")
(define-map witches-map { id: uint } { minted: bool })
(define-map witches-by-owner { owner: principal } { ids: (list 2500 uint) })
(define-data-var removing-witch-id uint u0)
(define-data-var cost-per-mint uint u2000000)
(define-data-var creator-address principal 'SP394DPNR80DGQTPC2CB4177RXFSFSRS503N1AFYB) ;; testnet ST1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZ2WSHZY
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get witch-counter))
  )
    (asserts! (<= count u5000) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get witch-counter))
    (idx (var-get witch-index))
    (witch-ids (unwrap-panic (get-witches-by-owner tx-sender)))
    (random-witch-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- u5000 (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? belles-witches random-witch-id tx-sender))
        (var-set witch-counter (+ count u1))
        (map-set witches-map { id: random-witch-id } { minted: true })
        (map-set witches-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append witch-ids random-witch-id) u2500)) }
        )
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set witch-index (+ u1 (var-get witch-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u1500000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-witch-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-witches-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? witches-by-owner { owner: owner })
  )
)

(define-public (get-witches-by-owner (owner principal))
  (ok (get ids (get-witches-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? belles-witches index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? belles-witches index owner recipient)
      success (let ((witch-ids (unwrap-panic (get-witches-by-owner recipient))))
        (map-set witches-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append witch-ids index) u2500)) }
        )
        (try! (remove-witch owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-witch (owner principal) (witch-id uint))
  (if true
    (let ((witch-ids (unwrap-panic (get-witches-by-owner owner))))
      (var-set removing-witch-id witch-id)
      (map-set witches-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-witch witch-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-witch (witch-id uint))
  (if (is-eq witch-id (var-get removing-witch-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get witch-counter))
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

(define-public (set-token-witch-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-witch-uri value))
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
    (ok (some (var-get token-witch-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? belles-witches index))
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
  (is-eq user (unwrap! (nft-get-owner? belles-witches index) false))
)

;; initialize
(var-set token-witch-uri "https://www.stacksart.com/assets/witches.json")
(var-set token-uri "https://www.stacksart.com/assets/witches.json")