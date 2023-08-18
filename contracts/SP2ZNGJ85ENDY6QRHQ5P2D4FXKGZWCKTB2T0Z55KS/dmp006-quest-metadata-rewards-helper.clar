;; Title: DMP005 - Quest Metadata, Charisma Rewards, and Quest Reward Helper
;; Author: rozar.btc
;; Synopsis:
;; This contract serves as a proposal to add the remaining contracts required for basic on-chain quests.
;; Description:
;; Three contracts are enabled by this proposal:
;; - DME008-Quest-Metadata (adds metadata to quests)
;; - DME009-Charisma-Rewards (adds Charisma token rewards to quests)
;; - DME010-Quest-Reward-Helper (helper contract for claiming quests rewards)

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme008-quest-metadata true))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme009-charisma-rewards true))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme010-quest-reward-helper true))
        (ok true)
	)
)
