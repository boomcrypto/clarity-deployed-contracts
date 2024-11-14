;; Simple Hello World contract

;; Declare a constant that represents the greeting message
(define-constant hello-message "Hello, World!")

;; Define a public function that returns the greeting message
(define-public (say-hello)
  (ok hello-message)
)
