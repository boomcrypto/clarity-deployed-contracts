(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)


(define-trait DispatcherInterface 
    (
        (swap    
            ;; ({poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint,factor uint, dx: uint, minDy: (optional uint)})
            (uint uint (optional <ft-trait>) (optional <ft-trait>) (optional <ft-trait-alex>) (optional <ft-trait-alex>) (optional <liquidity-token>) uint uint uint uint (optional uint))
            (response {dy: uint} uint)
        )
    )
)
