---
title: "Trait pool-proposal-the-fellowship-of-the-meme"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? .lands set-whitelisted 'SP3SMQNVWRBVWC81SRJYFV4X1ZQ7AWWJFBQJMC724.fam true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? .lands get-or-create-land-id 'SP3SMQNVWRBVWC81SRJYFV4X1ZQ7AWWJFBQJMC724.fam)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP3SMQNVWRBVWC81SRJYFV4X1ZQ7AWWJFBQJMC724.fam get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u6)))
      )
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? .lands set-land-difficulty land-id land-difficulty)
    )
  )
)

```
