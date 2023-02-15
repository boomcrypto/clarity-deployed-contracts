
;; title: MAX-FANS
;; version: 0.1
;; summary: A toy NFT project for demonstration purposes

;; traits
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; errors
(define-constant ERR_MAX_SUPPLY u001)
(define-constant ERR_ALREADY_CLAIMED u002)
(define-constant ERR_ONLY_TRANSFER_YOURS u003)

;; token definitions
;; New NFT collection MAX-FANS
(define-non-fungible-token MAX-FANS uint)

;; data vars
;; store the last issued token ID
(define-data-var last-id uint u0)

;; maps
;; store owners of the MAX-FANS
(define-map claimants { user: principal } bool )

;; public functions
;; claim a MAX-FANS
(define-public (claim)
  (begin 
   (map-insert claimants { user : tx-sender } true )
   (mint tx-sender)
   )
)

;; Checks if given principal is an owner of a MAX-FANS
(define-public (check-owner (owner principal))
    (ok (match (map-get? claimants { user: owner}) owner-found true false))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SIP009: Transfer token to a specified principal;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err ERR_ONLY_TRANSFER_YOURS))
     (map-set claimants { user: recipient } false)
     (nft-transfer? MAX-FANS token-id sender recipient)))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; read only functions
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace NFT-NAME
  (ok (nft-get-owner? MAX-FANS token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://maxefremov.com")))

;; private functions
;; Mint new NFT
(define-private (mint (new-owner principal))
    (let (
      (next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      (nft-mint? MAX-FANS next-id new-owner)))
