;; Title: Mint CHA into sCHA pool
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; Description:
;; Mint 100k CHA tokens directly into the sCHA staking pool

;; Reasoning: 
;; Reward early users and begin to increase the rebase valuse of sCHA

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (* u100000 (pow u10 u6)) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma))
		(ok true)
	)
)