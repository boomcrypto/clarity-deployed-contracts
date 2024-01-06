(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; declare a new NFT
(define-non-fungible-token NFT-NR uint)
(define-map asset uint (string-ascii 256))

;; store the last issued token ID
(define-data-var last-id uint u0)
(define-constant contract-owner tx-sender)
;;

;; mint a new NFT
(define-public (claim (receipient principal) (newAsset (string-ascii 256))  )
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403)) 
    (mint receipient newAsset)
  ))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     ;; Make sure to replace NFT-FACTORY
     (nft-transfer? NFT-NR token-id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace NFT-NAME
  (ok (nft-get-owner? NFT-NR token-id)))


;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? asset token-id)))

;; Internal - Mint new NFT
(define-private (mint (new-owner principal) (newAsset (string-ascii 256)) )
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      (map-set asset next-id newAsset)
      (nft-mint? NFT-NR next-id new-owner)))