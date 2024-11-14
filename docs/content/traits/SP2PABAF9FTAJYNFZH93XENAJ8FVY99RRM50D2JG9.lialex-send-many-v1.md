---
title: "Trait lialex-send-many-v1"
draft: true
---
```
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))
(define-private (transfer-from-tuple (details { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 transfer (get amount details) tx-sender (get to details) (get memo details)))
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34))})))
  (fold check-err (map transfer-from-tuple recipients) (ok true)))
```
