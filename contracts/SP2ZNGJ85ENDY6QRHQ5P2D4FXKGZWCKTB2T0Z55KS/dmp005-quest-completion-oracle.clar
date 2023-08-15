;; Title: DMP005 - Quest Completion Oracle
;; Author: rozar.btc
;; Synopsis:
;; This contract serves as a proposal to add a quest completion oracle extention.
;; Description:
;; This proposal adds an extention contract to validate user quest completions. 
;; Using a designated Stacks address- the contract authorizes a centralized oracle to validate or alter quest statuses. 
;; This approach provides a balance between decentralized blockchain capabilities and a trusted validation system.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme007-quest-completion-oracle true))
        (ok true)
	)
)
