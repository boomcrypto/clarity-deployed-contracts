(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token MY-OWN-NFT uint)

(define-constant ERR-NOT-WHITELISTED u401)
(define-constant ERR-MINT-FAILED u100)
(define-constant ERR_STX_TRANSFER u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant PRICE u100)
(define-constant WALT3R-ADDRESS 'SP3B08K0WR6H3SYW6HPERXV4TRMGJDWWBMNR51JXN)
(define-constant WHITELIST (list 
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
    'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW))

(define-data-var last-id uint u0)

;; private functions
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      ;; Make sure to replace MY-OWN-NFT
      (nft-mint? MY-OWN-NFT next-id new-owner)
      ))

;; read only functions
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://token.stacks.co/{id}.json")))

(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace MY-OWN-NFT
  (ok (nft-get-owner? MY-OWN-NFT token-id)))

;; public functions
(define-public (claim)
    (begin 
        (asserts! (not (is-none (index-of WHITELIST tx-sender) )) (err ERR-NOT-WHITELISTED))
        (unwrap! (stx-transfer? PRICE tx-sender WALT3R-ADDRESS) (err ERR_STX_TRANSFER))
        (mint tx-sender) 
    )
  )

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     ;; Make sure to replace MY-OWN-NFT
     (nft-transfer? MY-OWN-NFT token-id sender recipient)))
