;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u18446744073709551615)
(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(let (
		(alex-1 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance-fixed 'SP1SNT6GK28RWFHDZEQ4510MDC80XH2DANN553KZ4)))
		(alex-2 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance-fixed 'SP2VCNXGRZCBTP8E9MQ6DJPFVXRBPWBN63FE06A1M)))
		(alex-3 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance-fixed 'SP174BBVTRQSE3YAMBKD5NKG03TMDQSY6ZMJT14J6)))
	)
(and (> alex-1 u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex burn-fixed alex-1 'SP1SNT6GK28RWFHDZEQ4510MDC80XH2DANN553KZ4)))
(and (> alex-2 u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex burn-fixed alex-2 'SP2VCNXGRZCBTP8E9MQ6DJPFVXRBPWBN63FE06A1M)))
(and (> alex-3 u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex burn-fixed alex-3 'SP174BBVTRQSE3YAMBKD5NKG03TMDQSY6ZMJT14J6)))
		(ok true)))
