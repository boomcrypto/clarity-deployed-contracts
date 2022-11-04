;; TRICK OR TREAT

(impl-trait .halloween.trick-or-treat)

(define-read-only (slice (n int))
  (if (> n 0)
    (ok "Apple Slice")
    (err u0)))

(define-read-only (spice (n int))
  (if (> n 0)
    (ok "Black Pepper")
    (err u0)))

;;
