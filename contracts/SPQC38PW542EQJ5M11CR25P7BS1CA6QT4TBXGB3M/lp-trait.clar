;; lp-trait
(use-trait sip-010 .sip-010-trait-ft-standard.sip-010-trait)

(define-trait lp-trait
  (
    ;; SIP10
    (adheres-to-sip-010 () (response bool uint))

    ;; Mint
    (mint (principal uint) (response bool uint))

    ;; Burn
    (burn (principal uint) (response bool uint))
  )
)