;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token blue-ridge-biker uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var blue-ridge-index uint u0)
(define-data-var blue-ridge-counter uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-blue-ridge-uri (string-ascii 256) "")
(define-map blue-ridges { id: uint } { minted: bool })
(define-map blue-ridge-by-owner { owner: principal } { ids: (list 6 uint) })
(define-data-var removing-blue-ridge-id uint u0)
(define-data-var cost-per-mint uint u1000000000)
(define-data-var creator-address principal 'SPTQQE9SEV82CZ3DWCV5AY8ZSX3HK3GK7FTAZNV8) ;; SPTQQE9SEV82CZ3DWCV5AY8ZSX3HK3GK7FTAZNV8
(define-data-var nft-ids (list 6 uint) (list u3 u0 u2 u1 u5 u4))

;; public functions
(define-public (mint)
  (begin
    (asserts! (<= (var-get blue-ridge-counter) u5) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get blue-ridge-counter))
    (blue-ridge-ids (unwrap-panic (get-blue-ridge-by-owner tx-sender)))
    (random-blue-ridge-id (unwrap-panic (element-at (var-get nft-ids) (var-get blue-ridge-index))))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? blue-ridge-biker random-blue-ridge-id tx-sender))
        (var-set blue-ridge-counter (+ u1 count))
        (var-set blue-ridge-index (+ u1 (var-get blue-ridge-index)))
        (map-set blue-ridges { id: random-blue-ridge-id } { minted: true })
        (map-set blue-ridge-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append blue-ridge-ids random-blue-ridge-id) u6)) }
        )
        (try! (as-contract (stx-transfer? u750000000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-blue-ridge-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-blue-ridge-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? blue-ridge-by-owner { owner: owner })
  )
)

(define-public (get-blue-ridge-by-owner (owner principal))
  (ok (get ids (get-blue-ridge-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? blue-ridge-biker index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? blue-ridge-biker index owner recipient)
      success (let ((blue-ridge-ids (unwrap-panic (get-blue-ridge-by-owner recipient))))
        (map-set blue-ridge-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append blue-ridge-ids index) u6)) }
        )
        (try! (remove-blue-ridge owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-blue-ridge (owner principal) (blue-ridge-id uint))
  (if true
    (let ((blue-ridge-ids (unwrap-panic (get-blue-ridge-by-owner owner))))
      (var-set removing-blue-ridge-id blue-ridge-id)
      (map-set blue-ridge-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-blue-ridges blue-ridge-ids) u6)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-blue-ridges (blue-ridge-id uint))
  (if (is-eq blue-ridge-id (var-get removing-blue-ridge-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get blue-ridge-counter))
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

(define-public (set-token-blue-ridge-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-blue-ridge-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-creator-address (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set creator-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri (id uint))
  (if (not (is-eq id u0))
    (ok (some (var-get token-blue-ridge-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? blue-ridge-biker index))
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
  (is-eq user (unwrap! (nft-get-owner? blue-ridge-biker index) false))
)

;; initialize
(var-set token-blue-ridge-uri "https://www.stacksart.com/assets/blue_ridge_biker.json")
(var-set token-uri "https://www.stacksart.com/assets/blue_ridge_biker.json")
