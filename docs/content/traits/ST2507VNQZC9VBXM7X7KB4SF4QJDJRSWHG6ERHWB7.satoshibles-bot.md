---
title: "Trait satoshibles-bot"
draft: true
---
```
(define-map id-map principal (string-ascii 99))

(define-public (set-id (id (string-ascii 99)))
    (ok (map-set id-map tx-sender id))
)

(define-read-only (get-id (account principal))
    (default-to ""
        (map-get? id-map account)
    )
)
```
