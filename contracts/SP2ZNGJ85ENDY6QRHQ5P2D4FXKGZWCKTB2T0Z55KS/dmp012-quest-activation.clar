;; Title: DMP012 - Quest Activation
;; Author: rozar.btc
;; Synopsis:
;; This contract serves as a proposal to add the quest activation extention.
;; Description:
;; This proposal enables quest activation extention, giving quests an start block in which they can not be completed before.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme012-quest-activation true))
        (ok true)
	)
)
