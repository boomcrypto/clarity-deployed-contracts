(define-trait nft-approvable-trait
  (
     ;; Sets or unsets a user or contract principal who is allowed to call transfer
    (set-approval-for (uint principal) (response bool uint))

     ;; Sets or unsets a user or contract principal who is allowed to call transfer
    (get-approval (uint) (response (optional principal) uint))
  )
)
