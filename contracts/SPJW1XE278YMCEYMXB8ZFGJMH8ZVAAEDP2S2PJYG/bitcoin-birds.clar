;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token bitcoin-birds uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var bird-counter uint u0)
(define-data-var bird-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-bird-uri (string-ascii 256) "")
(define-map birds-map { id: uint } { minted: bool })
(define-map birds-by-owner { owner: principal } { ids: (list 400 uint) })
(define-data-var removing-bird-id uint u0)
(define-data-var cost-per-mint uint u20000000)
(define-data-var creator-address principal 'SP2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJJY3MV90) ;; ST2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJKRNEXKM
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get bird-counter))
  )
    (asserts! (<= count u399) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get bird-counter))
    (idx (var-get bird-index))
    (bird-ids (unwrap-panic (get-birds-by-owner tx-sender)))
    (random-bird-id
      (if (is-eq (var-get rotation) u0)
        (+ u0 idx)
        (- u399 (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? bitcoin-birds random-bird-id tx-sender))
        (var-set bird-counter (+ count u1))
        (map-set birds-map { id: random-bird-id } { minted: true })
        (map-set birds-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append bird-ids random-bird-id) u400)) }
        )
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set bird-index (+ u1 (var-get bird-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u16000000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-bird-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-birds-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? birds-by-owner { owner: owner })
  )
)

(define-public (get-birds-by-owner (owner principal))
  (ok (get ids (get-birds-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? bitcoin-birds index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? bitcoin-birds index owner recipient)
      success (let ((bird-ids (unwrap-panic (get-birds-by-owner recipient))))
        (map-set birds-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append bird-ids index) u400)) }
        )
        (try! (remove-bird owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-bird (owner principal) (bird-id uint))
  (if true
    (let ((bird-ids (unwrap-panic (get-birds-by-owner owner))))
      (var-set removing-bird-id bird-id)
      (map-set birds-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-bird bird-ids) u400)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-bird (bird-id uint))
  (if (is-eq bird-id (var-get removing-bird-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get bird-counter))
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

(define-public (set-token-bird-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-bird-uri value))
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
    (ok (some (var-get token-bird-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? bitcoin-birds index))
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
  (is-eq user (unwrap! (nft-get-owner? bitcoin-birds index) false))
)

;; initialize
(var-set token-bird-uri "https://www.stacksart.com/assets/birds.json")
(var-set token-uri "https://www.stacksart.com/assets/birds.json")
