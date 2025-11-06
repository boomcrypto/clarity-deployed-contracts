;; @contract StakingSiloTrait
;; @version 1.0
;; @description Trait contract for staking silo functionality

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait staking-silo-trait
  (
    ;;-------------------------------------
    ;; Getters
    ;;-------------------------------------

    ;; @desc - Get claim data by ID
    ;; @param - id: claim ID to retrieve
    ;; @return - (ok {recipient: principal, amount: uint, ts: uint}) on success, (err uint) on failure
    (get-claim (uint) (response {recipient: principal, amount: uint, ts: uint} uint))

    ;;-------------------------------------
    ;; User Functions
    ;;-------------------------------------

    ;; @desc - Transfer USDh to recipient after cooldown window has passed
    ;; @param - claim-id: ID of the claim to execute
    ;; @return - (ok bool) on success, (err uint) on failure
    (withdraw (uint) (response bool uint))

  )
)