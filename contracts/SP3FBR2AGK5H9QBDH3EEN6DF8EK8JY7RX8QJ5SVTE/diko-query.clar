(define-read-only (get-lp-balances (address principal) (block-hash (buff 32)))
  (at-block block-hash (query-balance address))
)

;; internal function, called within `at-block`
(define-private (query-balance (address principal))
  (let
    (
      (wstx-diko-staked (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 get-stake-amount-of address))
      (wstx-diko-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance address)))
      (wstx-diko (+ wstx-diko-staked wstx-diko-balance))

      (wstx-usda-staked (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1 get-stake-amount-of address))
      (wstx-usda-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda get-balance address)))
      (wstx-usda (+ wstx-usda-staked wstx-usda-balance))

      (diko-usda-staked (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-diko-usda-v1-1 get-stake-amount-of address))
      (diko-usda-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda get-balance address)))
      (diko-usda (+ diko-usda-staked diko-usda-balance))
    )
    { wstx-diko: wstx-diko, wstx-usda: wstx-usda, diko-usda: diko-usda }
  )
)

(define-read-only (get-block-hash (height uint))
  (get-block-info? id-header-hash height)
)

(define-read-only (get-total-supply (block-hash (buff 32)))
  (at-block block-hash (query-total-supply))
)

(define-private (query-total-supply)
  (let
    (
      (wstx-diko (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-total-supply)))
      (wstx-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda get-total-supply)))
      (diko-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda get-total-supply)))
    )
    { wstx-diko: wstx-diko, wstx-usda: wstx-usda, diko-usda: diko-usda }
  )
)