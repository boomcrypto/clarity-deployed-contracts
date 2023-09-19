;; Title: DMP015 - Quest Reward Helper
;; Author: rozar.btc
;; Synopsis:
;; Upgrades the quest reward helper to the latest version.
;; Description:
;; The Quest Reward Helper is an intuitive bridge that aids users in seamlessly claiming their rewards upon quest completion.
;; This latest iteration adds support for quest activation and deactivation, as well as STX quest reward payouts.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme015-quest-reward-helper true))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme010-quest-reward-helper false))
        (ok true)
	)
)
