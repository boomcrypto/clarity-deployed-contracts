
;; title: nft-factory
;; version: 0.1
;; summary: A simple NFT minting contract

;; traits
;; trait configured and deployed from ./settings/Devnet.toml
;; (impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait) ;; testnet contract?
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
(define-non-fungible-token NFT-FANS uint)


;; errors
(define-constant ERR_NOT_AUTHORIZED (err u1001))


;; data vars
(define-data-var last-id uint u0)

;; public functions

;; mint a new NFT
(define-public (claim)
  (mint tx-sender))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
     (nft-transfer? NFT-FANS token-id sender recipient)))

;; SIP009: Transfer token to a specified principal with a memo
(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))


;; read only functions

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace NFT-NAME
  (ok (nft-get-owner? NFT-FANS token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://token.stacks.co/{id}.json")))



;; private functions

;; Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      ;; You can replace NFT-FANS with another name if you'd like
      (nft-mint? NFT-FANS next-id new-owner)))
