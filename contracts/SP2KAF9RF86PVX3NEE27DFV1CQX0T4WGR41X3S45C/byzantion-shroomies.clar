(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token shroomies uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-SET-MINTED u102)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u210)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u21000000)
(define-data-var commission uint u800)
(define-data-var payout uint u0)
(define-data-var set-limit uint u21)
(define-data-var artist-address principal 'SP1AGWGJQZSZBJ5YA8KKPSXZ8M8RMGQB859WP3ACK)
(define-data-var minting-enabled bool true)
(define-map sets uint { ipfs-full-metadata: (string-ascii 105), ipfs-root: (string-ascii 92) })
(define-data-var last-set-id uint u0)

(define-public (claim)
  (mint tx-sender))

(define-public (claim-five)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-ten)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Internal - Register token
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (print (/ next-id (var-get set-limit)))
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (< count (var-get set-limit)) (err ERR-SET-MINTED))
      (if (is-eq (/ next-id (var-get set-limit)) u0)
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? shroomies next-id new-owner))
            (var-set last-id next-id)
            (var-set payout (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)))
            (try! (as-contract (stx-transfer? (var-get payout) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
          (match (stx-transfer? (* (var-get cost-per-mint) u10) tx-sender (as-contract tx-sender))
            success (begin
              (try! (nft-mint? shroomies next-id new-owner))
              (var-set last-id next-id)
              (var-set payout (- (* (var-get cost-per-mint) u10) (/ (* (* (var-get cost-per-mint) u10) (var-get commission)) u10000)))
              (try! (as-contract (stx-transfer? (var-get payout) (as-contract tx-sender) (var-get artist-address))))
              (ok next-id)
          ) 
          error (err error)
          )
          )
          )
        )

;; Public functions
(define-public (add-set
  (ipfs-full-metadata (string-ascii 105))
  (ipfs-root (string-ascii 92))
)
  (begin
    (asserts!
      (or
        (is-eq tx-sender CONTRACT-OWNER)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (map-set sets (var-get last-set-id) {
      ipfs-full-metadata: ipfs-full-metadata,
      ipfs-root: ipfs-root
      })
    (var-set last-set-id (+ u1 (var-get last-set-id)))
    (ok true)
  )
)

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-commission-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting on
(define-public (set-minting-enabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled true))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting off
(define-public (set-minting-disabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled false))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Change set limit
(define-public (set-new-set-limit (new-limit uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set set-limit new-limit))
    (err ERR-NOT-AUTHORIZED)
  )
)


;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? shroomies token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? shroomies token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
(if (is-eq (/ (+ (var-get last-id) u1) (var-get set-limit)) u0)
  (ok (var-get cost-per-mint))
  (ok (* (var-get cost-per-mint) u10))
)
)

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata (set-id uint))
  (ok (some (get ipfs-full-metadata (unwrap-panic (map-get? sets set-id)))))
)

(define-read-only (get-token-uri (token-id uint))
  (let (
        (set (/ (- token-id u1) u21)) 
      )
  (ok (some (concat (concat (get ipfs-root (unwrap-panic (map-get? sets set))) (unwrap-panic (contract-call? .conversion lookup token-id))) "_metadata.json")))
  )
)