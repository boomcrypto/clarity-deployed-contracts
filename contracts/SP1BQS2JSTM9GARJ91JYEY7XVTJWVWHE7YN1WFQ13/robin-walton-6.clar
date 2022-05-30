(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidity-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)

;; constants
;;
(define-constant ERR-SWAP-ONE-FAILED u7771)
(define-constant ERR-SWAP-TWO-FAILED u7772)
(define-constant ERR-BALANCE-LOWER u7773)

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;
(define-public (swap-cryptomate-arkadiko
    (cryptomate-token-x-trait <sip-010-token>)
    (cryptomate-token-y-trait <sip-010-token>)
    (cryptomate-token-liquidity-trait <liquidity-token>)
    (cryptomate-dx uint)
    (cryptomate-min-dy uint)
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-dy uint)
    (arkadiko-min-dx uint)
)
    (begin
        ;; TODO Save balance before trade
        (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y cryptomate-token-x-trait cryptomate-token-y-trait cryptomate-token-liquidity-trait cryptomate-dx cryptomate-min-dy))
        (print { message: "cryptomate-swap", cryptomate-dx: cryptomate-dx, cryptomate-min-dy: cryptomate-min-dy })
        (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x arkadiko-token-x-trait arkadiko-token-y-trait arkadiko-dy arkadiko-min-dx))
        ;; TODO Get balance after trade and revert is balance before is > as after trade
        (ok true)
    )
)

(define-public (swap-arkadiko-stackswap
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (stackswap-token-x-trait <sip-010-token>)
    (stackswap-token-y-trait <sip-010-token>)
    (stackswap-inverse bool)
    (dx uint)
    (min-dx uint)
)
    (let (
        (balance-before (stx-get-balance (as-contract tx-sender)))
        (swapped-amounts (if arkadiko-inverse
            (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x arkadiko-token-x-trait arkadiko-token-y-trait dx u0) (err ERR-SWAP-ONE-FAILED))
            (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y arkadiko-token-x-trait arkadiko-token-y-trait dx u0) (err ERR-SWAP-ONE-FAILED))
        ))
        (y-amount (if arkadiko-inverse
            (unwrap-panic (element-at swapped-amounts u0))
            (unwrap-panic (element-at swapped-amounts u1))
        ))
        (swapped-amounts-2 (if stackswap-inverse
            (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x stackswap-token-x-trait stackswap-token-y-trait y-amount min-dx) (err ERR-SWAP-TWO-FAILED))
            (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y stackswap-token-x-trait stackswap-token-y-trait y-amount min-dx) (err ERR-SWAP-TWO-FAILED))
        ))
        (z-amount (if stackswap-inverse
            (unwrap-panic (element-at swapped-amounts-2 u0))
            (unwrap-panic (element-at swapped-amounts-2 u1))
        ))
  )
    ;; Get balance after trade and revert is balance before is > as after trade
    (asserts! (> balance-before (stx-get-balance (as-contract tx-sender))) (err ERR-BALANCE-LOWER))
    (ok swapped-amounts-2)
  )
)
