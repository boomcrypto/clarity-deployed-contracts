;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant REGISTRATION_EXTEND u4320) ;; 30 day

(define-public (execute (sender principal))
	(let (
		(pool-details-2 (try! (contract-call? .alex-launchpad-v2-03f get-launch-or-fail u2)))
		(pool-details-3 (try! (contract-call? .alex-launchpad-v2-03f get-launch-or-fail u3)))
		(updated-heights { 
			registration-end-height: (+ (get registration-end-height pool-details-2) REGISTRATION_EXTEND), 
			claim-end-height: (+ (get claim-end-height pool-details-2) REGISTRATION_EXTEND) })
		(updated-details-2 (merge pool-details-2 updated-heights))
		(updated-details-3 (merge pool-details-3 updated-heights)))
	(try! (contract-call? .alex-launchpad-v2-03f update-pool u2 updated-details-2))
	(try! (contract-call? .alex-launchpad-v2-03f update-pool u3 updated-details-3))
		(ok true)))
