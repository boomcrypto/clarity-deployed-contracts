;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)
(define-constant token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstxoshi)
(define-constant factor ONE_8)
(define-constant pool-owner 'SP11M99GX0YGHMBFCA7W4952AHFQTT9XEX33BFQSZ)
(define-constant lp 'SP1WST899N8B2VR76DCHQ56ZQ78R9VSYT2B2RNTJY)
(define-constant amount-x (* u1800 ONE_8))
(define-constant amount-y u13113752469386100)
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

		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed (get pool-id pool-details) (get supply new-supply) tx-sender lp))

		(print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))

		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3BE2G4V0Y0SRQ71W1QKX677ZES83HFE0XGPY4WZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1P4JM3KYHYPV7G8VYT2QDPXW2X8FHRAY62CP0SE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2K1XATFRWWBECH1RBJJ34FFZ1C2CZW301GB2KPR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1MTS5CGTPQWYVSAWWY6GXTAC2MA93FATVMVPZAP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2TWDJZK2C257R9Y761K890B6A7DR25XPRQ2W4F6))
    (ok true)))
