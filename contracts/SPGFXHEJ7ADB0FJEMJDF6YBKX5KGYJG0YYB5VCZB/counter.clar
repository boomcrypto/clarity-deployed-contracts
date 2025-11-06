;; Simple counter contract
(define-constant MAX_COUNTER u100)

(define-trait counter-trait
  ((get-counter () (response uint uint))))

(define-map simple-map uint principal)

(define-data-var counter uint u0)
(define-data-var last-caller principal tx-sender)

;; Read-only function to get counter value
(define-read-only (get-counter)
  (var-get counter))

;; Read-only function to get last caller
(define-read-only (get-last-caller)
  (var-get last-caller))

;; Public function to increment counter
(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) u1))
    (var-set last-caller tx-sender)
    (map-set simple-map (var-get counter) tx-sender)
    (print {event: "incremented", new-value: (var-get counter), caller: tx-sender})
    (ok (var-get counter))))

;; Public function to reset counter
(define-public (reset)
  (begin
    (var-set counter u0)
    (var-set last-caller tx-sender)
    (print {event: "reset", caller: tx-sender})
    (ok u0)))