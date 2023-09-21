;; Title: DMP017 - Quest Helper
;; Author: rozar.btc
;; Synopsis:
;; A utility contract to manage and control various aspects of quests including STX quest funding.
;; Description:
;; The Quest Helper is a comprehensive tool that allows users to update quest expiration, activation, maximum completion, and STX rewards. 
;; Notably, it provides a mechanism for managing STX quest funding.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme017-quest-helper true))
        (ok true)
	)
)
