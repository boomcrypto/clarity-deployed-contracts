;;  This file is part of the Bitfari Community Toolkit.
;;  Creates a VIP NFT for Stratospheric Leaders
;;  VIP Community with free access to events, the intranet, courses
;;  tools, and VIP forums

;;  Sale prize of the token increases regularly after new content is added
;;  to the platform 

;;  This token is transferable.
;; ------------------------------------------------------------------------------------------------------------------
 
;; SIP090 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP090 interface (mainnet)
(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

;; Define Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant FARI_VIP_LIMIT u1000)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_OVER_LIMIT (err u402))

;; Store the variables
(define-data-var last-id uint u0)

;; Register a new token holder - 100K Club
(define-non-fungible-token vip uint)

;; SIP009: Transfer the token to a specified principal
 (define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (if
    (and 
      (is-eq (some tx-sender) (nft-get-owner? vip token-id))
      (is-eq owner tx-sender)
    )
    (nft-transfer? vip token-id owner recipient)
    (err u500)
  )
)

;; SIP009: Get the owner of the specified token ID
 (define-read-only (get-owner (token-id uint))
   (ok (nft-get-owner? vip token-id)))
 
;; SIP009: Get the last token ID
 (define-read-only (get-last-token-id)
   (ok (var-get last-id)))

;; SIP009: Get the token URI
 (define-read-only (get-token-uri (token-id uint))
    (ok (some "https://bitfari.org/nfts/vip")))
    
;; Private functions
(define-private (is-owner (token-id uint) (user principal))
   (is-eq user (unwrap! (nft-get-owner? vip token-id) false))
)

;; Public functions
(define-public (burn (token-id uint))
   (if (is-owner token-id tx-sender)
     (match (nft-burn? vip token-id tx-sender)
       success (ok true)
       error (err error)
     )
       ERR_NOT_AUTHORIZED
   )
 )

;; Mint a New Stratospheric Leader VIP NFT
 (define-public (mint (new-owner principal)) 
    (let ((next-id (+ u1 (var-get last-id))))
    ;; parameter sanitization, unilateral minting
    (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    ;; limit membership 
    (asserts! (< (var-get last-id) FARI_VIP_LIMIT) ERR_OVER_LIMIT)

    (match (nft-mint? vip next-id new-owner)
       success
       (begin
        (var-set last-id next-id)       
        (ok true))
       error (err error))))