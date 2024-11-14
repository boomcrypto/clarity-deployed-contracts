;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-invalid-token (err u1022))
(define-constant err-address-len (err u1024))
(define-constant err-principal-construct (err u1025))
(define-constant err-invalid-routing (err u1026))
(define-constant err-slippage (err u1027))
(define-constant err-token-mismatch (err u1028))

(define-map approved-wrapped principal principal) ;; token => base

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (destruct-principal (address principal))
	(contract-call? .bridge-common-v2-02 destruct-principal address))

(define-read-only (construct-principal (hash-bytes (buff 20)))
	(contract-call? .bridge-common-v2-02 construct-principal hash-bytes))

(define-read-only (get-approved-wrapped-or-fail (token principal))
	(ok (unwrap! (map-get? approved-wrapped token) err-invalid-token)))

(define-read-only (validate-route (amount uint) (routing-tokens (list 5 principal)) (routing-factors (list 4 uint)) (token-out principal) (min-amount-out (optional uint)) (recipient { address: (buff 128), chain-id: (optional uint) }))
	(let (
			(routing-len-check (asserts! (is-eq (len routing-tokens) (+ (len routing-factors) u1)) err-invalid-routing))
			(route-details (if (is-eq (len routing-tokens) u1) { token: (unwrap-panic (element-at? routing-tokens u0)), amount: amount }
				(if (is-eq (len routing-tokens) u2)
					{	token: (unwrap-panic (element-at? routing-tokens u1)),
						amount: (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-factors u0)) amount)) }
					(if (is-eq (len routing-tokens) u3)
						{	token: (unwrap-panic (element-at? routing-tokens u2)),
							amount: (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) amount)) }
						(if (is-eq (len routing-tokens) u4)
							{	token: (unwrap-panic (element-at? routing-tokens u3)),
								amount: (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-tokens u3)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) (unwrap-panic (element-at? routing-factors u2)) amount)) }
							{	token: (unwrap-panic (element-at? routing-tokens u4)),
								amount: (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-tokens u3)) (unwrap-panic (element-at? routing-tokens u4)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) (unwrap-panic (element-at? routing-factors u2)) (unwrap-panic (element-at? routing-factors u3)) amount)) }))))))
		(asserts! (>= (get amount route-details) (default-to u0 min-amount-out)) err-slippage)
		(asserts! (or (is-eq token-out (get token route-details)) (is-eq (try! (get-approved-wrapped-or-fail token-out)) (get token route-details))) err-token-mismatch)
		(match (get chain-id recipient)
			some-value
			(if (> some-value u1000)
				(begin (try! (contract-call? .meta-peg-out-endpoint-v2-03 validate-peg-out (get amount route-details) { token: token-out, chain-id: some-value })) (ok true))
				(if (is-eq some-value u0)
					(begin (asserts! (is-eq token-out 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) err-invalid-token)
						(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 validate-peg-out-0 (get amount route-details)))  (ok true))
					(begin (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-out-endpoint-v2-01 validate-transfer-to-unwrap tx-sender token-out (get amount route-details) some-value)) (ok true))))
			(begin (unwrap! (construct-principal (unwrap! (as-max-len? (get address recipient) u20) err-principal-construct)) err-principal-construct) (ok true)))))	

;; public calls

;; @dev failure and fallback should be handled by the consumer
(define-public (route (amount uint) (routing-tokens (list 5 <ft-trait>)) (routing-factors (list 4 uint)) (token-out-trait <ft-trait>) (min-amount-out (optional uint)) (recipient { address: (buff 128), chain-id: (optional uint) }))
	(let (
			(validated (try! (validate-route amount (map trait-to-principal routing-tokens) routing-factors (contract-of token-out-trait) min-amount-out recipient)))
			(amount-out (if (is-eq (len routing-tokens) u1) amount
				(if (is-eq (len routing-tokens) u2) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-factors u0)) amount min-amount-out))
					(if (is-eq (len routing-tokens) u3) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) amount min-amount-out))
						(if (is-eq (len routing-tokens) u4) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-tokens u3)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) (unwrap-panic (element-at? routing-factors u2)) amount min-amount-out))
							(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c (unwrap-panic (element-at? routing-tokens u0)) (unwrap-panic (element-at? routing-tokens u1)) (unwrap-panic (element-at? routing-tokens u2)) (unwrap-panic (element-at? routing-tokens u3)) (unwrap-panic (element-at? routing-tokens u4)) (unwrap-panic (element-at? routing-factors u0)) (unwrap-panic (element-at? routing-factors u1)) (unwrap-panic (element-at? routing-factors u2)) (unwrap-panic (element-at? routing-factors u3)) amount min-amount-out))))))))
		(match (get chain-id recipient) some-value
			(if (> some-value u1000)
				(try! (contract-call? .meta-peg-out-endpoint-v2-03 request-peg-out amount-out (get address recipient) token-out-trait some-value))
				(if (is-eq some-value u0)
					(begin (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 (get address recipient) amount-out)) true)
					(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-out-endpoint-v2-01 transfer-to-unwrap token-out-trait amount-out some-value (get address recipient)))))		
			(try! (contract-call? token-out-trait transfer-fixed amount tx-sender (unwrap! (construct-principal (unwrap! (as-max-len? (get address recipient) u20) err-principal-construct)) err-principal-construct) none)))
		(ok true)))

;; governance calls

(define-public (add-wrapped (token principal) (base principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-wrapped token base))))

(define-public (remove-wrapped (token principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-delete approved-wrapped token))))

;; private calls

(define-private (trait-to-principal (token-trait <ft-trait>))
	(contract-of token-trait))	