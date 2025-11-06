(define-read-only (get-name-at-block (block uint) (name (buff 48)) (namespace (buff 20)))
    (at-block 
        (unwrap-panic (get-burn-block-info? header-hash block) )
        (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace)
    )
)

(define-read-only (get-name-at-block-stacks-v1 (block uint) (name (buff 48)) (namespace (buff 20)))
    (at-block 
        (unwrap-panic (get-stacks-block-info? id-header-hash block) )
        (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace)
    )
)

(define-read-only (get-name-at-block-stacks-v2 (block uint) (name (buff 48)) (namespace (buff 20)))
    (at-block 
        (unwrap-panic (get-stacks-block-info? header-hash block) )
        (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace)
    )
)

(define-read-only (get-burn-block-height)
    burn-block-height
)

(define-read-only (get-burn-block-height-custom (block uint))
    (at-block  (unwrap-panic (get-stacks-block-info? id-header-hash block) ) burn-block-height)
)