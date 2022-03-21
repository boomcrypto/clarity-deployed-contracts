---
title: "Trait SatoshiBrandSwag"
draft: true
---
```
;; SatoshiBrandSwag

;; (impl-trait .nft-trait.nft-trait)
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token SatoshiBrandSwag uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)

;; Internal variables
(define-data-var mint-limit uint u5000)
(define-data-var last-id uint u0)

;; private functions
;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))
        (count (var-get last-id)))
      (asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
    (begin
      (mint-helper new-owner next-id))
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? SatoshiBrandSwag next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? SatoshiBrandSwag token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? SatoshiBrandSwag token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
    (ok (some "https://arweave.net/PmLjNVFILt-TwgFhXQY5WXcWs22PvwyEcMBLTOq0Nso/stcl_brand_swag_{id}.json")))

```
