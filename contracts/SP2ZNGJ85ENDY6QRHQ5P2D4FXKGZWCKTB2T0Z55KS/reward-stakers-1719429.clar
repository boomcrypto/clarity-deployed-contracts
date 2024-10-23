;; Title: Reward Stakers
;; Created By Charisma
;; 
;; Synopsis: Mint Charisma tokens directly to the staking pool, evenly distributing them among all stakers.
;;
;; Reasoning: Why not?

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint u10000 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma))
		(ok true)
	)
)