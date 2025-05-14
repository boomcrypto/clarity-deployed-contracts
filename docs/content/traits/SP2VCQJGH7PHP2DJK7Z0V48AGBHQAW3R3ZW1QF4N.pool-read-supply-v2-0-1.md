---
title: "Trait pool-read-supply-v2-0-1"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)

(define-read-only (is-active (asset principal))
  (let (
    (reserve-state (get-reserve-data asset))
    )
    (and (get is-active reserve-state) (not (get is-frozen reserve-state)))
  )
)

(define-constant available-assets (list
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
  'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
  .wstx
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
  'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
  'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
  'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
))

(define-read-only (get-supplieable-assets)
  available-assets
)

(define-read-only (get-borroweable-assets)
  (list
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    .wstx
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
    'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
  )
)

(define-read-only (is-isolated-asset (asset principal))
  (is-isolated-type asset)
)

(define-read-only (is-isolated-type (asset principal))
  (default-to false (contract-call? .pool-reserve-data get-isolated-assets-read asset)))

(define-read-only (is-used-as-collateral (who principal) (asset principal))
  (get use-as-collateral (get-user-reserve-data who asset))
)

;; Define a helper function to get reserve data
(define-read-only (get-reserve-data (asset principal))
  (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset))
)

(define-read-only (get-user-reserve-data (who principal) (asset principal))
  (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read who asset))
)

(define-read-only (get-asset-supply-apy (reserve principal))
  (let (
    (reserve-resp (get-reserve-data reserve))
  )
    (calculate-linear-interest
      (get current-liquidity-rate reserve-resp)
      (* u144 u365)
    )
  )
)

(define-read-only (get-user-assets (who principal))
  (default-to
    { assets-supplied: (list), assets-borrowed: (list) }
    (contract-call? .pool-reserve-data get-user-assets-read who)))

(define-read-only (get-useable-collateral-usd-ststx (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zststx-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (get-ststx-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-aeusdc (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zaeusdc-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )   
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0 get-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-stx (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zwstx-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data .wstx))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who .wstx)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-3 get-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-diko (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zdiko-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (get-diko-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-usdh (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zusdh-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (get-usdh-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-susdt (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zsusdt-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (get-usdh-price)
      )
    )
  )
)

(define-read-only (get-useable-collateral-usd-sbtc (who principal))
  (let (
    (asset-balance (unwrap-panic (contract-call? .zsbtc-v2-0 get-principal-balance who)))
    (reserve-data (get-reserve-data 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)))
    (asset-decimals (get decimals reserve-data))
    (base-ltv-as-collateral (get base-ltv-as-collateral reserve-data))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)
      )
    )
  )
    (mul
      base-ltv-as-collateral
      (mul
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index))
        (get-sbtc-price)
      )
    )
  )
)

