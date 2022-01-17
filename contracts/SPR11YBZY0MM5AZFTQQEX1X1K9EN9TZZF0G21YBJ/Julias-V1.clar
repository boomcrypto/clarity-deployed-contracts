;; use the SIP090 interface
;;(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define a new NFT
(define-non-fungible-token JuliasV2 uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u10)

;; Internal variables
(define-data-var last-id uint u0)

;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))
  
 ;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))
        (count (var-get last-id))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (nft-mint? JuliasV2 next-id new-owner)
          success (begin
            (try! (nft-mint? JuliasV2 next-id new-owner))
            (var-set last-id next-id)
            (ok next-id)
          )
          error (err error)
          )
          )
        )

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? JuliasV2 token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace MY-OWN-NFT
  (ok (nft-get-owner? JuliasV2 token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://wieinvestieren.com/wp-content/uploads/2021/07/wieinvestieren_img_11.jpg")))