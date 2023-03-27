(define-read-only (construct (arg1 principal))
(let
(
    (hasha (unwrap-panic (principal-destruct? arg1 )))
)
    (ok (unwrap-panic (principal-construct? 0x16 (get hash-bytes hasha))))
)
 )
(define-read-only (destruct (arg1 principal))
    (ok (unwrap-panic (principal-destruct? arg1 )))
 )