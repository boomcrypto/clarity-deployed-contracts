;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant WHITELISTED (list u125 u126 u127))

(define-public (execute (sender principal))
	(let (
			(whitelisted (contract-call? .farming-campaign-v2-02 get-whitelisted-pools)))
(try! (contract-call? .farming-campaign-v2-02 whitelist-pools (unwrap-panic (as-max-len? (concat whitelisted WHITELISTED) u1000))))

		(ok true)))

