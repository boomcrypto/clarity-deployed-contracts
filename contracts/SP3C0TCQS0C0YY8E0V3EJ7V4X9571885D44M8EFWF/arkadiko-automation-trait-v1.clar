(define-trait automation-trait
  (
    ;; initialize contract values
    (initialize () (response bool uint))

    ;; read-only function to check if job should be ran
    (check-job () (response bool bool))

    ;; public function that runs the job logic
    (run-job () (response bool uint))
  )
)
