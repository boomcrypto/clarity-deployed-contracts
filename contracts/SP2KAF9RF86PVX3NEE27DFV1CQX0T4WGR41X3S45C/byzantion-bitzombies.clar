(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token bitzombies uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u15)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u1000000000)
(define-data-var cost-reducer uint u100000000)
(define-data-var cost-floor uint u100000000)
(define-data-var commission uint u800)
(define-data-var payout uint u0)
(define-data-var first-block uint block-height)
(define-data-var block-difference uint u5)
(define-data-var ipfs-full-metadata (string-ascii 107) "ipfs://ipfs/bafybeia2lrpf6mbytha4bwv4ziqnaszygwnyowxsmtfu2m5wzry74tk7ly/bitzombies/bitzombies_metadata.json")
(define-data-var ipfs-root (string-ascii 94) "ipfs://ipfs/bafybeia2lrpf6mbytha4bwv4ziqnaszygwnyowxsmtfu2m5wzry74tk7ly/bitzombies/bitzombies_")
(define-data-var artist-address principal 'SP4DCNFNJRWKR5R8VK28V7043BT6Q2TWS9T9V30P)
(define-data-var minting-enabled bool true)

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
        (block-dif (- block-height (var-get first-block)))
        (cost (var-get cost-per-mint))
        (new-cost (- (var-get cost-per-mint) (* (/ block-dif (var-get block-difference)) (var-get cost-reducer))))
      )
      
      (print new-cost)
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (if (< block-dif u45)
        (match (stx-transfer? new-cost tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? bitzombies next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? new-cost (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
        (match (stx-transfer? (var-get cost-floor) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? bitzombies next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? (var-get cost-floor) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
      )
        )
        )

;; Public functions

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-cost-floor (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-floor value))
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

;; Allows contract owner to change artist address if need be
(define-public (set-block)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set first-block block-height))
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

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? bitzombies token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)
      )
      )

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bitzombies token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (let (
        (block-dif (- block-height (var-get first-block)))
        (cost (var-get cost-per-mint))
        (new-cost (- (var-get cost-per-mint) (* (/ block-dif (var-get block-difference)) (var-get cost-reducer))))
      )
      (if (< block-dif u45)
    (ok new-cost)
    (ok (var-get cost-floor))
  )
)
)

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))


(define-read-only (get-block-height)
  (ok block-height)
)

(define-read-only (get-initial-block)
  (ok (var-get first-block))
)

(define-read-only (get-block-difference)
  (ok (- block-height (var-get first-block)))
)

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) "_metadata.json")))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001)))) "_metadata.json")))
    )
)

(begin
  (try! (mint (var-get artist-address)))
  (ok true)
)