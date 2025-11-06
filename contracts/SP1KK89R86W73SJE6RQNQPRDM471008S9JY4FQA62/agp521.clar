;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
	{ extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01, enabled: false } 
	{ extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming, enabled: false } 
	{ extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01, enabled: false }
	{ extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-02, enabled: false }
	{ extension: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03, enabled: false })))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 pause true))
		(ok true)))

