;; @contract SiloTrait
;; @version 1.0
;; @description Trait contract for silo functionality

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait silo-trait
  (
    ;; @desc - Create a claim for user to withdraw USDh
    ;; @param - amount: amount of USDh to claim
    ;; @param - recipient: recipient of the claim
    ;; @return - (ok uint) claim ID on success, (err uint) on failure
    (create-claim (uint principal) (response uint uint))
  )
)