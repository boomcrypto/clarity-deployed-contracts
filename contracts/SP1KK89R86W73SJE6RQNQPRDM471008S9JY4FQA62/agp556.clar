;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (let (
			(campaign-details (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 get-campaign-or-fail u4))))
		(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 update-campaign u4 (merge campaign-details { reward-amount: u0, stake-end: MAX_UINT })))
		(print (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 get-campaign-or-fail u4)))
    (ok true)))
