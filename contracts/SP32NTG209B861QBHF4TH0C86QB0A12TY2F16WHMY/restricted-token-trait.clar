(define-trait restricted-token-trait
  (
    (detect-transfer-restriction (uint principal principal) (response uint uint))
    (message-for-restriction (uint) (response (string-ascii 1024) uint))
  )
)
