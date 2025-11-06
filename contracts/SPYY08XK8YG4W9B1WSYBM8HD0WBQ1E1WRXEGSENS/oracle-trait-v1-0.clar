(use-trait registry-trait .registry-trait-v1-0.registry-trait)

(define-trait oracle-trait
  (
    (get-price ((optional (buff 8192)) <registry-trait>) (response uint uint))
  )
) 