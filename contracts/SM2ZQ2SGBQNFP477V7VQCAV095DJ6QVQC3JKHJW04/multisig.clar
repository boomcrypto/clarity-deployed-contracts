(define-map store (buff 32) (buff 32))

(define-public (get-value (key (buff 32)))
  (match (map-get? store key)
    entry (ok entry)
    (err 0)))

(define-public (set-value (key (buff 32)) (value (buff 32)))
  (begin
    (map-set store key value)
    (ok true)))
