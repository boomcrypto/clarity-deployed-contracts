;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token stacks-mandala uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ITEM-COUNT u540)
(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var mandala-counter uint u0)
(define-data-var mandala-index uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-mandala-uri (string-ascii 256) "")
(define-data-var cost-per-mint uint u20000000)
(define-data-var creator-address principal 'SP2C1BVR38WHJK1RDACXDD6A4SSP10X01SVNC8EBX)
(define-data-var rotation uint u1)

;; public functions
(define-public (mint)
  (let (
    (count (var-get mandala-counter))
  )
    (asserts! (<= count ITEM-COUNT) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-public (mint-five)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get mandala-counter))
    (idx (var-get mandala-index))
    (random-mandala-id
      (if (is-eq (var-get rotation) u0)
        (+ u1 idx)
        (- ITEM-COUNT (- count idx))
      )
    )
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? stacks-mandala random-mandala-id tx-sender))
        (var-set mandala-counter (+ count u1))
        (if (is-eq u0 (var-get rotation))
          (begin
            (var-set rotation u1)
            (var-set mandala-index (+ u1 (var-get mandala-index)))
          )
          (var-set rotation u0)
        )
        (try! (as-contract (stx-transfer? u15000000 (as-contract tx-sender) (var-get creator-address))))
        (ok random-mandala-id)
      )
      error (err error)
    )
  )
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? stacks-mandala index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? stacks-mandala index owner recipient)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get mandala-counter))
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

(define-public (set-token-mandala-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-mandala-uri value))
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
    (ok (some (var-get token-mandala-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-read-only (get-owner (index uint))
  (ok (nft-get-owner? stacks-mandala index))
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
  (is-eq user (unwrap! (nft-get-owner? stacks-mandala index) false))
)

;; initialize
(var-set token-mandala-uri "https://www.stacksart.com/assets/stacks-mandala.json")
(var-set token-uri "https://www.stacksart.com/assets/stacks-mandala.json")
