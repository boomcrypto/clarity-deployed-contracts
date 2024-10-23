(impl-trait .proposal-trait.proposal-trait)
(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .cross-bridge-registry-v2-01 remove-validator 'SP16CQM9F91AN8MA3RRDAE0ECYZQ25GTV59KRKJQT))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP38GY2WQ67GMR41WB0S1XGN7H6SXSG54HH4424GD { chain-id: u11, pubkey: 0x03d181a642ffd785942e025b592ac6293b6446d3e8ab20f5ab99f1524a00b31081}))
(ok true)))