(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)
(impl-trait .swap-helper-trait.swap-helper-trait)

(define-constant contract-owner tx-sender)

;; private functions
;;
(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)
;; Dummy implementation to simulate swap.
;; Receive all the token-x and send back 1/4 amount in token y
(define-public (swap-helper (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
    (begin 
        (try! (transfer-ft token-x-trait dx tx-sender (as-contract tx-sender)))
        (let (
             (return-amount (/ dx u4))   ;; lets assume a 1 to 4 ratio
             (recipient tx-sender)
             ) 
             (try! (as-contract (transfer-ft token-y-trait return-amount tx-sender recipient)))
             (ok return-amount)
        )
    )
)
