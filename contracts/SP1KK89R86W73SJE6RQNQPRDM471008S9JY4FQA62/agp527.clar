;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex burn-fixed (+ u10994322319381 u416970251910) 'SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E))
		(ok true)))

