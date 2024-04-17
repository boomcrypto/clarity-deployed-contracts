;; title: template-batch-endorsements

;; traits
;;
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
;; 
;; (VAR) based on title of collection
(define-non-fungible-token endorsement uint)
;; constants
;;
;; (VAR) changes based on the number of recipients
(define-constant TOTAL u1)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

;; (VAR) changes based on the collection ipfs hash
(define-constant IPFS-ROOT "ipfs://ipfs/bafybeie2fcmgexfauny3u5ttckhrcm5hjv7mscdlhkseyhhcsincmi5jzi/{id}.json")


;; data vars
;;
(define-data-var last-token-id uint u0)
;; data maps
;;


;; public functions
;;
(define-private (mint (address principal))
    (let (
        (token-id (+ u1 (var-get last-token-id)))
    ) 
    (var-set last-token-id token-id)
    (nft-mint? endorsement token-id address)))

;; Non transferrable
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (err ERROR-NOT-IMPLEMENTED))

(define-public (burn (id uint)) 
    (let (
        (owner (unwrap! (nft-get-owner? endorsement id) (err ERROR-UNAUTHORIZED)))
    ) 
    (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
    (nft-burn? endorsement id owner)))
;; read only functions
;;

;; this would be constant to mark collection as preminted
(define-read-only (get-last-token-id) 
    (ok TOTAL))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? endorsement id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT)))

;;; mint calls here
(mint 'ST32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32N9D9WJ83)
