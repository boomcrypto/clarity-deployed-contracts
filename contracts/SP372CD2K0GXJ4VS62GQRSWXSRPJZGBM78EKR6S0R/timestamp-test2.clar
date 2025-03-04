
;; title: timestamp-test
;; version:
;; summary:
;; description:
(define-data-var last-timestamp uint u0)

(define-read-only (get-last-stacks-block-time-1 (amount-blocks-back uint) )
    (match (get-stacks-block-info? time (- stacks-block-height amount-blocks-back)) timestamp
        timestamp
        u0
    )
)

(define-read-only (get-stacks-block-time (blockheight uint) )
    (match (get-stacks-block-info? time blockheight) timestamp
        timestamp
        u0
    )
)

(define-public (set-last-stacks-blocktime)
    (ok (match (get-stacks-block-info? time (- stacks-block-height u10)) timestamp
        (var-set last-timestamp timestamp)
        false
    ))
)

(define-read-only (get-last-timestamp)
    (var-get last-timestamp)
)

(define-read-only (get-stacks-block-height)
    stacks-block-height
)

(define-read-only (get-burn-block-height)
    burn-block-height
)