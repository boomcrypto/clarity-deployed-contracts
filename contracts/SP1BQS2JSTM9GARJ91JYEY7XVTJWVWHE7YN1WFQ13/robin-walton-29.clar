(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidity-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)
(use-trait alex-sip-010-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait stackswap-sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait stackswap-liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)


;; constants
;;
(define-constant contract-owner tx-sender)

;; constants errors
;;
(define-constant ERR-NOT-OWNER (err u403))
(define-constant ERR-SWAP-ALEX-FAILED u7770)
(define-constant ERR-SWAP-ARKADIKO-FAILED u7771)
(define-constant ERR-SWAP-CRYPTOMATE-FAILED u7772)
(define-constant ERR-SWAP-STACKSWAP-FAILED u7773)
(define-constant ERR-BALANCE-LOWER u7773)

;; data maps and vars
;;

;; private functions
;;

(define-private (swap-alex
    (compare-token-decimals uint)
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (dx uint)
 )
    (let
        (
            (alex-token-decimal (unwrap-panic (contract-call? alex-token-x-trait get-decimals)))
            (y-amount (unwrap! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper alex-token-x-trait alex-token-y-trait (alex-number dx compare-token-decimals alex-token-decimal) none)) (err ERR-SWAP-ALEX-FAILED)))
            (y-amount-converted (alex-number y-amount alex-token-decimal compare-token-decimals))
        )
        (ok y-amount-converted)
    )
)

(define-private (swap-arkadiko
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (dx uint)
 )
    (let
        (
            (swapped-amounts (if arkadiko-inverse
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x arkadiko-token-x-trait arkadiko-token-y-trait dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y arkadiko-token-x-trait arkadiko-token-y-trait dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
            ))
            (y-amount (if arkadiko-inverse
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
            ))
        )
        (ok y-amount)
    )
)

(define-private (swap-cryptomate
    (cryptomate-token-x-trait <sip-010-token>)
    (cryptomate-token-y-trait <sip-010-token>)
    (cryptomate-token-liquidity-trait <liquidity-token>)
    (cryptomate-inverse bool)
    (dx uint)
 )
    (let
        (
            (swapped-amounts (if cryptomate-inverse
                (unwrap! (as-contract (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x cryptomate-token-x-trait cryptomate-token-y-trait cryptomate-token-liquidity-trait dx u0)) (err ERR-SWAP-CRYPTOMATE-FAILED))
                (unwrap! (as-contract (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y cryptomate-token-x-trait cryptomate-token-y-trait cryptomate-token-liquidity-trait dx u0)) (err ERR-SWAP-CRYPTOMATE-FAILED))
            ))
            (y-amount (if cryptomate-inverse
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
            ))
        )
        (ok y-amount)
    )
)

(define-private (swap-stackswap
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (dx uint)
 )
    (let
        (
            (swapped-amounts (if stackswap-inverse
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
            ))
            (y-amount (if stackswap-inverse
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
            ))
        )
        (ok y-amount)
    )
)

(define-read-only (alex-number
    (n uint)
    (b uint) 
    (a uint)
 )
    (/ (* n (pow u10 a)) (pow u10 b))
)

;; public functions
;;

(define-public (swap-alex-arkadiko
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? arkadiko-token-x-trait get-decimals)) alex-token-x-trait alex-token-y-trait dx)))
                (z-amount (unwrap-panic (swap-arkadiko arkadiko-token-x-trait arkadiko-token-y-trait arkadiko-inverse y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-alex-cryptomate
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (cryptomate-token-x-trait <sip-010-token>)
    (cryptomate-token-y-trait <sip-010-token>)
    (cryptomate-token-liquidity-trait <liquidity-token>)
    (cryptomate-inverse bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? cryptomate-token-x-trait get-decimals)) alex-token-x-trait alex-token-y-trait dx)))
                (z-amount (unwrap-panic (swap-cryptomate cryptomate-token-x-trait cryptomate-token-y-trait cryptomate-token-liquidity-trait cryptomate-inverse y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-alex-stackswap
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? stackswap-token-x-trait get-decimals)) alex-token-x-trait alex-token-y-trait dx)))
                (z-amount (unwrap-panic (swap-stackswap stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait stackswap-inverse y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-arkadiko-alex
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-arkadiko arkadiko-token-x-trait arkadiko-token-y-trait arkadiko-inverse dx)))
                (z-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? arkadiko-token-y-trait get-decimals)) alex-token-x-trait alex-token-y-trait y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-arkadiko-stackswap
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-arkadiko arkadiko-token-x-trait arkadiko-token-y-trait arkadiko-inverse dx)))
                (z-amount (unwrap-panic (swap-stackswap stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait stackswap-inverse y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)


(define-public (swap-stackswap-alex
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-stackswap stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait stackswap-inverse dx)))
                (z-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? stackswap-token-y-trait get-decimals)) alex-token-x-trait alex-token-y-trait y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-cryptomate-alex
    (cryptomate-token-x-trait <sip-010-token>)
    (cryptomate-token-y-trait <sip-010-token>)
    (cryptomate-token-liquidity-trait <liquidity-token>)
    (cryptomate-inverse bool)
    (alex-token-x-trait <alex-sip-010-token>)
    (alex-token-y-trait <alex-sip-010-token>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-cryptomate cryptomate-token-x-trait cryptomate-token-y-trait cryptomate-token-liquidity-trait cryptomate-inverse dx)))
                (z-amount (unwrap-panic (swap-alex (unwrap-panic (contract-call? cryptomate-token-y-trait get-decimals)) alex-token-x-trait alex-token-y-trait y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)

(define-public (swap-stackswap-arkadiko
    (stackswap-token-x-trait <stackswap-sip-010-token>)
    (stackswap-token-y-trait <stackswap-sip-010-token>)
    (stackswap-token-liquidity-trait <stackswap-liquidity-token>)
    (stackswap-inverse bool)
    (arkadiko-token-x-trait <sip-010-token>)
    (arkadiko-token-y-trait <sip-010-token>)
    (arkadiko-inverse bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (y-amount (unwrap-panic (swap-stackswap stackswap-token-x-trait stackswap-token-y-trait stackswap-token-liquidity-trait stackswap-inverse dx)))
                (z-amount (unwrap-panic (swap-arkadiko arkadiko-token-x-trait arkadiko-token-y-trait arkadiko-inverse y-amount)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? z-amount tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, y-amount: y-amount, z-amount: z-amount })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok z-amount)
        )
    )
)