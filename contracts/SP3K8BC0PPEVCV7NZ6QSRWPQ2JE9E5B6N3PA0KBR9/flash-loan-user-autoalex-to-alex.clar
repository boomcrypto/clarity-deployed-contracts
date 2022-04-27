(impl-trait .trait-flash-loan-user.flash-loan-user-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000)
(define-constant ERR-NO-ARB-EXISTS (err u9000))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))

;; @desc execute
;; @params collateral
;; @params amount
;; @params memo ; expiry
;; @returns (response boolean)
(define-public (execute (token <ft-trait>) (amount uint) (memo (optional (buff 16))))
    (let
        (   
            (add-to-position (try! (contract-call? .auto-alex add-to-position amount)))
            (minted (unwrap! (contract-call? .auto-alex get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
            (swapped (try! (contract-call? .swap-helper-v1-01 swap-helper .auto-alex .age000-governance-token minted none)))
            (amount-with-fee (mul-up amount (+ ONE_8 (unwrap-panic (contract-call? .alex-vault get-flash-loan-fee-rate)))))
        )
        (ok (asserts! (>= swapped amount-with-fee) ERR-NO-ARB-EXISTS))
    )
)

;; @desc mul-up
;; @params a
;; @params b
;; @returns uint
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