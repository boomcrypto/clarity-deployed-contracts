(define-read-only (lookup (array (list 5000 uint)) (uid uint))
    (let (
        (listed (list 
                (list  array)
                (list  array array)
                (list  array array array)))
    )
    (unwrap-panic (element-at listed uid))
    )
)