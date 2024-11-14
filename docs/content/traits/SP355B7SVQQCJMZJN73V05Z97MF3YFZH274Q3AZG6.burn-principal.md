---
title: "Trait burn-principal"
draft: true
---
```
(define-read-only (generate-burn-standard-principal (entropyString (string-utf8 1000)))
  (let
    (
      (withAddedEntropy (concat (unwrap-panic (to-consensus-buff? entropyString)) (unwrap-panic (to-consensus-buff? stacks-block-height))))
      (hash (hash160 withAddedEntropy))
    )
    (principal-construct? 0x16 hash)
  )
)
```
