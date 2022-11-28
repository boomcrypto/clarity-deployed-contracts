(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stake-pool-trait 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-trait-v1.stake-pool-trait)
(use-trait stake-registry-trait 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-trait-v1.stake-registry-trait)

;; errors
;;
(define-constant ERR-NOT-AUTHORIZED (err u401))

;; constants
;;
(define-constant CONTRACT-OWNER tx-sender)

;; data maps and vars
;;
(define-data-var stake-amount uint u0)

;; Get stake info - amount staked
(define-read-only (get-stake-amount-of)
  (var-get stake-amount)
)

;; @desc stake tokens in the pool
(define-public (stake (registry-trait <stake-registry-trait>) (pool-trait <stake-pool-trait>) (token-trait <ft-trait>) (amount uint))
    (let (
        ;; Calculate new stake amount
        (new-stake-amount (+ (var-get stake-amount) amount))
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

        ;; Transfer LP token from user to contract
        (try! (contract-call? token-trait transfer amount tx-sender (as-contract tx-sender) none))

        ;; Stake LP tokens
        (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 stake registry-trait pool-trait token-trait amount)))

        ;; Update staker info
        (var-set stake-amount new-stake-amount)

        (ok amount)
    )
)

;; @desc unstake tokens in the pool
(define-public (unstake (registry-trait <stake-registry-trait>) (pool-trait <stake-pool-trait>) (token-trait <ft-trait>) (amount uint))
    (let (
        (staker tx-sender)
        ;; Calculate new stake amount
        (new-stake-amount (- (var-get stake-amount) amount))
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

        ;; Unstake LP tokens
        (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 unstake registry-trait pool-trait token-trait amount)))

        ;; Transfer LP token from contract to user
        (try! (as-contract (contract-call? token-trait transfer amount tx-sender staker none)))

        ;; Update staker info
        (var-set stake-amount new-stake-amount)

        (ok amount)
    )
)

;; @desc withdraw ft to user wallet
(define-public (withdraw-ft (ft-trait <ft-trait>) (amount uint))
    (let (
        (staker tx-sender)
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

        ;; Transfer FT from contract to user
        (try! (as-contract (contract-call? ft-trait transfer amount tx-sender staker none)))

        (ok amount)
    )
)

(define-public (compound (registry-trait <stake-registry-trait>) (pool-trait <stake-pool-trait>) (token-trait <ft-trait>))
    (let (
        (staker tx-sender)
        ;; Claim pending reward for contract
        (reward (unwrap-panic (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 claim-pending-rewards registry-trait pool-trait))))
        (half-reward (/ reward u2))
        ;; Swap 50% DIKO to STX
        (amount-stx (unwrap-panic (element-at (unwrap-panic (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token half-reward u0))) u1)))
        ;; Swap 50% DIKO to USDA
        (amount-usda (unwrap-panic (element-at (unwrap-panic (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-multi-hop-swap-v1-1 swap-x-for-z 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token half-reward u0 false true))) u0)))
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

        ;; Add liquidity to pool
        (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda amount-stx amount-usda)))

        (let (
            (lp-balance (unwrap-panic (as-contract (contract-call? token-trait get-balance tx-sender))))
        )
            ;; Stake the new LP tokens
            (try! (stake registry-trait pool-trait token-trait lp-balance))
            (ok lp-balance)
        )
    )
)