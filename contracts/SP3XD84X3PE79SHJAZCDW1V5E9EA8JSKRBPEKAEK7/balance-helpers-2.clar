
(define-read-only (get-balance (a principal)) (stx-get-balance a))

(define-read-only (get-balance-at-block (a principal) (b uint)) (at-block (unwrap-panic (get-block-info? id-header-hash b)) (stx-get-balance a)))

