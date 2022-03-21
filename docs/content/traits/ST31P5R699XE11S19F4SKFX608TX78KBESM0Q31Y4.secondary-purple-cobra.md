---
title: "Trait secondary-purple-cobra"
draft: true
---
```
;; sky-test-contract-001
;; This is a test

(define-public (say-hello-world)
    (begin
        (try! (stx-transfer? u1000 tx-sender (as-contract tx-sender)))
        (ok "Hello, World!")

    )
)
```
