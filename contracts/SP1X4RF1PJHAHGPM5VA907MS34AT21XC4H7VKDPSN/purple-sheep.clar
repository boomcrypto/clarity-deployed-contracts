

(define-non-fungible-token purple-sheep uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))   
(define-constant err-not-token-owner (err u101))
(define-constant err-not-token (err u103))

(define-data-var last-token-id uint u0)
(define-data-var token-uri (string-ascii 256) "ipfs://ipfs/QmYjCAdtgUWBhTCym5GHRgiKUpFshZp7ueppPJDZbACQnW/")


(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-id (token-id uint))
    (ok none)
)



(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts!  (is-eq tx-sender contract-owner) (err err-owner-only))
        ;;(asserts! (not (var-get metadata-frozon)) (err err-metadata-frozen))
        (var-set token-uri new-base-uri)
        (ok true)
    )
)

(define-read-only (get-token-uri (token-id uint)) 
    (begin  
        (asserts! (not (is-eq token-id u0)) err-not-token)
        (ok (some (var-get token-uri)))
    )
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? purple-sheep token-id))   
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq sender tx-sender) err-not-token-owner)
        (nft-transfer? purple-sheep token-id sender recipient)
    )
)  

(define-public (mint (recipient principal))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(try! (nft-mint? purple-sheep token-id recipient))
		(var-set last-token-id token-id)
		(ok token-id)
	)
)

(define-public (buy (token-id uint) (reciver principal) ) 
    (begin  
         (asserts! (is-eq tx-sender contract-owner) err-not-token-owner)
         (nft-transfer? purple-sheep token-id tx-sender reciver)
    )
)