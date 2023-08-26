(define-constant err-generic (err u500))

(define-read-only (get-balance-at-block (address principal) (block uint))
 (let
	(
		(block-hash (unwrap! (get-block-info? id-header-hash block) err-generic))
	)
	(ok (at-block block-hash (unwrap! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-balance address) err-generic)))
 )
)