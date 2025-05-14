(define-read-only (principal-destruct (principal-value principal))
  (principal-destruct? principal-value)
)

(define-read-only (principal-construct (hash-bytes (buff 20)))
  (principal-construct? 0x16 hash-bytes)
)

(define-read-only (get-address-part (ascii-string (string-ascii 64)))
  (let
    (
      (delimiter-index (index-of? ascii-string "."))
    )
    (match delimiter-index
      index (unwrap-panic (slice? ascii-string u0 index))
      ascii-string)
  )
)

(define-read-only (get-name-part (ascii-string (string-ascii 64)))
  (let
    (
      (delimiter-index (index-of? ascii-string "."))
    )
    (match delimiter-index
      index (slice? ascii-string (+ index u1) (len ascii-string))
      none)
  )
)