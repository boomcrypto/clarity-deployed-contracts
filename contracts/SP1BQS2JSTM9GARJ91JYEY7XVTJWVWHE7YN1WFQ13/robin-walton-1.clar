(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidity-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)

;; robin-walton
;; <add a description here>

;; constants
;;

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;
(define-public (swap-cryptomate-arkadiko (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (cryptomate-token-liquidity-trait <liquidity-token>) (cryptomate-dx uint) (cryptomate-min-dy uint) (arkadiko-dy uint) (arkadiko-min-dx uint))
    (begin
        (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y token-x-trait token-y-trait cryptomate-token-liquidity-trait cryptomate-dx cryptomate-min-dy))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x token-x-trait token-y-trait arkadiko-dy arkadiko-min-dx))
        (ok true)
    )
)

;; element-at
