(define-trait dao-token-trait
  (
    (mint-for-dao (uint principal) (response bool uint))

    (burn-for-dao (uint principal) (response bool uint))
  )
)