(use-trait registry-trait .registry-trait-vpv-17.registry-trait)

(define-trait oracle-trait
  (
    (get-price ((optional (buff 8192)) <registry-trait>) (response uint uint))
  )
) 