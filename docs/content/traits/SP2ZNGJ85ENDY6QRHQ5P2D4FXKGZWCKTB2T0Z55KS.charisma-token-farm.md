---
title: "Trait charisma-token-farm"
draft: true
---
```
;; Function to check total balance over multiple blocks
(define-read-only (balance-check-multiple (data (list 200 { address: principal, block: uint })))
  (fold add-balance-for-block data u0)
)

;; Private function to add balance for a block to the total
(define-read-only (add-balance-for-block (data { address: principal, block: uint }) (prev-total uint))
    (+ prev-total (get-balance data))
)

(define-read-only (get-balance (data { address: principal, block: uint }))
    (let
        (
        (block-hash (unwrap-panic (get-block-info? id-header-hash (get block data))))
        )
        (at-block block-hash (unwrap-panic (contract-call? .charisma-token get-balance (get address data))))
    )
)

(define-read-only (generate-sample-points (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u8))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: (+ start-block block-step) }
            { address: address, block: (+ start-block (* block-step u2)) }
            { address: address, block: (+ start-block (* block-step u3)) }
            { address: address, block: (+ start-block (* block-step u4)) }
            { address: address, block: (+ start-block (* block-step u5)) }
            { address: address, block: (+ start-block (* block-step u6)) }
            { address: address, block: (+ start-block (* block-step u7)) }
            { address: address, block: end-block }
        )
    )
)

(define-read-only (calculate-trapezoid-areas (balances (list 9 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u4)) (unwrap-panic (element-at balances u5))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u5)) (unwrap-panic (element-at balances u6))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u6)) (unwrap-panic (element-at balances u7))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u7)) (unwrap-panic (element-at balances u8))) dx) u2)
    )
)

(define-read-only (calculate-balance-integral (address principal) (start-block uint) (end-block uint))
    (let
        (
            (sample-points (generate-sample-points address start-block end-block))
            (balances (map get-balance sample-points))
            (dx (/ (- end-block start-block) u8))
            (areas (calculate-trapezoid-areas balances dx))
        )
        (ok (fold + areas u0))
    )
)



```
