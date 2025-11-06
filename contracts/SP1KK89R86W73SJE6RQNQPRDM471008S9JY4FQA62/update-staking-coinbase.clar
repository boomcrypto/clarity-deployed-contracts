;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)

(define-constant rewards u10320000000000)

(define-public (execute (sender principal))
	(begin 
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool set-coinbase-amount 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token rewards rewards rewards rewards (/ rewards u2)))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool set-apower-multiplier-in-fixed 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u0))
(print { 
	coinbase-299: (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-coinbase-amount-or-default u299), 
	coinbase-300: (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-coinbase-amount-or-default u300),
	coinbase-301: (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-coinbase-amount-or-default u301),
	coinbase-401: (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-coinbase-amount-or-default u401),
	apower-multiplier: (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool get-apower-multiplier-in-fixed-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token) })
		(ok true)))
