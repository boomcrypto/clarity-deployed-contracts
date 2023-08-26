(define-public (get-balance-at-block (address principal) (block-hash (buff 32)))
	(at-block block-hash (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-balance address))
)