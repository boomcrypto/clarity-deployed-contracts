;; @contract Value Calculator Trait
;; @version 1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-trait value-calculator-trait
  (

    ;; valuation of token amount
    (get-valuation (<ft-trait> uint) (response uint uint))

    ;; valuation of single token amount
    (get-valuation-single (<ft-trait> uint) (response uint uint))

    ;; valuation of lp token amount
    (get-valuation-lp (<ft-trait> uint) (response uint uint))
  )
)
