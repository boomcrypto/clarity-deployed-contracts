;; title: template-batch-endorsements

;; traits
;;

;; token definitions
;; 
;; (VAR) based on title of collection
(define-non-fungible-token endorsement uint)
;; constants
;;
;; (VAR) changes based on the number of recipients
(define-constant TOTAL u2)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

;; (VAR) changes based on the collection ipfs hash
(define-constant IPFS-ROOT "ipfs://ipfs/bafybeibwoefbzrljbd7hyq5m7igipgp2qw22ogg5vzwcnjmopelgyxyidy/{id}.json")


;; data vars
;;
(define-data-var last-token-id uint u0)
;; data maps
;;
(define-map awarded-addresses principal bool)
(define-map minters principal bool)

;; public functions
;;
(define-public (mint)
    (let (
        (token-id (+ u1 (var-get last-token-id)))
        (is-allowed (unwrap! (map-get? awarded-addresses tx-sender) (err ERROR-UNAUTHORIZED)))
    ) 
    (asserts! (not (did-address-mint tx-sender)) (err ERROR-ALREADY-MINTED))
    (var-set last-token-id token-id)
    (map-insert minters tx-sender true)
    (nft-mint? endorsement token-id tx-sender)))

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
(define-read-only (did-address-mint (address principal)) 
    (default-to false (map-get? minters tx-sender)))
;; private functions
;;
(define-private (add-allowed-address (address principal)) 
    (map-insert awarded-addresses address true))

;;; mint calls here
(add-allowed-address 'SP3J2T2PW8S3DREPQ175Y1Z6YPX8842645AJATAP6)
(add-allowed-address 'SP21SVWAVAZNZ77XBASTKBVVT38BM3WFN9QRCQ423)
