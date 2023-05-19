(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.nft-trait.nft-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-non-fungible-token stackseoz uint)

(define-data-var last-token-id uint u0)

(define-read-only (get-last-token-id)
	(ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint)) 
    (ok (some "ipfs://ipfs/bafkreidtnwuidmoqgasinb3cowk5fuinamrqysu3qurforuy2wkz7wdyku"))
)


(define-read-only (get-owner (token-id uint))
	(ok (nft-get-owner? stackseoz token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(nft-transfer? stackseoz token-id sender recipient)
	)
)

(define-public (mint (recipient principal))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(try! (nft-mint? stackseoz token-id recipient))
		(var-set last-token-id token-id)
		(ok token-id)
	)
)
(define-public (burn (id uint))
    (nft-burn? stackseoz id tx-sender))

(mint tx-sender)