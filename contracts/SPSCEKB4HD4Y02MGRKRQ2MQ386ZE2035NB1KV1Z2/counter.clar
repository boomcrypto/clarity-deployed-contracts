(define-map Counters principal uint)

(define-public (count-twice)
  (double)
)

(define-private (double)
  (begin
    (unwrap-panic (count-up))
    (count-up)
  )
)

(define-public (count-up)
  (ok (map-set Counters tx-sender (+ (get-count tx-sender) u1)))
)

(define-read-only (get-count (who principal))
  (default-to u0 (map-get? Counters who))
)