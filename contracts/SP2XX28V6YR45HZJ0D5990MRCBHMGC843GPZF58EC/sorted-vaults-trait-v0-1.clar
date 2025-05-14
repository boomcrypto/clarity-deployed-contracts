(define-trait vaults-trait
  (
    
    (insert (uint uint (optional uint)) (response (tuple 
      (first-vault-id (optional uint)) 
      (last-vault-id (optional uint))
      (total-vaults uint)
    ) uint))

    (reinsert (uint uint (optional uint)) (response (tuple 
      (first-vault-id (optional uint)) 
      (last-vault-id (optional uint))
      (total-vaults uint)
    ) uint))

    (remove (uint) (response (tuple 
      (first-vault-id (optional uint)) 
      (last-vault-id (optional uint))
      (total-vaults uint)
    ) uint))
  )
)