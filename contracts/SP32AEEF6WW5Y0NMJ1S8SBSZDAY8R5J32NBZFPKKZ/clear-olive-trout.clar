(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token rickroll uint)

(define-data-var last-token-id uint u0)


(define-read-only (get-last-token-id)
	(if true (ok u10000) (err u0))
)

(define-read-only (get-token-uri (id uint)) 
    (if true (ok (some "ipfs://ipfs/bafkreidsjwp6t5x6rap5utwblutdnp23cdpzlnqrq3ml4wrgoegeihkv2i")) (err u0))
)

(define-read-only (get-owner (token-id uint))
	(if true (ok (nft-get-owner? rickroll token-id)) (err u1))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender sender) (err u0))
		(nft-transfer? rickroll token-id sender recipient)
	)
)

(define-public (mint (recipient principal))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(try! (nft-mint? rickroll token-id recipient))
		(var-set last-token-id token-id)
		(ok token-id)
	)
)

(define-public (burn (id uint))
    (nft-burn? rickroll id tx-sender))

(mint tx-sender)
(burn u1)

