---
title: "Trait military-teal-tortoise-4"
draft: true
---
```
(define-read-only (principal-destruct (principal-value principal))
  (principal-destruct? principal-value)
)

(define-read-only (principal-construct (hash-bytes (buff 20)))
  (principal-construct? 0x16 hash-bytes)
)

(define-read-only (find-dot-index (ascii-string (string-ascii 64)))
  (let
    (
      (delimiter-index (index-of? ascii-string "."))
    )
    delimiter-index
  )
)
```
