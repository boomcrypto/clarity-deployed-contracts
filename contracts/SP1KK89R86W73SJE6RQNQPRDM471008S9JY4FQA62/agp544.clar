;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)


(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-data-var snapshot-block uint u1509640)
(define-data-var btc-rate uint u10273463917525) ;; 102,734.64 
(define-data-var stx-rate uint u67721865) ;; 0.67721865
(define-data-var usd-rate uint u100000000) ;; 1.00
(define-data-var btc-pct uint u25000000) ;; 25%
(define-data-var stx-pct uint u100000000) ;; 100%
(define-data-var usd-pct uint u9000000) ;; 9%

;; Main execute function with chunked processing
(define-public (execute (sender principal))
	(let (
			(dual-bal-900 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wkiki get-balance-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming))))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed u305149511700 tx-sender 'SP3417QH761047SYGZ2T26BMZNJ2XEEZT4B4CCX1S none))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed u372289393500 tx-sender 'SP2DK6S5P9GEQVASGYXC98Y85FQ49J2ZGS74HH6WK none))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming, enabled: true })))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed u900 ONE_8 tx-sender))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-activation-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900 u46601))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-coinbase-amount 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900 u100000000 u100000000 u100000000 u100000000 u100000000))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wkiki dual-bal-900 u294 u295)) ;; current cycle + 1
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming stake-tokens 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900 ONE_8 u1))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-reward-cycle-length u1))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming claim-staking-reward 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 u900 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wkiki u294))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-reward-cycle-length u525))
	(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed u900 ONE_8 tx-sender))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming, enabled: false })))	
    (ok true)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
