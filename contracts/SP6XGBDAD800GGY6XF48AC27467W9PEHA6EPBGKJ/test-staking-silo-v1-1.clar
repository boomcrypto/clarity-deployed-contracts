;; @contract Staking Silo
;; @version 1.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_CLAIM_FOR_ID (err u3101))
(define-constant ERR_NOT_COOLED_DOWN (err u3102))
(define-constant ERR_ONLY_STAKING_CONTRACT (err u3103))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var current-claim-id uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims
  { 
    claim-id: uint
  }
  {
    recipient: principal,
    amount: uint,                          ;; USDh
    ts: uint,                              ;; timestamp in seconds
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-current-ts)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

(define-read-only (get-current-claim-id)
  (var-get current-claim-id)
)

(define-read-only (get-claim (id uint))
  (ok (unwrap! (map-get? claims { claim-id: id }) ERR_NO_CLAIM_FOR_ID))
)

;;-------------------------------------
;; User
;;-------------------------------------

;; @desc - executes a claim for each claim-id in the list
;; @param - entries: list of claim-ids
(define-public (withdraw-many (entries (list 1000 uint)))
  (ok (map withdraw entries)))

;; @desc - transfers USDh to recipient of the claim after the cooldown window has passed
;; @param - claim-id: uint id of the claim
(define-public (withdraw (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
  )
    (asserts! (>= (get-current-ts) (get ts current-claim)) ERR_NOT_COOLED_DOWN)
    (try! (contract-call? .test-usdh-token-v1 transfer (get amount current-claim) (as-contract tx-sender) (get recipient current-claim) none))
    (print {action: "withdraw", user: contract-caller, data: {claim-id: claim-id, claim-data: current-claim}})
    (ok (map-delete claims { claim-id: claim-id }))
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

;; @desc - called by the protocol to create a claim for the user to withdraw USDh
;; @param - amount: amount of USDh to claim (10**8)
;; @param - recipient: recipient of the claim
(define-public (create-claim (amount uint) (recipient principal))
  (let (
    (next-claim-id (+ (get-current-claim-id) u1))
    (ts (+ (get-current-ts) (contract-call? .test-staking-state-v1 get-custom-cooldown recipient)))
  )
    (asserts! (is-eq contract-caller .test-staking-v1-1) ERR_ONLY_STAKING_CONTRACT)
    (map-set claims { claim-id: next-claim-id } 
      {
        recipient: recipient,
        amount: amount,                                             ;; USDh
        ts: ts
      }
    )
    (print {action: "create-claim", user: contract-caller, data: {claim-id: next-claim-id, recipient: recipient, amount: amount, claim-ts: ts}})
    (ok (var-set current-claim-id next-claim-id))
  )
)