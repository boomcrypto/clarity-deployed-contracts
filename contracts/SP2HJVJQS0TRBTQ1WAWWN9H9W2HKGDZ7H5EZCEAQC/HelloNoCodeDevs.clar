;; For The NoCodeDevs | A Simple Contract
;; Cultivated By Christopher Perceptions 

;; Data variable to store the greeting message
(define-data-var greeting (string-ascii 50) "Hello NoCodeDevs!")

;; Read-Only Function: Get the current greeting
(define-read-only (get-greeting)
  (ok (var-get greeting)))

;; Public Function: Update the greeting message
(define-public (set-greeting (new-greeting (string-ascii 50)))
  (if (is-eq new-greeting "")
      (err "Greeting cannot be empty")
      (begin
        (var-set greeting new-greeting)
        (print {event: "greeting-updated", new-message: new-greeting})
        (ok true))))