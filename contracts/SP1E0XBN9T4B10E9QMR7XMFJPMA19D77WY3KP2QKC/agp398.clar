;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant whitelisted (list u7 u10 u11 u12 u16 u17 u18 u22 u23 u24 u25 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u41 u42 u43 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u105))

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v1-01 whitelist-pools whitelisted))
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v1-01 create-campaign 
	u1733097600 ;; registration cutoff
	u1733702400 ;; voting cutoff
	u1733702401 ;; stake cutoff
	u1736121600 ;; stake end
	(* u1000000 ONE_8) ;; reward amount
	u228247 ;; snapshot block
))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 create-pool 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao u1091 ONE_8))		
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-enabled 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 true))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u500000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u500000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-in-ratio 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u60000000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-out-ratio 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u60000000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-average 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u99000000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rebate 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u90000000))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt ONE_8 u0))

		(ok true)))

