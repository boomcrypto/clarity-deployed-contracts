
(define-constant INVALID-DIAMOND-COUNT (err "invalid diamond count"))

(define-public (check-diamond-count (count uint))
  (if (> count u0)
      (ok count)
      INVALID-DIAMOND-COUNT))
