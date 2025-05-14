---
title: "Trait block-time-test2"
draft: true
---
```

;; title: block-time-test
;; version:
;; summary:
;; description:



(define-read-only (get-last-stacks-block-time )
    (match (get-block-info? time block-height) timestamp
        timestamp
        u0
    )
)

(define-read-only (get-stacks-block-time (blockheight uint) )
    (match (get-block-info? time blockheight) timestamp
        timestamp
        u0
    )
)

```
