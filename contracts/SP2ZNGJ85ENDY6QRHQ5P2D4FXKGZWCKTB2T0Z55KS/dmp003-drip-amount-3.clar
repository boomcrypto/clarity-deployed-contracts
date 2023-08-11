;; Title: DMP003 - Increase Token Faucet Drip Amount
;; Author: rozar.btc
;; Synopsis:
;; This proposal increases the token faucet drip amount to 3 tokens per drip.
;; Description:
;; This proposal increases the drip amount to further decentralize DAO governance.



(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme005-token-faucet-v0 set-drip-amount u3))
        (ok true)
	)
)
