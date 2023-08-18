;; Title: DMP007 - Set Quest Rewards
;; Author: rozar.btc
;; Synopsis:
;; This proposal sets the quest reward to 100 Charisma tokens for the token faucet quest

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme009-charisma-rewards set-rewards u0 u100))
        (ok true)
	)
)
