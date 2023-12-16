;; @contract Reserve Trait
;; @version 1

(define-trait reserve-trait
  (
    ;; Getters
    (get-stx-stacking () (response uint uint))
    (get-stx-for-withdrawals () (response uint uint))
    (get-stx-balance () (response uint uint))
    (get-total-stx () (response uint uint))

    ;; Withdrawals
    (lock-stx-for-withdrawal (uint) (response uint uint))
    (request-stx-for-withdrawal (uint principal) (response uint uint))

    ;; Stacking
    (request-stx-to-stack (uint) (response uint uint))
    (return-stx-from-stacking (uint) (response uint uint))

    ;; Get STX
    (get-stx (uint principal) (response uint uint))
  )
)
