
;; math-fixed-point
;; Fixed Point Math
;; following https://github.com/balancer-labs/balancer-monorepo/blob/master/pkg/solidity-utils/contracts/math/FixedPoint.sol

;; constants
;;
(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places

;; With 8 fixed digits you would have a maximum error of 0.5 * 10^-8 in each entry, 
;; which could aggregate to about 8 x 0.5 * 10^-8 = 4 * 10^-8 relative error 
;; (i.e. the last digit of the result may be completely lost to this error).
(define-constant MAX_POW_RELATIVE_ERROR u4) 
(define-constant TOLERANCE_CONSTANT u10000)
;; public functions
;;

;; @desc get_one
;; @returns (response uint)
(define-read-only (get_one)
    (ok ONE_8)
)

;; @desc scale-up
;; @params a 
;; @returns uint
(define-read-only (scale-up (a uint))
    (* a ONE_8)
)

;; @desc scale-down
;; @params a 
;; @returns uint
(define-read-only (scale-down (a uint))
    (/ a ONE_8)
)

;; @desc mul-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; @desc mul-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (mul-up (a uint) (b uint))
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

;; @desc div-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (div-down (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (/ (* a ONE_8) b)
   )
)

;; @desc div-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (div-up (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (+ u1 (/ (- (* a ONE_8) u1) b))
    )
)

;; @desc pow-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (pow-down (a uint) (b uint))    
    (let
        (
            (raw (unwrap-panic (contract-call? .math-log-exp pow-fixed a b)))
            (max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
        )
        ;;(if (>= a ONE_8) (round-for-up raw TOLERANCE_CONSTANT)
            (if (< raw max-error)
                u0
                (- raw max-error)
            )
        ;;)
    )
)

;; @desc pow-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (pow-up (a uint) (b uint))
    (let
        (
            (raw (unwrap-panic (contract-call? .math-log-exp pow-fixed a b)))
            (max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
        )
        (+ raw max-error)
        ;;(if (>= a ONE_8)  (round-for-up raw TOLERANCE_CONSTANT) (+ raw max-error))
    )
)

;; TODO : Precision for 6 Decimals should be introduced later on. 
;; @desc round-for-up
;; @params a 
;; @params tolerance
;; @returns (response uint)
(define-read-only (round-for-up (a uint) (tolerance uint))
    (begin
    (if (is-eq (mod a tolerance) u0) (ok a)
        (let
            (
                (divided (/ a tolerance))
                (new-value (+ divided u1))
                (rounded (* new-value tolerance))
            )
        (ok rounded)
        )
    )
    )
)