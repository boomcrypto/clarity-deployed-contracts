---
title: "Trait derupt-stackers"
draft: true
---
```
;; .derupt-stackers Contract
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Stack
(define-public (log-stack (stacker principal) (dislike-ft-total uint) (lockPeriod uint))
  (let
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "stack", stacker: stacker, dislike-ft-total: dislike-ft-total, lockPeriod: lockPeriod })
    (ok true)
  )
)

;; Log Stacking Reward Claim
(define-public (log-stacking-reward-claim (targetCycles (list 32 uint)))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "stacking-reward-claim", stacker: tx-sender, targetCycles: targetCycles })
    (ok true)
  )
)
```
