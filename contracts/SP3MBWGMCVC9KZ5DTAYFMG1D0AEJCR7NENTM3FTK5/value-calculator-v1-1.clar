;; @contract Value Calculator
;; @version 1.1

(impl-trait .value-calculator-trait-v1-1.value-calculator-trait)
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u3503001)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map token-info
  { token: principal }
  {
    liquidity-token: bool,
    token-x: principal,
    token-y: principal
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-token-info (token principal))
  (default-to
    {
      liquidity-token: false,
      token-x: .lydian-token,
      token-y: .lydian-token
    }
    (map-get? token-info { token: token })
  )
)

;; ------------------------------------------
;; Valuation
;; ------------------------------------------

(define-public (get-valuation (token-trait <ft-trait>) (amount uint))
  (let (
    (is-lp (get liquidity-token (get-token-info (contract-of token-trait))))
  )
    (if (is-eq is-lp false)
      (get-valuation-single token-trait amount)
      (get-valuation-lp token-trait amount)
    )
  )
)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

(define-public (get-valuation-single (token-trait <ft-trait>) (amount uint))
  (let (
    (token-decimals (unwrap-panic (contract-call? token-trait get-decimals)))
    (lydian-decimals (unwrap-panic (contract-call? .lydian-token get-decimals)))
    (token-pow (pow u10 token-decimals))
    (lydian-pow (pow u10 lydian-decimals))
  )
    (ok (/ (* amount lydian-pow) token-pow))
  )
)

(define-public (get-valuation-lp (token-trait <ft-trait>) (amount uint))
  (let (
    (total-value (unwrap-panic (get-lp-total-value token-trait)))
    (total-supply (unwrap-panic (contract-call? token-trait get-total-supply)))

    (lp-share (/ (* amount u10000000000) total-supply))
    (value (/ (* total-value lp-share) u10000000000))
  )
    (ok value)
  )
)

(define-public (get-lp-total-value (token-trait <ft-trait>))
  (let (
    (k-value (unwrap-panic (get-lp-k-value token-trait)))
    (value (* (sqrti k-value) u2))
  )
    (ok value)
  )
)

(define-public (get-lp-k-value (token-trait <ft-trait>))
  (let (
    (token-x (get token-x (get-token-info (contract-of token-trait))))
    (token-y (get token-y (get-token-info (contract-of token-trait))))

    (decimals-token-x (unwrap-panic (get-decimals-single token-x)))
    (decimals-token-y (unwrap-panic (get-decimals-single token-y)))
    (decimals-token-swap (unwrap-panic (contract-call? token-trait get-decimals)))
    (decimals (- (+ decimals-token-x decimals-token-y) decimals-token-swap))

    (reserves (unwrap-panic (get-lp-reserves token-trait)))
    (reserve-x (get balance-x reserves))
    (reserve-y (get balance-y reserves))

    (k-value (/ (* reserve-x reserve-y u1000000) (pow u10 decimals)))
  )
    (ok k-value)
  )
)

;; ---------------------------------------------------------
;; Hard coded contracts
;; ---------------------------------------------------------

;; Hard coding to avoid extra parameter
(define-public (get-decimals-single (token principal))
  (if (is-eq token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-decimals)

    (if (is-eq token .lydian-token)
      (contract-call? .lydian-token get-decimals)

      (if (is-eq token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin)
        (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-decimals)

        (ok u6)
      )
    )
  )
)

;; Get LP reserves from swap
(define-public (get-lp-reserves (token-trait <ft-trait>))
  (let (
    (token-x (get token-x (get-token-info (contract-of token-trait))))
    (token-y (get token-y (get-token-info (contract-of token-trait))))

    (pair-info (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details token-x token-y)))
    (balance-x (unwrap-panic (get balance-x pair-info)))
    (balance-y (unwrap-panic (get balance-y pair-info)))
  )
    (ok { balance-x: balance-x, balance-y: balance-y })
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (add-token (token principal) (liquidity-token bool) (token-x principal) (token-y principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (map-set token-info { token: token } { liquidity-token: liquidity-token, token-x: token-x, token-y: token-y })
    (ok true)
  )
)
