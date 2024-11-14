---
title: "Trait meta-bridge-registry-v2-02-read-helper"
draft: true
---
```
(define-read-only (get-pair-details (pair { token: principal, chain-id: uint }))
  (let ((details? (contract-call? .meta-bridge-registry-v2-02
                    get-pair-details-or-fail
                    pair)))
    (match details?
      details (some details)
      e none)))

(define-read-only (get-pair-details-many (pairs (list 100  { token: principal, chain-id: uint })))
  (map get-pair-details pairs))

(define-read-only (get-tick-details (tick (string-utf8 256)))
  (let ((pair? (contract-call? .meta-bridge-registry-v2-02
                 get-tick-to-pair-or-fail
                 tick)))
    (match pair?
      pair (get-pair-details pair)
      e none)))

(define-read-only (get-tick-details-many (ticks (list 100 (string-utf8 256))))
  (map get-tick-details ticks))

```
