;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant REGISTRATION_CUTOFF u1748527200)
(define-constant VOTING_CUTOFF u1749132000)
(define-constant STAKE_CUTOFF u1749132000)
(define-constant STAKE_END u1751551200)
(define-constant REWARD_AMOUNT (* u1000000 ONE_8))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 create-campaign REGISTRATION_CUTOFF VOTING_CUTOFF STAKE_CUTOFF STAKE_END REWARD_AMOUNT MAX_UINT))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2KFVYHJPZN5ZD9XSWY4SD23JMQJBWEP6CDPKP5T))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPBNMD07T0WD2WJAH6JZJG07GYSF0X413V69J3T9))
		(ok true)))

