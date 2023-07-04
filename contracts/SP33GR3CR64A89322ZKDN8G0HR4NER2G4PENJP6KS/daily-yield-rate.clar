;; Daily rate contract
;;The contract-owner constant is set to the contract creators tx-sender address
(define-constant contract-owner tx-sender)
;;Error thrown by invalid caller accessing set-rate
(define-constant err-invalid-caller (err u1))
;;Data variable for the rate of return
(define-data-var rate (string-ascii 5) "nil")
;;Private(internal) function to check if the function caller is the contract owner
(define-private (is-contract-owner)
    (is-eq contract-owner tx-sender)
)
;;Read-only function to get the stored value for rate
(define-read-only (get-rate)    
  (var-get rate))
;;Function only executes if caller is contract owner
;;Function updates the stored rate to a new value given by a parameter
(define-public (set-rate (new-rate (string-ascii 5)))
    (begin
        ;; Assert the tx-sender is valid.
        (asserts! (is-contract-owner) err-invalid-caller)
        (ok (var-set rate new-rate))
    )
)
