
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

(define-constant ONE_8 u100000000) 




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
            (fromToken (unwrap! fromTokenAlex ERR_WRONG_FROM_TOKEN))
            (toToken (unwrap! toTokenAlex ERR_WRONG_TO_TOKEN))
            (dy (if (is-eq FIXED_WEIGHT poolId)
                    (if (is-eq SWAP_WSTX_FOR_Y swapFuncId)
                        (get dy (try! (handleSwapWstxForYFixed fromToken toToken weightX weightY dx minDy)))
                        (if (is-eq SWAP_Y_FOR_WSTX swapFuncId)
                            (get dx (try! (handleSwapYForWstxFixed fromToken toToken weightX weightY dx minDy)))
                            u0
                        )
                    )
                    (if (is-eq TRADING_POOL poolId)
                        (if (is-eq SWAP_X_FOR_Y swapFuncId)
                            (get dy (try! (handleSwapXForYTrading fromToken toToken factor dx minDy)))
                            (if (is-eq SWAP_Y_FOR_X swapFuncId)
                                (get dx (try! (handleSwapYForXTrading fromToken toToken factor dx minDy)))
                                u0
                            )
                        )
                        (if (is-eq SIMPLE_WEIGHT poolId)
                            (if (is-eq SWAP_ALEX_FOR_Y swapFuncId)
                                (get dy (try! (handleSwapAlexForYSimple fromToken toToken dx minDy)))
                                (if (is-eq SWAP_Y_FOR_ALEX swapFuncId)
                                    (get dx (try! (handleSwapYForAlexSimple fromToken toToken dx minDy)))
                                    u0
                                )
                            )
                            u0
                        )
                    )
                )
            )
        )
        (asserts! (> dy u0) ERR_SWAP_FAILED)
        (ok {dy: dy})
    )
)

(define-private (handleSwapAlexForYSimple (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>)  (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (alexTokenAddr 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token)
            (tokenY toToken)
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq alexTokenAddr fromTokenAddr) ERR_FROM_TOKEN_NOT_MATCH)
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex get-pool-exists alexTokenAddr tokenYAddr)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-alex-for-y tokenY dx minDy)
    )
)

(define-private (handleSwapYForAlexSimple (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>)  (dx uint) (minDy (optional uint))) 
    (let
        (
            (toTokenAddr (contract-of toToken))
            (alexTokenAddr 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token)
            (tokenY fromToken)
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq alexTokenAddr toTokenAddr) ERR_TO_TOKEN_NOT_MATCH)
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex get-pool-exists alexTokenAddr tokenYAddr)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-alex tokenY dx minDy)
    )
)

(define-private (handleSwapXForYTrading (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>) (factor uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (tokenX fromToken)
            (tokenY toToken)
            (tokenXAddr (contract-of tokenX))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-exists tokenXAddr tokenYAddr factor)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-x-for-y tokenX tokenY factor dx minDy)
    )
)

(define-private (handleSwapYForXTrading (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>) (factor uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (tokenX toToken)
            (tokenY fromToken)
            (tokenXAddr (contract-of tokenX))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-exists tokenXAddr tokenYAddr factor)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-y-for-x tokenX tokenY factor dx minDy)
    )
)




(define-private (handleSwapWstxForYFixed (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (wstxTokenAddr 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx)
            (tokenY toToken)
            (weightY weightTo)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        (asserts! (is-eq wstxTokenAddr fromTokenAddr) ERR_FROM_TOKEN_NOT_MATCH)
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 get-pool-exists wstxTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y tokenY weightY dx minDy)
    )
)

(define-private (handleSwapYForWstxFixed (fromToken <ft-trait-alex>) (toToken <ft-trait-alex>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (toTokenAddr (contract-of toToken))
            (wstxTokenAddr 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx)
            (tokenY fromToken)
            (weightY weightFrom)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        (asserts! (is-eq wstxTokenAddr toTokenAddr) ERR_TO_TOKEN_NOT_MATCH)
        (asserts! (is-some (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 get-pool-exists wstxTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx tokenY weightY dx minDy)
    )
)
