(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)

(define-constant token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)
(define-constant token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo)
(define-constant factor ONE_8)
(define-constant start-cycle u223)
(define-constant end-cycle u268)
(define-constant reward-cycle (* u600000 ONE_8))

(define-public (execute (sender principal))
  (let (
(id (get pool-id (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 id))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-activation-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 id u46601))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-apower-multiplier-in-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 id u0))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-coinbase-amount 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 id ONE_8 ONE_8 ONE_8 ONE_8 ONE_8))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming add-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 id token-y reward-cycle start-cycle end-cycle))
;; add value of token-y
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo transfer-fixed (* reward-cycle (- (+ end-cycle u1) start-cycle)) tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3V6FVEWHH69QCWFAR561AN03QA0GM70VZA4D2WJ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3QZ2WB9937YNBH2GR9ZHGH8EFXG1WRHZACCDAN7))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2KVKTGQZ6GE5ND1MRTJHTHATG980AK7Y80048KR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3SSBX8ZCXDY90DX9MRT3JHF7AGSCVRW2Q82K25A))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP317SHW9WKFG3GS9YHWM9FK0XFGCD6MXVHYP63HM))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP12E9DE7KZBMH4KPYK94JA54KDBCMNR255DRZAXJ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1T8VQVGZDCC7XTF5FBEHMQ3RJB2FZ06GS3T6YQN))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPEJJ2ZBXK5K2XPD1F9SAGWK397Z32NY0Z926EGE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2JYXW40Y34SEVQN2BAF27P5ZQ3BGNMN7FMWPASR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2Q95PDBPDXXMCS7064SQGR3HHE9J44K533Z8VWR))

    (ok true)))
