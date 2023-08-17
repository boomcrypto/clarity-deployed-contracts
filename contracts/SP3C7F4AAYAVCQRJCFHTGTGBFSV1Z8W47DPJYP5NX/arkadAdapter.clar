(impl-trait .dispatcherTrait.DispatcherInterface)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_FROM_TOKEN_NOT_MATCH (err u9001))
(define-constant ERR_POOL_NOT_EXISTS (err u9002))
(define-constant ERR_TO_TOKEN_NOT_MATCH (err u9003))
(define-constant ERR_WEIGHT_SUM (err u9004))
(define-constant ERR_SWAP_FAILED (err u9005))
(define-constant ERR_WRONG_FROM_TOKEN (err u9006))
(define-constant ERR_WRONG_TO_TOKEN (err u9007))
(define-constant ERR_WRONG_LP_TOKEN (err u9008))

(define-constant ONE_8 u100000000) ;; 8 decimal places




(define-constant SWAP_ALEX_FOR_Y u1000001)
(define-constant SWAP_Y_FOR_ALEX u1000002)
(define-constant SWAP_WSTX_FOR_Y u1000003)
(define-constant SWAP_Y_FOR_WSTX u1000004)

(define-constant SWAP_X_FOR_Y    u1000005)
(define-constant SWAP_Y_FOR_X    u1000006)

(define-constant FIXED_WEIGHT u2000001)
(define-constant STABLE_POOL u2000002)
(define-constant TRADING_POOL u2000003)
(define-constant SIMPLE_WEIGHT u2000004)

(define-public (swap (poolId uint) (swapFuncId uint) (fromTokenNormal (optional <ft-trait>)) (toTokenNormal (optional <ft-trait>)) (fromTokenAlex (optional <ft-trait-alex>)) (toTokenAlex (optional <ft-trait-alex>)) (lpToken (optional <liquidity-token>)) (weightX uint) (weightY uint) (factor uint) (dx uint) (minDy (optional uint))) 
    (let 
        (
            (fromToken (unwrap! fromTokenNormal ERR_WRONG_FROM_TOKEN))
            (toToken (unwrap! toTokenNormal ERR_WRONG_TO_TOKEN))
            (dy (if (is-eq SWAP_X_FOR_Y swapFuncId)
                (element-at (try! (handleSwapXForY fromToken toToken dx (default-to u0 minDy))) u1) ;;dy
                (if (is-eq SWAP_Y_FOR_X swapFuncId)
                    (element-at (try! (handleSwapYForX fromToken toToken dx (default-to u0 minDy))) u0) ;;dx
                    none
                )
            ))
        ) 
        (unwrap! dy ERR_SWAP_FAILED)
        (ok {dy: (default-to u0 dy)})
    )
)


(define-private (handleSwapXForY (fromToken <ft-trait>) (toToken <ft-trait>) (dx uint) (minDy uint))
    (let
        (
            (tokenX fromToken)
            (tokenY toToken)
            (tokenXAddr (contract-of tokenX))
            (tokenYAddr (contract-of tokenY))
        )
        ;; check pool exists
        (asserts! (is-ok (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details tokenXAddr tokenYAddr)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y tokenX tokenY dx minDy)
    )
)

(define-private (handleSwapYForX (fromToken <ft-trait>) (toToken <ft-trait>) (dx uint) (minDy uint))
    (let
        (
            (tokenX toToken)
            (tokenY fromToken)
            (tokenXAddr (contract-of tokenX))
            (tokenYAddr (contract-of tokenY))
        )
        ;; check pool exists
        (asserts! (is-ok (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details tokenXAddr tokenYAddr)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x tokenX tokenY dx minDy)
    )
)
