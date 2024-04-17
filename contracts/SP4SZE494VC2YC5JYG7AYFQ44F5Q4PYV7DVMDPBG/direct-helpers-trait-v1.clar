;; @contract Direct STacking Helpers Trait
;; @version 1

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

(define-trait direct-helpers-trait
  (
    (add-direct-stacking (principal (optional principal) uint) (response bool uint))
    (subtract-direct-stacking (principal uint) (response bool uint))
    (stop-direct-stacking (principal) (response bool uint))
  )
)
