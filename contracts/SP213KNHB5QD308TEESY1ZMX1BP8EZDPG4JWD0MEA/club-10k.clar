;;  This file is part of the Bitfari Community Toolkit.
;;  Give a 10K balance to buy digital land;

;;  Digital land NFTs contain virtual billboards and geofences
;;  that screen operators can monetize. Digital land price depends on land size,
;;  zipcode, type of property, popularity, landmark status and, of course,
;;  market dynamics.

;;  This token is transferable.
;; ------------------------------------------------------------------------------------------------------------------
 
;; SIP090 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP090 interface (mainnet)
(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

;; Define Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant FARI_CLUB_LIMIT u100000)

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_OVER_LIMIT (err u402))

;; Store the variables
(define-data-var last-id uint u0)

;; Register a new token holder - 10K Club
(define-non-fungible-token club-10k uint)

;; SIP009: Transfer the token to a specified principal
 (define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (if
    (and 
      (is-eq (some tx-sender) (nft-get-owner? club-10k token-id))
      (is-eq owner tx-sender)
    )
    (nft-transfer? club-10k token-id owner recipient)
    (err u500)
  )
)

;; SIP009: Get the owner of the specified token ID
 (define-read-only (get-owner (token-id uint))
   (ok (nft-get-owner? club-10k token-id)))
 
;; SIP009: Get the last token ID
 (define-read-only (get-last-token-id)
   (ok (var-get last-id)))

;; SIP009: Get the token URI
 (define-read-only (get-token-uri (token-id uint))
    (ok (some "https://bitfari.org/club-10k")))
    
;; Private functions
(define-private (is-owner (token-id uint) (user principal))
   (is-eq user (unwrap! (nft-get-owner? club-10k token-id) false))
)

;; Public functions
(define-public (burn (token-id uint))
   (if (is-owner token-id tx-sender)
     (match (nft-burn? club-10k token-id tx-sender)
       success (ok true)
       error (err error)
     )
       ERR_NOT_AUTHORIZED
   )
 )

;; Mint a New club-10k NFT
 (define-public (mint (new-owner principal)) 
    (let ((next-id (+ u1 (var-get last-id))))
    ;; parameter sanitization, unilateral minting
    (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    ;; limit membership 
    (asserts! (< (var-get last-id) FARI_CLUB_LIMIT) ERR_OVER_LIMIT)

    (match (nft-mint? club-10k next-id new-owner)
       success
       (begin
        (var-set last-id next-id)       
        (ok true))
       error (err error))))