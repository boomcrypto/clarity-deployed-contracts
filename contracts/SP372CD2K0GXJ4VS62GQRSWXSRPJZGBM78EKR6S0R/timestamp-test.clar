
;; title: timestamp-test
;; version:
;; summary:
;; description:
(define-data-var last-timestamp uint u0)

(define-read-only (get-last-stacks-block-time )
    (match (get-stacks-block-info? time stacks-block-height) timestamp
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
    (ok (match (get-stacks-block-info? time stacks-block-height) timestamp
        (var-set last-timestamp timestamp)
        false
    ))
)

(define-read-only (get-last-timestamp)
    (var-get last-timestamp)
)