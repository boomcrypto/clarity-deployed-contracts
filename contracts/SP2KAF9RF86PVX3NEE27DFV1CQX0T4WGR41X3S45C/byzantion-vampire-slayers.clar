(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token vampire-slayers uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u666)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u25000000)
(define-data-var commission-per-mint uint u24900000)
(define-data-var payout uint u0)
(define-data-var ipfs-full-metadata (string-ascii 117) "ipfs://ipfs/bafybeibmaxkf3nlxh4nhhzhg3s3ilvd2elyusn52kzi2y3nxsermfps3hi/vampire_slayers/vampire_slayers_metadata.json")
(define-data-var ipfs-root (string-ascii 104) "ipfs://ipfs/bafybeihsqrka62n6ksreqhvko7ckfv4fsy2q44g7dvo6ndiovygzmkdsoa/vampire_slayers/vampire_slayers_")
(define-data-var artist-address principal 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1)
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
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? vampire-slayers next-id new-owner))
            (var-set last-id next-id)
            (var-set payout (- (var-get cost-per-mint) (var-get commission-per-mint)))
            (try! (as-contract (stx-transfer? (var-get payout) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
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
(define-public (set-commission-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-per-mint value))
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

;; set token metadata uri
(define-public (set-root (ipfs (string-ascii 104))) 
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set ipfs-root ipfs))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; set contract metadata uri
(define-public (set-full (ipfs (string-ascii 117))) 
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set ipfs-full-metadata ipfs))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? vampire-slayers token-id sender recipient)
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
  (ok (nft-get-owner? vampire-slayers token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets commission
(define-read-only (get-commission)
  (ok (var-get commission-per-mint)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

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
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (try! (mint (var-get artist-address)))
    (ok true)
  )
