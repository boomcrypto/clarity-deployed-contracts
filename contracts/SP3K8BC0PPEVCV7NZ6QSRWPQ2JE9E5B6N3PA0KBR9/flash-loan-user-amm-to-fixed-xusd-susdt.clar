(impl-trait .trait-flash-loan-user.flash-loan-user-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-ARB-EXISTS (err u9000))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))
(define-public (execute (token <ft-trait>) (amount uint) (memo (optional (buff 16))))
    (let
        (   
            (swapped (try! (contract-call? .amm-swap-pool-v1-1 swap-helper .token-wxusd .token-susdt u5000000 amount none)))   
            (swapped-back (try! (contract-call? .swap-helper-bridged-v1-1 swap-helper-to-amm .token-susdt .token-wstx .token-wxusd ONE_8 swapped none)))                                                
            (amount-with-fee (mul-up amount (+ ONE_8 (contract-call? .alex-vault-v1-1 get-flash-loan-fee-rate))))
        )
        (ok (asserts! (>= swapped-back amount-with-fee) ERR-NO-ARB-EXISTS))
    )
)
(define-private (mul-up (a uint) (b uint))
    (let
        (
            (product (* a b))
       )
        (if (is-eq product u0)
            u0
            (+ u1 (/ (- product u1) ONE_8))
       )
   )
)