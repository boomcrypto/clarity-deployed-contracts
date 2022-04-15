(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; new to clarity. 
;; If you have time, please try and run claim 
;; stx-transfer refuses to pass post conditions for an unknown reason
;; twitter : @tsbernard_ 

(define-non-fungible-token MY-OWN-NFT uint)

(define-constant ERR-NOT-WHITELISTED u401)
(define-constant ERR-MINT-FAILED u100)
(define-constant ERR_STX_TRANSFER u101)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var last-id uint u0)
(define-data-var price uint u50)
(define-data-var walt3r-address principal 'SP3B08K0WR6H3SYW6HPERXV4TRMGJDWWBMNR51JXN)
(define-constant whitelist (list 
  'ST266T94CKFP9E6PV3N2JZDYTZPBYF9Q7Z1D0BDBS 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW))

;; private functions
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      ;; Make sure to replace MY-OWN-NFT
      (nft-mint? MY-OWN-NFT next-id new-owner)
      ))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://token.stacks.co/{id}.json")))

(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace MY-OWN-NFT
  (ok (nft-get-owner? MY-OWN-NFT token-id)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     ;; Make sure to replace MY-OWN-NFT
     (nft-transfer? MY-OWN-NFT token-id sender recipient)))

;; public functions
(define-public (claim)
    (let ((trx-sender tx-sender) (trx-recipient (var-get walt3r-address)) (cur-price (var-get price))) 
        (asserts! (not (is-none (index-of whitelist trx-sender) )) (err ERR-NOT-WHITELISTED))
        (try! (stx-transfer? cur-price trx-sender trx-recipient) )
        (try! (mint tx-sender) )
        (ok true))
  )
