;; Title: DMP008 - Set Oracle Address
;; Author: rozar.btc
;; Synopsis:
;; This proposal sets the oracle address for the DME007 Quest Completion Oracle.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme007-quest-completion-oracle set-oracle 'SP2MR4YP9C7P93EJZC4W1JT8HKAX8Q4HR9Q6X3S88))
        (ok true)
	)
)
