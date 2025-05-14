---
title: "Trait cuddly-bronze-gazelle"
draft: true
---
```

(define-read-only (get-holders-at (owner principal))
    ;; (at-block
    ;;   (unwrap-panic
    ;;     (get-block-info?
    ;;       id-header-hash
    ;;       stacks-block-height
    ;;     )
    ;;   )
        (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 get-balance owner)
    ;; )
)
```
