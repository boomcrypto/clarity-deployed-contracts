
;; contract-nft
(impl-trait 'SP39HFKW38EPPPRQ1R52GK02WCN8314DQAQHF6EZ6.nft-trait.nft-trait)


(define-non-fungible-token Bitcoin-Kitties uint)


;; Storage
(define-map tokens-count
  principal
  uint)


;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u999)


;; Internal variables
(define-data-var last-id uint u0)
(define-data-var cost-per-mint uint u20000000)
(define-data-var ipfs-full-metadata (string-ascii 54) "ipfs://QmTHuRPYQC9yWa6tAhD3MB1PTQjSKkdo7t7FX9QwBbtxBh")
(define-data-var ipfs-root (string-ascii 70) "ipfs://QmWuNNvvi3deQYcNhhBsG2HsLYSWrHuSnvThDJyqu3dezh/bitcoin_kitties_")
(define-data-var artist-address principal 'SP7NZ93FMPEWJCD1XYNEC51RSPCVE28GZABRYBZP)

(define-data-var minting-enabled bool true)


(define-public (claim)
  (mint tx-sender))


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

  (define-public (claim-tf)
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



(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? Bitcoin-Kitties  next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? (var-get cost-per-mint) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)              
        )
    )
)


;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
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
      (match (nft-transfer? Bitcoin-Kitties token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))


;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Bitcoin-Kitties token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

  ;; Gets artist address
(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

  (define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .lookups lookup token-id))) "_metadata.json")))
)




(begin
    (try! (mint (var-get artist-address)))
)