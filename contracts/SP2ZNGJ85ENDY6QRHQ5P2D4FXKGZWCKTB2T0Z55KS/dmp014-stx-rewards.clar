;; Title: DMP014 - STX Rewards
;; Author: rozar.btc
;; Synopsis:
;; A modular rewards system that disburses STX rewards for quest completions.
;; Description:
;; The rewards are paid out by the contract, which is controlled by the DAO. 
;; The DAO can also set the fee percentage and the fee address.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme014-stx-rewards true))
        (ok true)
	)
)
