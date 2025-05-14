(define-trait oracle-trait
  ((price
    (uint uint uint (buff 32) (buff 8192))
    ;; {
    ;;   identifier: (buff 32),
    ;;   message: (buff 8192),
    ;;   oracle: principal
    ;; })
    (response uint uint)))
)
