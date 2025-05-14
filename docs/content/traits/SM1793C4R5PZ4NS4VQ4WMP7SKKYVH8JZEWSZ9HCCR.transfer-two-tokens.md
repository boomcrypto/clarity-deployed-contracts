---
title: "Trait transfer-two-tokens"
draft: true
---
```

;; transfer-two-tokens

(use-trait sip-010-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-public (transfer-two-tokens
    (token-a <sip-010-trait>)
    (token-a-amount uint)
    (token-a-memo (optional (buff 34)))
    (token-b <sip-010-trait>)
    (token-b-amount uint)
    (token-b-memo (optional (buff 34)))
    (recipient principal))
  (let (
    (transfer-a (contract-call? token-a transfer token-a-amount tx-sender recipient token-a-memo))
    (transfer-b (contract-call? token-b transfer token-b-amount tx-sender recipient token-b-memo))
  ) 
    (try! transfer-a)
    (try! transfer-b)
    (ok true)
  )
)
```
