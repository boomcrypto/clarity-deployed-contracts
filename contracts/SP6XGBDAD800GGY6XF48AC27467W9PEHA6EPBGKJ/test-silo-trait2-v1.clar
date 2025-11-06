;; @contract Silo Trait
;; @version 1.0
;; @description Trait contract for silo functionality

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait silo-trait
  (
    ;; @desc - Create a claim for user to withdraw deposit-asset
    ;; @param - amount: amount of deposit-asset to claim (10**8)
    ;; @param - fee: fee to be paid to the protocol (10**8)
    ;; @param - recipient: recipient of the claim
    ;; @return - (ok bool) on success, (err uint) on failure
    (create-claim (uint uint principal) (response bool uint))
  )
)