;; Title: Minimal String Storage Contract

(define-data-var saved-message (optional (string-utf8 256)) none)

(define-public (set-message (message (string-utf8 256)))
  (begin
    (var-set saved-message (some message))
    (ok true)
  )
)

(define-read-only (get-message)
  (ok (var-get saved-message))
)
