(define-trait paradigma-token-trait
  (
    ;; mint token functionality
    (mint (uint principal) (response bool uint))

    ;; burn token functionality
    (burn (uint principal) (response bool uint))
  )
)