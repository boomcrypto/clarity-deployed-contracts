;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (let (
			(abtc-bal (unwrap-panic (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc get-balance-fixed .alex-launchpad-v2-03f))))
		(try! (contract-call? .alex-launchpad-v2-03f transfer-all-to-dao 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed abtc-bal tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none))
    (ok true)))
