(impl-trait .test-trait-2.test-trait)

(define-map test-map principal { 
    user: principal,
    created-height: uint
})

(define-public (set-map) 
    (ok (map-set test-map 
        tx-sender 
        { 
            user: tx-sender, 
            created-height: block-height 
        }
    ))
)
(define-read-only (read-map)
    (ok (default-to { user: tx-sender, created-height: block-height } (map-get? test-map tx-sender)))
)