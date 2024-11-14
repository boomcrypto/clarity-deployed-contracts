---
title: "Trait meta-bridge-registry-v2-01-read-helper"
draft: true
---
```
(define-read-only (get-pair-details (pair { tick: (string-utf8 256), token: principal }))
  (let ((resp-token-details (contract-call? .meta-bridge-registry-v2-01
                              get-pair-details-or-fail
                              pair)))
    (match resp-token-details
      details (some details)
      e none)))
(define-read-only (get-pair-details-many (pairs (list 100  { tick: (string-utf8 256), token: principal })))
  (map get-pair-details pairs))
```
