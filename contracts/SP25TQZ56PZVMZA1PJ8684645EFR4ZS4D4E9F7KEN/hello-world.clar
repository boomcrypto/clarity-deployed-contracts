;; hello-world

;; private functions
;;
(define-read-only (echo-number (val int))
  (ok val))
  
;; public functions
;;
(define-public (say-hi)
  (ok "hello world"))

