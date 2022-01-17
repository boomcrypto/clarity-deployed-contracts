(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stacks-dragons uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u680)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u2000000) ;;initial. Will be changed to 36 stx after launch of contract
(define-data-var commission-per-mint uint u1000000) ;;iniital. Will be changed to 2.88 stx after launch of contract
(define-data-var payout uint u0)
(define-data-var ipfs-full-metadata (string-ascii 115) "ipfs://ipfs/bafybeihj2wnmkwzcrwxcsa4ri5gzqtlvtzcobltkqz2poutuzifjdlbfky/stacks_dragons/stacks_dragons_metadata.json")
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/bafybeict6t5iasgbvmk7hovx6cyzoxlluzr42gnxdfhq54rtvtajnnvmki/stacks_dragons/stacks_dragons_")
(define-data-var artist-address principal 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1)

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
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? stacks-dragons next-id new-owner))
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

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? stacks-dragons token-id sender recipient)
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
  (ok (nft-get-owner? stacks-dragons token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) "_metadata.json")))
)

(begin
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (try! (mint 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1))
  (ok true)
)