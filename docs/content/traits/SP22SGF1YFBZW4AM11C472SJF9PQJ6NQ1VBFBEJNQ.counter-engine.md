---
title: "Trait counter-engine"
draft: true
---
```
;; An on-chain counter that stores a count for each individual

;; Define a map data structure
(define-map individual-count principal uint)

(define-data-var global-count int 0)

;; Function to retrieve the count for a given individual
(define-read-only (get-count (who principal))
  (default-to u0 (map-get? individual-count who))
)

(define-read-only (get-global-count)
    (var-get global-count)
)

;; Function to increment the count for the caller
(define-public (count-up)
    (begin
        (var-set global-count (+ (var-get global-count) 1))
        (map-set individual-count tx-sender (+ (get-count tx-sender) u1))
        (contract-call? .count-token safe-mint)
    )
)

(define-public (count-down)
    (begin
        (var-set global-count (- (var-get global-count) 1))
        (map-set individual-count tx-sender (- (get-count tx-sender) u1))
        (contract-call? .count-token safe-mint)
    )
)

```
