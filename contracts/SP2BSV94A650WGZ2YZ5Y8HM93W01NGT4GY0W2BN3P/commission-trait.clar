(define-trait commission-trait
  (
    (send-funds () (response bool uint))

    (pay (uint principal) (response bool uint))
  )
)