;; Title: DMP016 - Quest Ownership
;; Author: rozar.btc
;; Synopsis: 
;; A smart contract for tracking the ownership of quests and quest-rewards deposited.
;; Description:
;; This proposal defines state giving quests an owner principal which can be used to update the quest.
;; It also includes a map for quest-rewards deposited that only the DAO can modify.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme016-quest-ownership true))
        (ok true)
	)
)
