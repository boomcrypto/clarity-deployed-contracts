;; @contract Treasury Trait
;; @version 1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait value-calculator-trait .value-calculator-trait-v1-1.value-calculator-trait)

(define-trait treasury-trait
  (
    ;; mint LDN
    (mint (principal uint) (response bool uint))

    ;; audit reserve token
    (audit-reserve-token (<ft-trait> <value-calculator-trait>) (response uint uint))

    ;; returns valuation of asset
    (get-token-value (<ft-trait> <value-calculator-trait> uint) (response uint uint))

    ;; excess reserves
    (get-excess-reserves () (response uint uint))

    ;; deposit
    (deposit (<ft-trait> <value-calculator-trait> uint uint) (response uint uint))

    ;; withdraw
    (withdraw (<ft-trait> <value-calculator-trait> uint) (response uint uint))

    ;; incur debt
    (incur-debt (<ft-trait> <value-calculator-trait> uint) (response uint uint))

    ;; repay debt
    (repay-debt (<ft-trait> <value-calculator-trait> uint) (response uint uint))

  )
)
