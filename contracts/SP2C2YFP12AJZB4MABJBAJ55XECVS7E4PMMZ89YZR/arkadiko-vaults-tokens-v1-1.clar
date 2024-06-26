;; Vaults Collateral Tokens 
;;

(impl-trait .arkadiko-vaults-tokens-trait-v1-1.vaults-tokens-trait)

;; ---------------------------------------------------------
;; Constants
;; ---------------------------------------------------------

(define-constant ERR_NOT_AUTHORIZED u970401)
(define-constant ERR_UNKNOWN_TOKEN u970001)
(define-constant ERR_UPDATE_LIST_FAILED u970002)

;; ---------------------------------------------------------
;; Variables
;; ---------------------------------------------------------

(define-data-var token-list (list 25 principal) (list))
(define-data-var token-to-remove principal tx-sender)

;; ---------------------------------------------------------
;; Maps
;; ---------------------------------------------------------

(define-map tokens
  { 
    token: principal
  }
  {
    token-name: (string-ascii 12),
    max-debt: uint,
    vault-min-debt: uint,
    stability-fee: uint,

    liquidation-ratio: uint,
    liquidation-penalty: uint,

    redemption-fee-min: uint,
    redemption-fee-max: uint,
    redemption-fee-block-interval: uint,
    redemption-fee-block-rate: uint
  }
)

;; ---------------------------------------------------------
;; Getters
;; ---------------------------------------------------------

(define-read-only (get-token-list)
  (ok (var-get token-list))
)

(define-read-only (get-token (token principal))
  (let (
    (result (map-get? tokens { token: token }))
  )
    (if (is-none result)
      (err ERR_UNKNOWN_TOKEN)
      (ok (unwrap-panic result))
    )
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

;; Add or update token
(define-public (set-token 
  (token principal) 
  (token-name (string-ascii 12)) 
  (max-debt uint)
  (vault-min-debt uint)
  (stability-fee uint)
  (liquidation-ratio uint)
  (liquidation-penalty uint)
  (redemption-fee-min uint)
  (redemption-fee-max uint)
  (redemption-fee-block-interval uint)
  (redemption-fee-block-rate uint)
)
  (begin
    (asserts! (is-eq contract-caller (contract-call? .arkadiko-dao get-dao-owner)) (err ERR_NOT_AUTHORIZED))

    (if (is-some (index-of? (var-get token-list) token))
      ;; Token already in list
      false
      ;; Add token to list
      (begin
        (var-set token-list (unwrap! (as-max-len? (append (var-get token-list) token) u25) (err ERR_UPDATE_LIST_FAILED)))
        true
      )
    )

    (map-set tokens { token: token }
      {
        token-name: token-name,
        max-debt: max-debt,
        vault-min-debt: vault-min-debt,
        stability-fee: stability-fee,
        liquidation-ratio: liquidation-ratio, 
        liquidation-penalty: liquidation-penalty,
        redemption-fee-min: redemption-fee-min,
        redemption-fee-max: redemption-fee-max,
        redemption-fee-block-interval: redemption-fee-block-interval,
        redemption-fee-block-rate: redemption-fee-block-rate
      }
    )

    (ok true)
  )
)

;; Remove token
(define-public (remove-token (token principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .arkadiko-dao get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-some (index-of? (var-get token-list) token)) (err ERR_UNKNOWN_TOKEN))

    (var-set token-to-remove token)

    (map-delete tokens { token: token })
    (var-set token-list (filter is-token-to-remove (var-get token-list)))
    (ok true)
  )
)

(define-read-only (is-token-to-remove (token principal))
  (not (is-eq token (var-get token-to-remove)))
)

;; ---------------------------------------------------------
;; Init
;; ---------------------------------------------------------

(begin
  (var-set token-list (list
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token 
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
  ))

  (map-set tokens
    { 
      token: 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token 
    }
    {
      token-name: "STX",
      max-debt: u1000000000000,               ;; 1M
      vault-min-debt: u500000000,             ;; 500 usda
      stability-fee: u400,                    ;; 4% in bps
      liquidation-ratio: u14000,              ;; 140% in bps
      liquidation-penalty: u1000,             ;; 10% in bps
      redemption-fee-min: u3000,
      redemption-fee-max: u9000,
      redemption-fee-block-interval: u144,    ;; Fee decay 1 day
      redemption-fee-block-rate: u500000000   ;; Decrease last block with 1, per 500 USDA redeemed
    }
  )

  (map-set tokens
    {
      token: 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    }
    {
      token-name: "stSTX",
      max-debt: u5000000000000,               ;; 5M
      vault-min-debt: u500000000,             ;; 500 usda
      stability-fee: u400,                    ;; 4% in bps
      liquidation-ratio: u14000,              ;; 140% in bps
      liquidation-penalty: u1000,             ;; 10% in bps
      redemption-fee-min: u3000,
      redemption-fee-max: u9000,
      redemption-fee-block-interval: u144,    ;; Fee decay 1 day
      redemption-fee-block-rate: u500000000   ;; Decrease last block with 1, per 500 USDA redeemed
    }
  )

  (map-set tokens
    {
      token: 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    }
    {
      token-name: "xBTC",
      max-debt: u1000000000000,               ;; 1M
      vault-min-debt: u500000000,             ;; 500 usda
      stability-fee: u400,                    ;; 4% in bps
      liquidation-ratio: u13000,              ;; 130% in bps
      liquidation-penalty: u1000,             ;; 10% in bps
      redemption-fee-min: u3000,
      redemption-fee-max: u9000,
      redemption-fee-block-interval: u144,    ;; Fee decay 1 day
      redemption-fee-block-rate: u500000000   ;; Decrease last block with 1, per 500 USDA redeemed
    }
  )
)
