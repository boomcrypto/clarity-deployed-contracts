;; Title: DMP004 - Quest Completion
;; Author: rozar.btc
;; Synopsis:
;; This contract serves as a proposal to add the quest completion extention.
;; Description:
;; This proposal enables quest completion extention, tracking the completion status of quests for given addresses.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme006-quest-completion true))
        (ok true)
	)
)
