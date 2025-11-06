;; @contract Silo Trait
;; @version 1

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait silo-trait
  (
    ;; @desc - Create a claim for user to withdraw sBTC
    ;; @param - amount-token: amount of tokens processed in the claim (10**8)
    ;; @param - recipient: recipient of the claim
    ;; @return - (ok uint) claim ID on success, (err uint) on failure
    (create-claim (uint principal) (response uint uint))
  )
)