(define-read-only (get-supplied-balance-user-usd-ststx (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-ststx who)
    u6
    (get-ststx-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-aeusdc (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-aeusdc who)
    u6
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0 get-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-stx (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-stx who)
    u6
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-3 get-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-diko (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-stx who)
    u6
    (get-diko-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-usdh (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-usdh who)
    u8
    (get-usdh-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-susdt (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-susdt who)
    u8
    (get-susdt-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-usda (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-usda who)
    u6
    (get-usda-price)
  )
)

(define-read-only (get-supplied-balance-user-usd-sbtc (who principal) (oracle principal))
  (token-to-usd
    (get-supplied-balance-user-sbtc who)
    u8
    (get-sbtc-price)
  )
)

(define-read-only (get-supplied-balance-user-ststx (who principal))
  (let ((principal (unwrap-panic (contract-call? .zststx-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u6 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token principal u6)
  )
)

(define-read-only (get-supplied-balance-user-aeusdc (who principal))
  (let ((principal (unwrap-panic (contract-call? .zaeusdc-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u6 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc principal u6)
  )
)

(define-read-only (get-supplied-balance-user-stx (who principal))
  (let ((principal (unwrap-panic (contract-call? .zwstx-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u6 .wstx principal u6)
  )
)

(define-read-only (get-supplied-balance-user-diko (who principal))
  (let ((principal (unwrap-panic (contract-call? .zdiko-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token principal u6)
  )
)

(define-read-only (get-supplied-balance-user-usdh (who principal))
  (let ((principal (unwrap-panic (contract-call? .zusdh-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u8 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 principal u8)
  )
)

(define-read-only (get-supplied-balance-user-susdt (who principal))
  (let ((principal (unwrap-panic (contract-call? .zsusdt-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u8 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt principal u8)
  )
)

(define-read-only (get-supplied-balance-user-usda (who principal))
  (let ((principal (unwrap-panic (contract-call? .zusda-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token principal u6)
  )
)

(define-read-only (get-supplied-balance-user-sbtc (who principal))
  (let ((principal (unwrap-panic (contract-call? .zsbtc-v2-0 get-principal-balance who))))
    (calculate-cumulated-balance who u8 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token principal u8)
  )
)

(define-read-only (get-supplied-balance-usd-ststx)
  (token-to-usd
    (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token get-balance .pool-vault))
    u6
    (get-ststx-price)
  )
)

(define-read-only (get-supplied-balance-usd-aeusdc)
  (token-to-usd
    (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance .pool-vault))
    u6
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0 get-price)
  )
)

(define-read-only (get-supplied-balance-usd-stx)
  (token-to-usd
    (unwrap-panic (contract-call? .wstx get-balance .pool-vault))
    u6
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-3 get-price)
  )
)

(define-read-only (get-supplied-balance-usd-diko)
  (token-to-usd
    (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance .pool-vault))
    u6
    (get-diko-price)
  )
)

(define-read-only (get-supplied-balance-usd-usdh)
  (token-to-usd
    (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance .pool-vault))
    u8
    (get-usdh-price)
  )
)

(define-read-only (get-supplied-balance-usd-susdt)
  (token-to-usd
    (unwrap-panic (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt get-balance .pool-vault))
    u8
    (get-susdt-price)
  )
)

(define-read-only (get-supplied-balance-usd-usda)
  (token-to-usd
    (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .pool-vault))
    u6
    (get-usda-price)
  )
)

(define-read-only (get-supplied-balance-usd-sbtc)
  (token-to-usd
    (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance .pool-vault))
    u8
    (get-sbtc-price)
  )
)

(define-read-only (get-supplied-balance-ststx)
  (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-aeusdc)
  (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-stx)
  (unwrap-panic (contract-call? .wstx get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-diko)
  (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-usdh)
  (unwrap-panic (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-susdt)
  (unwrap-panic (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-usda)
  (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .pool-vault))
)

(define-read-only (get-supplied-balance-sbtc)
  (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance .pool-vault))
)
;; utils functions

(define-read-only (get-ststx-price)
  (let (
    (ststx-price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "stSTX")))
  )
    (* ststx-price u100)
  )
)

(define-read-only (get-stx-price)
  (let (
    (stx-price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "STX")))
  )
    (* stx-price u100)
  )
)

(define-read-only (get-diko-price)
  (let (
    (price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "DIKO")))
  )
    (* price u100)
  )
)

(define-read-only (get-usdh-price)
  (let (
    (price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usdh-oracle-v1-0 get-price))
  )
    price
  )
)

(define-read-only (get-susdt-price)
  (let (
    (price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.susdt-oracle-v1-0 get-price))
  )
    price
  )
)

(define-read-only (get-usda-price)
  (let (
    (price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "USDA")))
  )
    (* price u100)
  )
)

(define-read-only (get-sbtc-price)
  (let (
    (price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "BTC")))
  )
    (* price u100)
  )
)

(define-read-only (token-to-usd (amount uint) (decimals uint) (unit-price uint))
  (contract-call? .math-v1-2 mul-to-fixed-precision amount decimals unit-price)
)

(define-read-only (calculate-cumulated-balance
  (who principal)
  (lp-decimals uint)
  (asset <ft>)
  (asset-balance uint)
  (asset-decimals uint))
  (let (
    (asset-principal (contract-of asset))
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset-principal)))
    (user-index (unwrap-panic (contract-call? .pool-reserve-data get-user-index-read who (contract-of asset))))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data)))
        )
      (from-fixed-to-precision
        (mul-to-fixed-precision
          asset-balance
          asset-decimals
          (div reserve-normalized-income user-index)
        )
        asset-decimals
      )
  )
)

