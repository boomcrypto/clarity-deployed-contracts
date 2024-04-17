
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-COOLDOWN u105)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u2000)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var welsh-counter uint u0)
(define-data-var welsh-index uint u0)
(define-data-var cost-per-mint uint u50000000)
(define-data-var marketplace-commission uint u5000000)
(define-data-var rotation uint u1)
(define-data-var market-enabled bool false)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; TODO: rename methods & params

(define-public (accept-collection-bid (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap! (swap-usda-usdc-bitflow b1) (err u420)))
    (b3 (try! (swap-usdc-stx-velar b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (revoke-in-ustx (amountIn uint))
  (let (
    (b1 (try! (swap-stx-usdc-velar amountIn)))
    (b2 (unwrap! (swap-usdc-usda-bitflow b1) (err u420)))
    (b3 (try! (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (send-many (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (try! (redeem-vault 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token b1 prev-owner-hint)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-in-usda (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (try! (redeem-vault 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token b1 prev-owner-hint)))
    (b3 (unwrap! (swap-ststx-stx-bitflow b2) (err u420)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-in-stx (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (try! (redeem-vault 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin b1 prev-owner-hint)))
    (b3 (try! (swap-xbtc-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (buy-in-ustx (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (try! (redeem-vault 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin b1 prev-owner-hint)))
    (b3 (try! (swap-xbtc-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)



;; --

(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (redeem-vault 
  (token <ft-trait>) 
  (debt-payoff uint)
  (prev-owner-hint (optional principal)) 
)
  (let (
    (owner (unwrap-panic (get first-owner (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-sorted-v1-1 get-token (contract-of token))))))
  )
    (ok (* u100 (get collateral-received (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-manager-v1-1 redeem-vault
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-tokens-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-sorted-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-pool-active-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-helpers-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3
      owner
      token
      (/ debt-payoff u100)
      prev-owner-hint
    )))))
  )
)

(define-public (swap-stx-ststx-bitflow (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 (/ dx u100) u10))))
  (ok (* r u100)))
)

(define-public (swap-ststx-stx-bitflow (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 (/ dx u100) u10))))
  (ok (* r u100)))
)

(define-public (swap-usda-usdc-bitflow (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 (/ dx u100) u10))))
  (ok (* r u100)))
)

(define-public (swap-usdc-usda-bitflow (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-y-for-x 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 (/ dx u100) u10))))
  (ok (* r u100)))
)

(define-public (swap-xbtc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-xbtc-wstx-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-usdc-stx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u6
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-stx-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u6
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)
