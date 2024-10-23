
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-constant request-id u40)
(define-constant adjust-amount u158754695853)

(define-public (execute (sender principal))
	(let (
      (request-details (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-01 get-redeem-request-or-fail request-id)))
      (redeem-cycle (get redeem-cycle request-details))
      (current-redeem-shares-per-cycle (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-01 get-redeem-shares-per-cycle-or-default redeem-cycle))
      (updated-details (merge request-details { amount: (+ (get amount request-details) adjust-amount) })))
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-request request-id updated-details))
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-shares-per-cycle redeem-cycle (+ current-redeem-shares-per-cycle adjust-amount)))
		(print { notification: "update-redeem-request", payload: request-details, request-id:request-id })
		(ok true)))
