(use-trait registry-trait .registry-trait-vpv-5.registry-trait)

(define-trait oracle-trait
  (
    (get-source () (response uint uint))
    (set-source (uint) (response bool uint))
    (get-price (<registry-trait>) (response uint uint))
  )
) 