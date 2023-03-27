(define-read-only (construct (arg1 (buff 1)) (arg2 (buff 20)))
 (begin
    (print arg1)
    (print arg2)
    (ok (unwrap-panic (principal-construct? arg1 arg2)))

  )
 )
(define-read-only (destruct (arg1 principal))
 (begin
    (print arg1)
    (ok (unwrap-panic (principal-destruct? arg1 )))
  )
 )