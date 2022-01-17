(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-trait flash-loan-user-trait
  (
    ;; no need for params, as whoever implements this trait should know what he/she is doing
    ;; see test-flash-loan-user
    ;; (execute (<ft-trait> uint) (response bool uint) (optional (string-utf8 256)))
    (execute (<ft-trait> uint (optional (buff 16))) (response bool uint))
  )
)