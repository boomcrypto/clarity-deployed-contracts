;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant WHITELISTED (list u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153))

(define-public (execute (sender principal))
	(let (
			(whitelisted (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 get-whitelisted-pools))
			(updated-whitelisted (unwrap-panic (as-max-len? (concat whitelisted WHITELISTED) u1000))))
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 whitelist-pools updated-whitelisted))
(print { notification: "whitelist-pools", payload: { contract: "farming-campaign-v2-03", whitelisted: updated-whitelisted }})

		(ok true)))

