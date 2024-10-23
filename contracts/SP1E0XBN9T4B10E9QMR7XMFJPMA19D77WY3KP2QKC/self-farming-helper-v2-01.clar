(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-not-authorised (err u1000))
(define-constant err-token-not-approved (err u1001))
(define-constant err-total-cycles (err u1002))
(define-constant err-rewards-per-cycle (err u1003))

;; read-only calls

(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorised)))

;; public calls

(define-public (request (token-x principal) (token-y principal) (factor uint) (rewards-token-trait <ft-trait>) (total-rewards-in-fixed uint) (total-cycles uint))
    (let (
   			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))
				(current-cycle (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-reward-cycle block-height)))
				(rewards-per-cycle (/ total-rewards-in-fixed total-cycles)))
			(asserts! (or (is-eq tx-sender (get pool-owner pool-details)) (is-ok (is-dao-or-extension))) err-not-authorised)
			(asserts! (< u0 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 get-reserve (contract-of rewards-token-trait))) err-token-not-approved)
			(asserts! (< u0 total-cycles) err-total-cycles)
			(asserts! (< u0 rewards-per-cycle) err-rewards-per-cycle)
			
			(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details))))
			(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-activation-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details) u46601)))
			(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-apower-multiplier-in-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details) u0)))
			(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-coinbase-amount 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details) u100000000 u100000000 u100000000 u100000000 u100000000)))
			(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details) (contract-of rewards-token-trait) rewards-per-cycle (+ current-cycle u1) (+ current-cycle total-cycles))))

			(try! (contract-call? rewards-token-trait transfer-fixed total-rewards-in-fixed tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming none))

			(print { notification: "request", payload: { start-cycle: (+ current-cycle u1), end-cycle: (+ current-cycle total-cycles), rewards-per-cycle: rewards-per-cycle } })
			(ok true)))

;; priviliged calls

;; governance calls

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-farming-helper-v2-01, enabled: true } )))
		(ok true)))

;; private calls
