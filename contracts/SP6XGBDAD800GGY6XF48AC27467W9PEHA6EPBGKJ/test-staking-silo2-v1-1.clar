;; @contract Staking Silo
;; @version 1.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_CLAIM_FOR_ID (err u3101))
(define-constant ERR_NOT_COOLED_DOWN (err u3102))
(define-constant ERR_ONLY_STAKING_CONTRACT (err u3103))
(define-constant ERR_INVALID_AMOUNT (err u3104))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var current-claim-id uint u4)

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

(define-public (withdraw-many (entries (list 1000 uint)))
  (ok (map withdraw entries)))

(define-public (withdraw (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
  )
    (asserts! (>= (get-current-ts) (get ts current-claim)) ERR_NOT_COOLED_DOWN)
    (try! (contract-call? .test-usdh-token-v1 transfer (get amount current-claim) (as-contract tx-sender) (get recipient current-claim) none))
    (print { action: "withdraw", user: contract-caller, data: {claim-id: claim-id, claim-data: current-claim } })
    (ok (map-delete claims { claim-id: claim-id }))
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

(define-public (create-claim (amount uint) (recipient principal))
  (let (
    (claim-id (+ u1 (get-current-claim-id)))
    (ts (+ (get-current-ts) (contract-call? .test-staking-state2-v1 get-custom-cooldown recipient)))
  )
    (asserts! (is-eq contract-caller .test-staking2-v1-1) ERR_ONLY_STAKING_CONTRACT)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (map-set claims { claim-id: claim-id } 
      {
        recipient: recipient,
        amount: amount,                                             ;; USDh
        ts: ts
      }
    )
    (print { action: "create-claim", user: contract-caller, data: { claim-id: claim-id, recipient: recipient, amount: amount, claim-ts: ts } })
    (var-set current-claim-id claim-id)
    (ok claim-id)
  )
)