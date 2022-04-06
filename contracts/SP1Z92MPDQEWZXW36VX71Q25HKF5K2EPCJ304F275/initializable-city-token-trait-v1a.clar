;; trait from project one-click-token


(define-trait initializable-city-token-trait
  (
    (initialize ((string-ascii 32) (string-ascii 32) uint (string-utf8 256) (string-utf8 256) uint uint uint uint uint uint uint ) (response uint uint))
    (set-token-uri ((string-utf8 256)) (response bool uint))
    (approve (bool) (response bool uint))
  )
)

