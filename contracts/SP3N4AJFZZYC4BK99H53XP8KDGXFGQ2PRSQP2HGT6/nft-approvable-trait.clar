(define-trait nft-approvable-trait
  (
     ;; Sets or unsets a user or contract principal who is allowed to call transfer
    (set-approved (principal uint bool) (response bool uint))
  )
)
