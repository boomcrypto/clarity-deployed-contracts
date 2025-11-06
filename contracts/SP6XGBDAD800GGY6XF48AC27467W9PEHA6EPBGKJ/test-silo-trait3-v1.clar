;; @contract Silo Trait
;; @version 1

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait silo-trait
  (
    ;; @desc - Create a claim for user to withdraw sBTC
    ;; @param - amount-after-fees: amount of sBTC to claim after fees (10**8)
    ;; @param - fee-amount: amount of sBTC collected as fee (10**8)
    ;; @param - recipient: recipient of the claim
    ;; @return - (ok uint) claim ID on success, (err uint) on failure
    (create-claim (uint uint principal) (response uint uint))
  )
)