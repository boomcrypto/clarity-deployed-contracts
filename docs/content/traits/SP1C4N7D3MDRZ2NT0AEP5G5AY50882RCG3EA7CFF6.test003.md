---
title: "Trait test003"
draft: true
---
```
(define-public (transfer-stx (recipient principal) (amount uint))
  (begin
    (let ((transfer-result (stx-transfer? amount tx-sender recipient)))
      (if (is-ok transfer-result)
        (ok (tuple (status "success") (transferred-amount amount)))
        (err (tuple (status "failure") (error transfer-result))
        )
      )
    )
  )
)
```
