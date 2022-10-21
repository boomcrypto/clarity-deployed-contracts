;; rfnft
;; contractType: public
(impl-trait 'SP36VJX4FWS2C90AE58S6SNZ76VTXEVT1Y1Z4G03X.nft-trait.nft-trait)

(define-non-fungible-token NFT-RFNFT uint)

(define-data-var last-id uint u0)
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     (nft-transfer? NFT-RFNFT token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? NFT-RFNFT token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://gateway.pinata.cloud/ipfs/QmS7PsFZJwBK9ipN7yNbUKoaSgQfWs1HQtnZ8Mf8ffpAzo")))

(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
	(asserts! (is-eq contract-caller contract-owner) err-owner-only)
      (nft-mint? NFT-RFNFT next-id new-owner)))