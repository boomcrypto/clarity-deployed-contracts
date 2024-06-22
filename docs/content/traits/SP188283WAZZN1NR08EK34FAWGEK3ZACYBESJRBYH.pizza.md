---
title: "Trait pizza"
draft: true
---
```
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


(define-public (a11 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-arkadiko-stx-usda amountIn)))
    (b2 (unwrap-panic (swap-arkadiko-usda-diko b1)))
    (b3 (unwrap-panic (swap-arkadiko-diko-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)
(define-public (a12 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-arkadiko-stx-diko amountIn)))
    (b2 (unwrap-panic (swap-arkadiko-diko-usda b1)))
    (b3 (unwrap-panic (swap-arkadiko-usda-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (a21 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-velar-stx-velar amountIn)))
    (b2 (unwrap-panic (swap-velar-velar-usdc b1)))
    (b3 (unwrap-panic (swap-velar-usdc-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)
(define-public (a22 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-velar-stx-usdc amountIn)))
    (b2 (unwrap-panic (swap-velar-usdc-velar b1)))
    (b3 (unwrap-panic (swap-velar-velar-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (a31 (amountIn uint))
  (let (
    (b1 (try! (swap-alex-stx-welsh amountIn)))
    (b2 (try! (swap-velar-welsh-stx b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)
(define-public (a32 (amountIn uint))
  (let (
    (b1 (try! (swap-velar-stx-welsh amountIn)))
    (b2 (try! (swap-alex-welsh-stx b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (a41 (amountIn uint))
  (let (
    (b1 (try! (swap-alex-stx-welsh amountIn)))
    (b2 (try! (swap-arkadiko-welsh-stx b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)
(define-public (a42 (amountIn uint))
  (let (
    (b1 (try! (swap-arkadiko-stx-welsh amountIn)))
    (b2 (try! (swap-alex-welsh-stx b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (a51 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-alex-stx-xbtc amountIn)))
    (b2 (unwrap-panic (swap-arkadiko-xbtc-usda b1)))
    (b3 (unwrap-panic (swap-arkadiko-usda-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)
(define-public (a52 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-arkadiko-stx-usda amountIn)))
    (b2 (unwrap-panic (swap-arkadiko-usda-xbtc b1)))
    (b3 (unwrap-panic (swap-alex-xbtc-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)


(define-public (a61 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-alex-stx-xusd amountIn)))
    (b2 (unwrap-panic (swap-alex-xusd-usda b1)))
    (b3 (unwrap-panic (swap-arkadiko-usda-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)
(define-public (a62 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-arkadiko-stx-usda amountIn)))
    (b2 (unwrap-panic (swap-alex-usda-xusd b1)))
    (b3 (unwrap-panic (swap-alex-xusd-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (b11 (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-arkadiko-stx-usda amountIn)))
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
(define-public (b12 (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-arkadiko-stx-usda amountIn)))
    (b2 (try! (redeem-vault 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin b1 prev-owner-hint)))
    (b3 (try! (swap-arkadiko-xbtc-usda b2)))
    (b4 (try! (swap-arkadiko-usda-stx b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)
(define-public (b13 (amountIn uint) (prev-owner-hint (optional principal)))
  (let (
    (b1 (try! (swap-arkadiko-stx-usda amountIn)))
    (b2 (try! (redeem-vault 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin b1 prev-owner-hint)))
    (b3 (try! (swap-alex-xbtc-stx b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)


(define-public (swap-arkadiko-wstx-xbtc (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-xbtc-wstx (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-arkadiko-xbtc-usda (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-usda-xbtc (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-arkadiko-stx-diko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-diko-stx (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-arkadiko-stx-usda (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-usda-stx (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-arkadiko-diko-usda (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-usda-diko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-arkadiko-stx-welsh (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)
(define-public (swap-arkadiko-welsh-stx (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
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




(define-public (swap-velar-stx-welsh (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u27
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)
(define-public (swap-velar-welsh-stx (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u27
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-stx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)
(define-public (swap-velar-velar-stx (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)












(define-public (swap-alex-stx-welsh (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi u100000000 dx (some u0)))))
  (ok r))
)
(define-public (swap-alex-welsh-stx (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-stx-xbtc (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc u100000000 dx (some u0)))))
  (ok r))
)
(define-public (swap-alex-xbtc-stx (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-stx-xusd (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd u100000000 dx (some u0)))))
  (ok r))
)
(define-public (swap-alex-xusd-stx (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-usda-xusd (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd u5000000 dx (some u0)))))
  (ok r))
)
(define-public (swap-alex-xusd-usda (dx uint))
  (let ((r (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda u5000000 dx (some u0)))))
  (ok r))
)







(define-public (swap-velar-stx-usdc (dx uint))
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

(define-public (swap-velar-usdc-stx (dx uint))
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

(define-public (swap-velar-welsh-usdc (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u10
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-usdc-welsh (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u10
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-velar-wstx (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u22
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-velar-usdc (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u22
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)
```
