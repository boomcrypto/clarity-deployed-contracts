(define-trait flash-loan
  (
    ;; Callback function once the request amount is transferred to contract-caller
    (on-granite-flash-loan (uint uint (optional (buff 10240))) (response bool uint))
  )
)
