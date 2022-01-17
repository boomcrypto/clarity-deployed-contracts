(use-trait ft 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait pool 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-trait-v1.stake-pool-trait)
;; (use-trait registry 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-trait-v1.stake-registry-trait)

(define-public (increment-n (max-sell (optional uint)))
  (let
    (
      (new-diko (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1))) 
      (balances (try! (get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)))
      (stx-balance (unwrap-panic (element-at balances u0)))
      (diko-balance (unwrap-panic (element-at balances u1)))
      (dx (get-sell-amount new-diko diko-balance max-sell))
      (dy (/ (* stx-balance dx) (+ diko-balance dx)))
      (swap-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0)))
      (bought-stx (unwrap-panic (element-at swap-res u0)))
      (sold-diko (unwrap-panic (element-at swap-res u1)))
      (add-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko bought-stx u0)))
      (lp-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance tx-sender)))
      (stake-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 stake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko lp-balance)))
    )
    (ok { staked: stake-res })
  )
)

(define-public (increment)
  (let
    (
      (stx-usda (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1)))
      (diko-usda (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-diko-usda-v1-1)))
      (stx-diko (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1)))
      (vault (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-rewards-v1-1 claim-pending-rewards)))
      (total (+ (+ stx-usda diko-usda) (+ stx-diko vault)))
    )
    (ok total)
  )
)

(define-public (c-increment-one)
  (let
    (
      (claimed (try! (increment)))
      (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)))
      (staked (try! (increment-one balance)))
    )
    (ok staked)
  )
)

(define-public (c-decrement-one)
  (let
    (
      (claimed (try! (increment)))
      (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)))
      (staked (try! (decrement-one balance)))
    )
    (ok staked)
  )
)

(define-public (increment-one (amount uint))
  (let
    (
      (balances (try! (get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)))
      (stx-balance (unwrap-panic (element-at balances u0)))
      (diko-balance (unwrap-panic (element-at balances u1)))
      (dx (calculate-swap-in diko-balance amount))
      (swap-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0)))
      (bought-stx (unwrap-panic (element-at swap-res u0)))
      (add-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko bought-stx u0)))
      (lp-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance tx-sender)))
      (stake-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 stake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko lp-balance)))
    )
    (ok stake-res)
  )
)

(define-public (decrement-one (amount uint))
  (let
    (
      (balances (try! (get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)))
      (diko-balance (unwrap-panic (element-at balances u0)))
      (balance-balance (unwrap-panic (element-at balances u1)))
      (dx (calculate-swap-in diko-balance amount))
      (swap-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0)))
      (bought-stx (unwrap-panic (element-at swap-res u0)))
      (add-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda bought-stx u0)))
      (lp-balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance tx-sender)))
      (stake-res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 stake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-diko-usda-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda lp-balance)))
    )
    (ok stake-res)
  )
)

(define-private (get-balances (a <ft>) (b <ft>))
  (match
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances a b)
    balances (ok balances)
    error error
  )
)

(define-private (get-sell-amount (new-diko uint) (diko-balance uint) (max-sell (optional uint)))
  (let
    (
      (swap-in (calculate-swap-in diko-balance new-diko))
    )
    (match max-sell
      max (if (> max swap-in) swap-in max)
      swap-in
    )
  )
)

(define-read-only (calculate-swap-in (reserves uint) (amount uint))
  (let
    (
      (a (+ (* amount u3988000) (* reserves u3988009)))
      (b (sqrti (* reserves a)))
      (c (- b (* reserves u1997)))
      (d (/ c u1994))
    )
    d
  )
)
