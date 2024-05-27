;; Title: DMP021 Wooo! Launch
;; Author: rozar.btc
;; Synopsis:
;; Enable a new extention called Wooo! (WOOO) that is backed by staked sWELSH and sROO tokens.

(impl-trait .dao-traits-v0.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; disable fees/rewards on old contract since it's getting replaced
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-mint-fee-percent u0))
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-burn-fee-percent u0))
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-transfer-fee-percent u0))
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-mint-reward-factor u0))
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-burn-reward-factor u0))
		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme020-woooooo-token set-transfer-reward-factor u0))
		;; enable new contract extention
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme021-wooo-token true))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme022-wooo-title-belt-nft true))
		;; update decimals points for the Charisma token from 0 -> 2
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token set-decimals u2))
		(print "Wooo!")
		(ok true)
	)
)
