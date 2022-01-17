;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token dells-riches uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var rich-counter uint u0)
(define-data-var rich-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-rich-uri (string-ascii 256) "")
(define-map riches-map { id: uint } { minted: bool })
(define-map riches-by-owner { owner: principal } { ids: (list 2500 uint) })
(define-data-var removing-rich-id uint u0)
(define-data-var cost-per-mint uint u2000000)
(define-data-var creator-address principal 'SP394DPNR80DGQTPC2CB4177RXFSFSRS503N1AFYB) ;; testnet ST1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZ2WSHZY
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get rich-counter))
  )
    (asserts! (<= count u5000) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get rich-counter))
    (idx (var-get rich-index))
    (rich-ids (unwrap-panic (get-riches-by-owner tx-sender)))
    (random-rich-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- u5000 (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? dells-riches random-rich-id tx-sender))
        (var-set rich-counter (+ count u1))
        (map-set riches-map { id: random-rich-id } { minted: true })
        (map-set riches-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append rich-ids random-rich-id) u2500)) }
        )
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set rich-index (+ u1 (var-get rich-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u1500000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-rich-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-riches-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? riches-by-owner { owner: owner })
  )
)

(define-public (get-riches-by-owner (owner principal))
  (ok (get ids (get-riches-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? dells-riches index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? dells-riches index owner recipient)
      success (let ((rich-ids (unwrap-panic (get-riches-by-owner recipient))))
        (map-set riches-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append rich-ids index) u2500)) }
        )
        (try! (remove-rich owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-rich (owner principal) (rich-id uint))
  (if true
    (let ((rich-ids (unwrap-panic (get-riches-by-owner owner))))
      (var-set removing-rich-id rich-id)
      (map-set riches-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-rich rich-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-rich (rich-id uint))
  (if (is-eq rich-id (var-get removing-rich-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get rich-counter))
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

(define-public (set-token-rich-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-rich-uri value))
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
    (ok (some (var-get token-rich-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? dells-riches index))
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
  (is-eq user (unwrap! (nft-get-owner? dells-riches index) false))
)

;; initialize
(var-set token-rich-uri "https://www.stacksart.com/assets/riches.json")
(var-set token-uri "https://www.stacksart.com/assets/riches.json")