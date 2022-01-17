(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stackies-nft uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant ERR-NOT-MINT-TIME (err u1001))
(define-constant ERR-WHITELIST-PERIOD (err u1002))
(define-constant MINT-LIMIT u200)
(define-constant WHITELIST (list 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P 'SP2JZHPYW51Z89NSKGAEHMCMCRR2DXW1JHSARFX52 'SP3CE32MAM488RHSATA55ABVXF0GKZFH8B7BKPF4Z 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D 'SP3Q4KN09EP15WVF6WK8G6T673V7DKFWT1DEQF216 'SP1GZD7GWEGC2ZBE27J95Q3YE3F7PEBFHTKPCDXZS 'SP2AA7FSAF0BNEY7CQWHKVJ09FW7JWDMSQHA78KD0))
(define-constant RESERVED (list u5 u15 u18 u21 u27))

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u35000000)
(define-data-var commission uint u1500)
(define-data-var payout uint u0)
(define-data-var target-block uint u41179)
(define-data-var ipfs-full-metadata (string-ascii 76) "ipfs://QmYbVumNX42jXgdEBLXzvKg52umXQspWnKajP5rpst1aCT/stackies_metadata.json")
(define-data-var ipfs-root (string-ascii 54) "ipfs://QmYbVumNX42jXgdEBLXzvKg52umXQspWnKajP5rpst1aCT/")
(define-data-var artist-address principal 'SP1PBGAGP27T5E0AB374ATSPWBAK8TM6XNNJWTVPE)

(define-data-var minting-enabled bool true)

(define-public (claim)
(if (> block-height (var-get target-block))
  (mint tx-sender)
  (whitelist-mint tx-sender)
  )
)

(define-public (claim-two)
(if (> block-height (var-get target-block))
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
  (begin
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (ok true)
  )
)
)

(define-public (claim-five)
(if (> block-height (var-get target-block))
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
  (begin
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (ok true)
  )
)
)

(define-public (claim-ten)
(if (> block-height (var-get target-block))
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
  (begin
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (try! (whitelist-mint tx-sender))
    (ok true)
  )
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
        (target (var-get target-block))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (>= block-height target) ERR-NOT-MINT-TIME)
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (if (is-eq (is-some (index-of RESERVED next-id)) true)
          (begin
            (try! (nft-mint? stackies-nft next-id (var-get artist-address)))
            (try! (nft-mint? stackies-nft (+ next-id u1) new-owner))
            (var-set last-id (+ next-id u1))
          )
          (begin
            (try! (nft-mint? stackies-nft next-id new-owner))
            (var-set last-id next-id)
          )
          )
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) CONTRACT-OWNER)))
            (try! (as-contract (stx-transfer? (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

(define-private (whitelist-mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (target (var-get target-block))
        (whitelist-cost (- (var-get cost-per-mint) u15000000))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (is-eq (is-some (index-of WHITELIST tx-sender)) true) ERR-WHITELIST-PERIOD)
        (match (stx-transfer? whitelist-cost tx-sender (as-contract tx-sender))
          success (begin
          (if (is-eq (is-some (index-of RESERVED next-id)) true)
          (begin
            (try! (nft-mint? stackies-nft next-id (var-get artist-address)))
            (try! (nft-mint? stackies-nft (+ next-id u1) new-owner))
            (var-set last-id (+ next-id u1))
          )
          (begin
            (try! (nft-mint? stackies-nft next-id new-owner))
            (var-set last-id next-id)
          )
          )
            (try! (as-contract (stx-transfer? (/ (* whitelist-cost (var-get commission)) u10000) (as-contract tx-sender) CONTRACT-OWNER)))
            (try! (as-contract (stx-transfer? (- whitelist-cost (/ (* whitelist-cost (var-get commission)) u10000)) (as-contract tx-sender) (var-get artist-address))))
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
(define-public (set-commission (value uint))
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
(define-public (set-mint-time (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set target-block value))
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
      (match (nft-transfer? stackies-nft token-id sender recipient)
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
  (ok (nft-get-owner? stackies-nft token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets commission
(define-read-only (get-commission)
  (ok (/ (* (var-get cost-per-mint) (var-get commission)) u10000))
)

;; Gets artist address
(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-target-block)
  (ok (var-get target-block))
)

(define-read-only (get-current-block)
  (ok block-height)
)

(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) ".json")))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001)))) ".json")))
    )
)