;; Title: Token Metadata Update
;; Author: rozar.btc

;; broadcast the fungible token metadata update
(define-public (update-ft-metadata (address principal))
	(begin
		(print {
			notification: "token-metadata-update",
			payload: {
				token-class: "ft",
				contract-id: address
			}
		})
		(ok true)
	)
)

;; broadcast the non-fungible token metadata update
(define-public (update-nft-metadata (address principal))
	(begin
		(print {
			notification: "token-metadata-update",
			payload: {
				token-class: "nft",
				contract-id: address
			}
		})
		(ok true)
	)
)