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

(define-read-only (ascii-to-principal (ascii-string (string-ascii 64)))
  (let
    (
      ;; Extract the address and name parts
      (address-part (get-address-part ascii-string))
      (name-part (get-name-part ascii-string))
      
      ;; Convert address string to buffer and unwrap directly
      (address-buffer (unwrap-panic (to-consensus-buff? address-part)))
    )
    ;; Construct the principal based on whether we have a name part
    address-buffer
    ;; (if (is-some name-part)
    ;;   ;; If name part exists, create a contract principal
    ;;   (principal-construct? 0x16 address-buffer (unwrap-panic name-part))
    ;;   ;; Otherwise create a standard principal
    ;;   (principal-construct address-buffer)
    ;; )
  )
)