;; A read-only function that returns a message
(define-read-only (say-hi)
  (ok "Hello World")
)

;; A read-only function that returns an input number
(define-read-only (echo-number (val int))
  (ok val)
)

;; A public function that conditionally returns an ok or an error
(define-public (check-it (flag bool))
  (if flag (ok 1) (err u100))
)
