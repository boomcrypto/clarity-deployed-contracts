;; @contract Bond Values
;; @version 1.1

(impl-trait .bond-values-trait-v1-1.bond-values-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

;; LDN value in USDA / token value in USDA
(define-read-only (get-valuation (token principal))
  (let (
    (ldn-value (unwrap-panic (get-usda-value .lydian-token)))
    (token-value (unwrap-panic (get-usda-value token)))
  )
    (ok (/ (* u1000000 ldn-value) token-value))
  )
)

;; Get USDA value of token
(define-read-only (get-usda-value (token principal)) 

  ;; LDN
  (if (is-eq token .lydian-token)
    (get-usda-value-ldn)

  ;; wSTX
  (if (is-eq token .wrapped-stacks-token)
    (get-usda-value-wstx)

  ;; USDA 
  (if (is-eq token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
    (ok u1000000)

  ;; LDN/USDA
  (if (is-eq token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-ldn-usda)
    (get-usda-value-ldn-usda)

  ;; xBTC
  (if (is-eq token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin)
    (get-usda-value-xbtc)

    ;; Rest
    (ok u0)
  )))))
)

;; ------------------------------------------
;; USDA value helpers
;; ------------------------------------------

(define-read-only (get-usda-value-ldn)
  (let (
    (pool-balance (unwrap-panic (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details .lydian-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))))
    (price (/ (* u1000000 (get balance-y pool-balance)) (get balance-x pool-balance)))
  )
    (ok price)
  )
)

(define-read-only (get-usda-value-wstx)
  (let (
    (pool-balance (unwrap-panic (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))))
    (price (/ (* u1000000 (get balance-y pool-balance)) (get balance-x pool-balance)))
  )
    (ok price)
  )
)

;; Does not take decimals into account
;; As deposits do take decimals into account
(define-read-only (get-usda-value-xbtc)
  (let (
    (pool-balance (unwrap-panic (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))))
    (price (/ (* u1000000 (get balance-y pool-balance)) (get balance-x pool-balance)))
  )
    (ok price)
  )
)

(define-read-only (get-usda-value-ldn-usda)
  (let (
    (total-supply (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-ldn-usda get-total-supply)))
    (pool-balance (unwrap-panic (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details .lydian-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))))
    (balance-y (get balance-y pool-balance))
  )
    (ok (/ (* balance-y u2000000) total-supply))
  )
)
