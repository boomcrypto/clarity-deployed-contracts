;; Title: DMP020 Liquid Staked Welshcorgicoin
;; Author: rozar.btc
;; Synopsis:
;; Create a new token called Liquid Staked Welshcorgicoin (lsWELSH) that is backed by staked WELSH tokens.
;; Description:
;; This proposal creates a new token called Liquid Staked Welshcorgicoin (lsWELSH) that is backed by staked WELSH tokens. 
;; The lsWELSH token is minted by the Dungeon Master DAO and liquid staking utility extentions,
;; and staked in the WELSH staking contract to earn staking rewards.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP1VGCMHKXYGZ4Y0DWZR6449M0EJY3PZV2XX61EMH.dme020-liquid-staked-welsh true))
        (print "Aim to crit, even if you might miss.")
        (ok true)
	)
)