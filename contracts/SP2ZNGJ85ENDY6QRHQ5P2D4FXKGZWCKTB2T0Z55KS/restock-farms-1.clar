;; Title: Restock Farms 1
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks
;; Description:
;; Restock the farming rewards

;; Reasoning: 
;; Encourage platform usage and TVL

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.proposal-trait)

(define-constant cha-amount (* u50000 (pow u10 u6)))
(define-constant target-farm 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.abundant-orchard)

(define-public (execute (sender principal))
	(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.fuji-helper-v1 restock cha-amount target-farm)
)
