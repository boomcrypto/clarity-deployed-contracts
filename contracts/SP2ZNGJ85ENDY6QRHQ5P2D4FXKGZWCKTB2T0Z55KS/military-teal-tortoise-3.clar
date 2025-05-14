(define-read-only (principal-destruct (principal-value principal))
  (principal-destruct? principal-value)
)

(define-read-only (principal-construct (hash-bytes (buff 20)))
  (principal-construct? 0x16 hash-bytes)
)