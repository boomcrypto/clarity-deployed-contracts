;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)
(define-constant token-y 'SPRYBMPFT75XBFAH6YJ2YKTGC5P2E3KM6Y1F6NYK.ssl-DROID-62c6f)
(define-constant factor ONE_8)
(define-constant pool-owner 'SP11M99GX0YGHMBFCA7W4952AHFQTT9XEX33BFQSZ)
(define-constant amount-x (* u1721 ONE_8))
(define-constant amount-y u361079365404500)
(define-constant fee-rate-x u500000)
(define-constant fee-rate-y u500000)
(define-constant max-out-ratio u60000000)
(define-constant max-in-ratio u60000000)
(define-constant oracle-average u99000000)
(define-constant fee-rebate u50000000)
(define-constant start-block u0)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (let (
			(transfer-droid (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-y amount-y tx-sender)))
			(new-supply (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 create-pool token-x token-y factor pool-owner amount-x amount-y)))
			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor))))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-enabled token-x token-y factor true))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-x token-x token-y factor fee-rate-x))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-y token-x token-y factor fee-rate-y))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-out-ratio token-x token-y factor max-out-ratio))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-in-ratio token-x token-y factor max-in-ratio))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-average token-x token-y factor oracle-average))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rebate token-x token-y factor fee-rebate))		
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-start-block token-x token-y factor start-block))		

		(print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))
    (ok true)))
