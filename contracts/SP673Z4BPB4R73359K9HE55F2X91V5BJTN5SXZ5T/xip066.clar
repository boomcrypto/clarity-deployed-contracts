;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)



(define-public (execute (sender principal))
	(let (
			(xbtc-bal (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance-fixed 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-wrapped)))
			(xusd-bal (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd get-balance-fixed 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-wrapped))))
    (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-wrapped transfer-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc xbtc-bal 'SP156T7YCZG27M1F45S36RAJGTPZPFRHPPNW7V9GW))
    (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-wrapped transfer-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd xusd-bal 'SP156T7YCZG27M1F45S36RAJGTPZPFRHPPNW7V9GW))
(ok true)))