(define-read-only (get-normalized-income
  (current-liquidity-rate uint)
  (last-updated-block uint)
  (last-liquidity-cumulative-index uint))
  (let (
    (cumulated 
      (calculate-linear-interest
        current-liquidity-rate
        (- stacks-block-height last-updated-block))))
    (mul cumulated last-liquidity-cumulative-index)
  )
)

(define-read-only (calculate-linear-interest
  (current-liquidity-rate uint)
  (delta uint))
  (let (
    (rate (get-rt-by-block current-liquidity-rate delta))
  )
    (+ one-8 rate)
  )
)

(define-read-only (calculate-compounded-interest
  (current-liquidity-rate uint)
  (delta uint))
  (begin
    (taylor-6 (get-rt-by-block current-liquidity-rate delta))
  )
)

(define-constant one-8 u100000000)
(define-constant one-12 u1000000000000)
(define-constant fixed-precision u8)

(define-constant max-value u340282366920938463463374607431768211455)

(define-constant e 271828182)
;; (* u144 u365 u10 u60)
(define-constant seconds-in-year u31536000)
;; (* u10 u60)
(define-constant seconds-in-block u600)
;; seconds-year/seconds-block, to multiply with number of blocks to determine seconds passed in x number of blocks, is in fixed-precision
;; (/ (* seconds-in-block one-8) u31536000)
(define-constant sb-by-sy u1903)

