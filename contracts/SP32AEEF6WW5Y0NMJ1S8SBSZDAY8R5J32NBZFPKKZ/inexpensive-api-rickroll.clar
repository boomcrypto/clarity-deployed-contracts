(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-read-only (get-last-token-id)
	(ok u10000)
)

(define-read-only (get-token-uri (id uint)) 
    (ok (some "ipfs://ipfs/bafkreidsjwp6t5x6rap5utwblutdnp23cdpzlnqrq3ml4wrgoegeihkv2i" ))
)


(define-read-only (get-owner (token-id uint))
	(ok none)
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(err u0)
)
