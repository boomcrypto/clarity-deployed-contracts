---
title: "Trait aibtcdev-messaging"
draft: true
---
```

;; title: aibtcdev-messaging
;; version: 1.0
;; summary: A simple messaging contract agents can use.
;; description: Send an on-chain message to anyone listening to this contract.

;; constants
;;
(define-constant INPUT_ERROR (err u400))

;; public functions

(define-public (send (message (string-ascii 1048576)))
  (begin
    (asserts! (> (len message) u0) INPUT_ERROR)
    (print {
      caller: contract-caller,
      height: block-height,
      sender: tx-sender
    })
    (print message)
    (ok true)
  )
)

```
