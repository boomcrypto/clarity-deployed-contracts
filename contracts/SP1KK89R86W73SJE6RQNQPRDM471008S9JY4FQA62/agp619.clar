;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; Pool configuration for abtc-wsbtc
(define-constant pool-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
(define-constant pool-token-y 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
(define-constant pool-factor u5000000) ;; 0.05 * 1e8
(define-constant pool-owner 'SP11M99GX0YGHMBFCA7W4952AHFQTT9XEX33BFQSZ)
(define-constant pool-amount-x u1000)
(define-constant pool-amount-y u1000)
;; (define-constant pool-fee-rate-x u500000)
;; (define-constant pool-fee-rate-y u500000)
(define-constant pool-max-out-ratio u60000000)
(define-constant pool-max-in-ratio u60000000)
(define-constant pool-oracle-average u99000000)
(define-constant pool-fee-rebate u50000000)
(define-constant pool-start-block MAX_UINT)

;; Conversion rates per unit of token-amm-swap-pool (token-id 1)
;; 1 unit = 0.18626252 wxusd = 18626252 / ONE_8
;; 1 unit = 0.81701015 wusda = 81701015 / ONE_8
(define-constant WXUSD_PER_UNIT u18626252)
(define-constant WUSDA_PER_UNIT u81701015)

;; Calculate wxusd amount: balance * WXUSD_PER_UNIT / ONE_8
(define-private (calculate-wxusd (balance uint))
  (/ (* balance WXUSD_PER_UNIT) ONE_8))

;; Calculate wusda amount: balance * WUSDA_PER_UNIT / ONE_8
(define-private (calculate-wusda (balance uint))
  (/ (* balance WUSDA_PER_UNIT) ONE_8))

;; Hard-coded balances in fixed-point format (8 decimals)
(define-constant BALANCE_1 u599950010000) ;; SP1CM0AWD5FCT7RMNCQJ29XTX7ANXH4HMDDY3QW9H: 5999.50010000
(define-constant BALANCE_2 u550027647500) ;; SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E: 5500.27647500
(define-constant BALANCE_3 u450367261000) ;; SPVPAQ35P35JZYQA11A0E5DPY62E7P3HX0GA2RPH: 4503.67261000
(define-constant BALANCE_4 u600086543893) ;; SP3SHA1K2WKYA6AECJ88FMKD34RMS6KKPPAVRX16J: 6000.86543893

(define-public (execute (sender principal))
  (let (
      ;; Calculate amounts for address 1
      (wxusd-amount-1 (calculate-wxusd BALANCE_1))
      (wusda-amount-1 (calculate-wusda BALANCE_1))
      ;; Calculate amounts for address 2
      (wxusd-amount-2 (calculate-wxusd BALANCE_2))
      (wusda-amount-2 (calculate-wusda BALANCE_2))
      ;; Calculate amounts for address 3
      (wxusd-amount-3 (calculate-wxusd BALANCE_3))
      (wusda-amount-3 (calculate-wusda BALANCE_3))
      ;; Calculate amounts for address 4
      (wxusd-amount-4 (calculate-wxusd BALANCE_4))
      (wusda-amount-4 (calculate-wusda BALANCE_4))
      ;; Calculate total amounts
      (total-wxusd (+ (+ (+ wxusd-amount-1 wxusd-amount-2) wxusd-amount-3) wxusd-amount-4))
      (total-wusda (+ (+ (+ wusda-amount-1 wusda-amount-2) wusda-amount-3) wusda-amount-4))
    )
    (begin
      ;; Transfer total wxusd from vault to executor-dao (tx-sender)
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd total-wxusd tx-sender))
      
      ;; Transfer total wusda from vault to executor-dao (tx-sender)
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda total-wusda tx-sender))
      
      ;; Redemption for SP1CM0AWD5FCT7RMNCQJ29XTX7ANXH4HMDDY3QW9H
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd transfer-fixed wxusd-amount-1 tx-sender 'SP1CM0AWD5FCT7RMNCQJ29XTX7ANXH4HMDDY3QW9H none))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda transfer-fixed wusda-amount-1 tx-sender 'SP1CM0AWD5FCT7RMNCQJ29XTX7ANXH4HMDDY3QW9H none))
      
      ;; Redemption for SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd transfer-fixed wxusd-amount-2 tx-sender 'SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E none))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda transfer-fixed wusda-amount-2 tx-sender 'SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E none))
      
      ;; Redemption for SPVPAQ35P35JZYQA11A0E5DPY62E7P3HX0GA2RPH
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd transfer-fixed wxusd-amount-3 tx-sender 'SPVPAQ35P35JZYQA11A0E5DPY62E7P3HX0GA2RPH none))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda transfer-fixed wusda-amount-3 tx-sender 'SPVPAQ35P35JZYQA11A0E5DPY62E7P3HX0GA2RPH none))
      
      ;; Redemption for SP3SHA1K2WKYA6AECJ88FMKD34RMS6KKPPAVRX16J
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd transfer-fixed wxusd-amount-4 tx-sender 'SP3SHA1K2WKYA6AECJ88FMKD34RMS6KKPPAVRX16J none))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda transfer-fixed wusda-amount-4 tx-sender 'SP3SHA1K2WKYA6AECJ88FMKD34RMS6KKPPAVRX16J none))
      
      ;; Configure abtc-wsbtc pool
      (let (
          (new-supply (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 add-to-position pool-token-x pool-token-y pool-factor pool-amount-x (some pool-amount-y))))
          (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details pool-token-x pool-token-y pool-factor)))
        )
        (begin
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-enabled pool-token-x pool-token-y pool-factor true))
          ;; (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-x pool-token-x pool-token-y pool-factor pool-fee-rate-x))
          ;; (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rate-y pool-token-x pool-token-y pool-factor pool-fee-rate-y))
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-out-ratio pool-token-x pool-token-y pool-factor pool-max-out-ratio))
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-max-in-ratio pool-token-x pool-token-y pool-factor pool-max-in-ratio))
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-oracle-average pool-token-x pool-token-y pool-factor pool-oracle-average))
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rebate pool-token-x pool-token-y pool-factor pool-fee-rebate))
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-start-block pool-token-x pool-token-y pool-factor pool-start-block))
          
          (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 set-approved-token pool-token-y true))
          
          (print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details pool-token-x pool-token-y pool-factor)))
        )
      )
      
      ;; Finalise migrate for the following addresses
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP11W9HFWNHX22D2K2W13DJRXQN697S2SJRJ7TEP))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPFS7G36JKF80N3M47H5MDENH3S4MCN13CF3TJHD))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2YK0K7ZN00CQ77PHJADATZQRG4THBX7CFCWSYNF))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPXRFJMYDGVXYK77BAVV35EM3GPR1A4PJCCJPDXV))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SM2FEM079XQN5JTR622YKTDB3W7J8KM6RJNNRHHGD))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3T636CWCC6AYHMM4V5P8HWE4HCWH48E1KJHVXP2))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2P336EM6HGAX7NQJGR0A4W7KP11BNY25YDSTA6W))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1JM1HAYZM2JVT6EKCBPVE1AM8WW315TR028SKJY))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP23F07QZH8TGPCFJT0QJR8H9MMQGQB20H6FF1BF6))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP6V05EFZHDFBK3CT5F4ZQV74PK9XA2WZSYNTSNG))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP63HMSEJX3XVVYW9V4FDE4PPHQHXEASGBSBXB25))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP21RCXT7C1G543ZF1S0027K6YKF8RA3QBF1H1JWN))
      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2YSXXDA6YHY79JBNTFZPVYW9NF12TFN1059Y6XZ))
      
      (print {
        event: "amm-swap-pool-redemption",
        total-wxusd: total-wxusd,
        total-wusda: total-wusda
      })
      
      (ok true)
    )
  )
)

