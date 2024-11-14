---
title: "Trait ctf-test-1"
draft: true
---
```
;; Wrapper for balance-check-multiple
(define-public (test-balance-check-multiple (data (list 200 { address: principal, block: uint })))
  (ok (contract-call? .charisma-token-farm balance-check-multiple data))
)

;; Wrapper for add-balance-for-block
(define-public (test-add-balance-for-block (data { address: principal, block: uint }) (prev-total uint))
  (ok (contract-call? .charisma-token-farm add-balance-for-block data prev-total))
)

;; Wrapper for get-balance
(define-public (test-get-balance (data { address: principal, block: uint }))
  (ok (contract-call? .charisma-token-farm get-balance data))
)

;; Wrapper for generate-sample-points
(define-public (test-generate-sample-points (address principal) (start-block uint) (end-block uint))
  (ok (contract-call? .charisma-token-farm generate-sample-points address start-block end-block))
)

;; Wrapper for calculate-trapezoid-areas
(define-public (test-calculate-trapezoid-areas (balances (list 9 uint)) (dx uint))
  (ok (contract-call? .charisma-token-farm calculate-trapezoid-areas balances dx))
)

;; Wrapper for calculate-balance-integral
(define-public (test-calculate-balance-integral (address principal) (start-block uint) (end-block uint))
  (contract-call? .charisma-token-farm calculate-balance-integral address start-block end-block)
)

```
