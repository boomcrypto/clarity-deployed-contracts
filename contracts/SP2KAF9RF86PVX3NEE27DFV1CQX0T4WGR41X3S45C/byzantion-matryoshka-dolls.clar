(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token matryoshka-dolls uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u222)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u30000000)
(define-data-var artist-address principal 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1)

(define-public (claim)
  (mint tx-sender))

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
            (try! (nft-mint? matryoshka-dolls next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? u27600000 (as-contract tx-sender) (var-get artist-address))))
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

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? matryoshka-dolls token-id sender recipient)
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
  (ok (nft-get-owner? matryoshka-dolls token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some "https://cloudflare-ipfs.com/ipfs/bafybeibshj6oyxrb7zhyi2uypvebvqu2q4irc4n554vdubxmzsej7b24ge/matryoshka_dolls/matryoshka_dolls_metadata.json"))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat "https://cloudflare-ipfs.com/ipfs/bafybeibmw2cv5ydybhj5jxggvgev53wnytyjnntz73prtb7lrjjyn577de/matryoshka_dolls/matryoshka_dolls_" (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion lookup token-id))) "_metadata.json")))
)