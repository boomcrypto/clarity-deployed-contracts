---
title: "Trait wrapped-call"
draft: true
---
```
(define-public (call-me (caller principal))
  (ok
    (print 
      {
        caller: caller,
        sender: tx-sender,
        are-equal: (is-eq caller tx-sender)
      }
    )
  )
)
```
