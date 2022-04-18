(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token TRX-PROTO uint)

(define-constant ERR-USER-NOT-WHITELISTED u401)
(define-constant ERR-NFT-NOT-WHITELISTED u402)
(define-constant ERR-NOT-AUTHORIZED u403)
(define-constant ERR-OUT-OF-STOCK u404)
(define-constant ERR-UNCLAIMED-NFT u405)
(define-constant ERR-DUPLICATE-CLAIM u406)
(define-constant ERR-MINT-FAILED u100)
(define-constant ERR_STX_TRANSFER u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ADMIN-ADDRESS 'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW)
(define-constant WALT3R-ADDRESS 'SP3B08K0WR6H3SYW6HPERXV4TRMGJDWWBMNR51JXN)
(define-map nft-whitelist (string-ascii 10) bool)
(define-map user-whitelist principal bool)

(define-data-var last-id uint u0)

;; private functions
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      (nft-mint? TRX-PROTO next-id new-owner)
      ))

;; read only functions
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://token.stacks.co/{id}.json")))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? TRX-PROTO token-id)))

;; public functions

(define-public (user-purchase-whitelist (price uint))
     (stx-transfer? price tx-sender WALT3R-ADDRESS))

(define-public (bernard-claim-whitelist (nft-id (string-ascii 10)) (user-address principal))
  (begin
    (asserts! (is-eq tx-sender ADMIN-ADDRESS) (err ERR-NOT-AUTHORIZED))
    (map-set nft-whitelist nft-id true)
    (asserts! (is-eq (map-insert user-whitelist user-address true) true) (err ERR-DUPLICATE-CLAIM))
    
    (ok true)))

(define-public (user-claim-nft (nft-id (string-ascii 10)) (nft-stock uint))
    (begin 
        (unwrap! (map-get? nft-whitelist nft-id) (err ERR-NFT-NOT-WHITELISTED))
        (unwrap! (map-get? user-whitelist tx-sender) (err ERR-USER-NOT-WHITELISTED))

        (map-delete user-whitelist tx-sender)
        (asserts! (not (is-eq nft-stock u0)) (err ERR-OUT-OF-STOCK))

        (mint tx-sender) 
    ))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     (nft-transfer? TRX-PROTO token-id sender recipient)))
