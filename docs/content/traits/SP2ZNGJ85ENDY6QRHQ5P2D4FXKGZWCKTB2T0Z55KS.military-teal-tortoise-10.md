---
title: "Trait military-teal-tortoise-10"
draft: true
---
```
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

(define-read-only (extract-amount-from-opcode (opcode (string-ascii 64)))
  (let
    (
      (prefix "TRANSFER_")
      (prefix-len (len prefix))
      ;; Check if opcode starts with expected prefix
      (valid-prefix (is-eq (slice? opcode u0 prefix-len) (some prefix)))
      ;; Extract the amount part (everything after the prefix)
      (amount-str (if valid-prefix
                   (slice? opcode prefix-len (len opcode))
                   none))
    )
    ;; Return the amount part or none if invalid format
    (if valid-prefix amount-str none)
  )
)

(define-read-only (to-consensus-buff (string (string-ascii 64)))
  (to-consensus-buff? string)
)
```
