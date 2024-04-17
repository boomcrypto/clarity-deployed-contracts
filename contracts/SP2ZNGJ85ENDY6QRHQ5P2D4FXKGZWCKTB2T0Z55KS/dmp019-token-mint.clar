;; Title: DMP019 Token Mint
;; Author: rozar.btc
;; Synopsis:
;; Mint tokens for liquidity providers and the core contributers.
;; Description:
;; This proposal is to mint tokens for liquidity providers and the core contributers.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint u1000000 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
        (print "The secret we should never let the gamemasters know is that they don't need any rules.")
        (ok true)
	)
)