(define-read-only (get-max-value)
  max-value
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ one-8 u2)) one-8))

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x one-8) (/ y u2)) y))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (mul (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (mul (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (div (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (div (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (div-precision-to-fixed (a uint) (b uint) (decimals uint))
  (let (
    (result (/ (* a (pow u10 decimals)) b)))
    (to-fixed result decimals)
  )
)

;; Multiply a number with arbitrary decimals with a fixed-precision number
;; return number with arbitrary decimals
(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    ;; convert a and b-fixed in decimals-a precision
    ;; result is in decimals-a precision
    (mul-arbitrary a (* b-fixed (pow u10 (- decimals-a fixed-precision))) decimals-a)
    ;; convert a to fixed precision
    ;; result is in fixed precision, convert to decimals-a
    (/
      (mul-arbitrary (* a (pow u10 (- fixed-precision decimals-a))) b-fixed u8)
      (pow u10 (- fixed-precision decimals-a)))
  )
)

;; Divide a number with arbitrary decimals by a fixed-precision number, then return to
;; number with arbitrary decimals
(define-read-only (div-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    ;; convert b-fixed to decimals-a precision
    ;; final result is in decimals-a precision
    (div-arbitrary a (* b-fixed (pow u10 (- decimals-a fixed-precision))) decimals-a)
    ;; convert a to fixed precision
    ;; result is in fixed precision, convert to decimals-a
    (/
      (div-arbitrary (* a (pow u10 (- fixed-precision decimals-a))) b-fixed u8)
      (pow u10 (- fixed-precision decimals-a)))
  )
)

(define-read-only (mul-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x y) (/ (pow u10 arbitrary-prec) u2)) (pow u10 arbitrary-prec)))

(define-read-only (div-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x (pow u10 arbitrary-prec)) (/ y u2)) y))

(define-read-only (add-precision-to-fixed (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (+ (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (+ (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (sub-precision-to-fixed (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (- (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (- (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (to-fixed (a uint) (decimals-a uint))
  (if (> decimals-a fixed-precision)
    (/ a (pow u10 (- decimals-a fixed-precision)))
    (* a (pow u10 (- fixed-precision decimals-a)))
  )
)

;; multiply a number of arbitrary precision with a 8-decimals fixed number
;; convert back to unit of arbitrary precision
(define-read-only (mul-perc (a uint) (decimals-a uint) (b-fixed uint))
  (mul-precision-with-factor a decimals-a b-fixed)
)

(define-read-only (fix-precision (a uint) (decimals-a uint) (b uint) (decimals-b uint))
  (let (
    (a-standard
      (if (> decimals-a fixed-precision)
        (/ a (pow u10 (- decimals-a fixed-precision)))
        (* a (pow u10 (- fixed-precision decimals-a)))
      ))
    (b-standard
      (if (> decimals-b fixed-precision)
        (/ b (pow u10 (- decimals-b fixed-precision)))
        (* b (pow u10 (- fixed-precision decimals-b)))
      ))
  )
    {
      a: a-standard,
      decimals-a: decimals-a,
      b: b-standard,
      decimals-b: decimals-b,
    }
  )
)

(define-read-only (from-fixed-to-precision (a uint) (decimals-a uint))
  (if (> decimals-a fixed-precision)
    (* a (pow u10 (- decimals-a fixed-precision)))
    (/ a (pow u10 (- fixed-precision decimals-a)))
  )
)

;; x-price and y-price are in fixed precision
(define-read-only (get-y-from-x
  (x uint)
  (x-decimals uint)
  (y-decimals uint)
  (x-price uint)
  (y-price uint)
  )
  (if (> x-decimals y-decimals)
    ;; decrease decimals if x has more decimals
    (/ (div-precision-with-factor (mul-precision-with-factor x x-decimals x-price) x-decimals y-price) (pow u10 (- x-decimals y-decimals)))
    ;; do operations in the amounts with greater decimals, convert x to y-decimals
    (div-precision-with-factor (mul-precision-with-factor ( * x (pow u10 (- y-decimals x-decimals))) y-decimals x-price) y-decimals y-price)
  )
)

(define-read-only (is-odd (x uint))
  (not (is-even x))
)

(define-read-only (is-even (x uint))
  (is-eq (mod x u2) u0)
)

;; rate in 8-fixed
;; n-blocks
(define-read-only (get-rt-by-block (rate uint) (delta uint))
  (if (is-eq delta u0)
    u0
    (let (
      (start-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height delta))))
      ;; add 5 seconds
      (end-time (+ u5 (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))))
      (delta-time (- end-time start-time))
    )
      (/ (* rate delta-time) seconds-in-year)
    )
  )
)

(define-read-only (get-sb-by-sy)
  sb-by-sy
)

(define-read-only (get-e) e)

(define-read-only (get-one) one-8)

(define-read-only (get-seconds-in-year)
  seconds-in-year
)

(define-read-only (get-seconds-in-block)
  seconds-in-block
)

(define-constant fact_2 u200000000)
;; (mul u300000000 u200000000)
(define-constant fact_3 u600000000)
;; (mul u400000000 (mul u300000000 u200000000))
(define-constant fact_4 u2400000000)
;; (mul u500000000 (mul u400000000 (mul u300000000 u200000000)))
(define-constant fact_5 u12000000000)
;; (mul u600000000 (mul u500000000 (mul u400000000 (mul u300000000 u200000000))))
(define-constant fact_6 u72000000000)

;; taylor series expansion to the 6th degree to estimate e^x
(define-read-only (taylor-6 (x uint))
  (let (
    (x_2 (mul x x))
    (x_3 (mul x x_2))
    (x_4 (mul x x_3))
    (x_5 (mul x x_4))
  )
    (+
      one-8 x
      (div x_2 fact_2)
      (div x_3 fact_3)
      (div x_4 fact_4)
      (div x_5 fact_5)
      (div (mul x x_5) fact_6)
    )
  )
)
```
