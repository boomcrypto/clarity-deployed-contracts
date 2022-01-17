;; wolf-pack-academy
;; <wolf pack academy>
(impl-trait 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6.nft-trait.nft-trait)


;; Non Fungible Token, using sip-009
(define-non-fungible-token wolf-team-collection uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u3)
(define-constant LOOKUPS (list "0" "1" "2" "3" ))

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u1000000)
(define-data-var commission-per-mint uint u0000000)
(define-data-var payout uint u0)
(define-data-var ipfs-full-metadata (string-ascii 500) "https://gateway.pinata.cloud/ipfs/QmaJt4kRCrR6vnNs2aKQs6Dw7sQKndvYjaD1d6ZgghoT5w")
(define-data-var ipfs-root (string-ascii 120) "https://gateway.pinata.cloud/ipfs/QmaJt4kRCrR6vnNs2aKQs6Dw7sQKndvYjaD1d6ZgghoT5w/wolf_team_")
(define-data-var artist-address principal 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6)
(define-data-var minting-enabled bool true)



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
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? wolf-team-collection next-id new-owner))
            (var-set last-id next-id)
            (var-set payout  (var-get cost-per-mint) )
            (try! (as-contract (stx-transfer? (var-get cost-per-mint) (as-contract tx-sender) (var-get artist-address))))
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

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? wolf-team-collection token-id sender recipient)
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
  (ok (nft-get-owner? wolf-team-collection token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (lookup (uid uint))
    (ok (unwrap-panic (element-at LOOKUPS uid)))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (lookup token-id))) "_metadata.json")))

)

(begin
    (try! (mint (var-get artist-address)))
)