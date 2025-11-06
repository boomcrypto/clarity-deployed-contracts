;; @contract Silo
;; @version 1

(impl-trait .test-silo-trait2-v1.silo-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_CLAIM_FOR_ID (err u104001))
(define-constant ERR_NOT_COOLED_DOWN (err u104002))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u104003))
(define-constant ERR_ALREADY_FUNDED (err u104004))
(define-constant ERR_NOT_FUNDED (err u104005))

(define-constant this-contract (as-contract tx-sender))

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
    amount: uint,                                 ;; deposit-asset
    fee: uint,                                    ;; deposit-asset
    claim-ts: uint,                               ;; timestamp in s
    funded: bool,                                 ;; true if the claim has been funded
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-current-claim-id)
  (var-get current-claim-id)
)

(define-read-only (get-claim (id uint))
  (ok (unwrap! (map-get? claims { claim-id: id }) ERR_NO_CLAIM_FOR_ID))
)

(define-private (get-current-ts)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

;;-------------------------------------
;; User
;;-------------------------------------

;; @desc - executes a claim for each claim-id in the list
;; @param - entries: list of claim-ids
(define-public (withdraw-many (entries (list 1000 uint)))
  (ok (map withdraw entries)))

;; @desc - transfers deposit-asset to recipient of the claim after the cooldown window has passed
;; @param - claim-id: uint id of the claim
(define-public (withdraw (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
    (amount (get amount current-claim))
    (fee (get fee current-claim))
    (recipient (get recipient current-claim))
  )
    (try! (contract-call? .test-state-hbtc2-v1 check-is-withdraw-enabled))
    (asserts! (>= (get-current-ts) (get claim-ts current-claim)) ERR_NOT_COOLED_DOWN)
    (asserts! (get funded current-claim) ERR_NOT_FUNDED)
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount this-contract recipient none)))
    (if (> fee u0)
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer fee this-contract .test-fee-collector-hbtc-v1 none)))
      true
    )
    (print { action: "withdraw", user: contract-caller, data: { claim-id: claim-id, amount: amount, fee: fee, recipient: recipient, fee-address: .test-fee-collector-hbtc-v1 } })
    (ok (map-delete claims { claim-id: claim-id }))
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

;; @desc - called by the protocol to create a claim for the user to withdraw 
;; @param - amount: amount of deposit-asset to claim (10**8)
;; @param - fee: fee to be paid to the protocol (10**8)
;; @param - recipient: recipient of the claim
(define-public (create-claim (amount uint) (fee uint) (recipient principal))
  (let (
    (next-claim-id (+ (get-current-claim-id) u1))
    (claim-ts (+ (get-current-ts) (contract-call? .test-state-hbtc2-v1 get-custom-cooldown recipient)))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol contract-caller))
    (asserts! (is-standard recipient) ERR_NOT_STANDARD_PRINCIPAL)
    (map-set claims { claim-id: next-claim-id } 
      {
        recipient: recipient,
        amount: amount,
        fee: fee,
        claim-ts: claim-ts,
        funded: false
      }
    )
    (print { action: "create-claim", user: contract-caller, data: { claim-id: next-claim-id, amount: amount, fee: fee, recipient: recipient, claim-ts: claim-ts } })
    (ok (var-set current-claim-id next-claim-id))
  )
)

;; @desc - called by the protocol to fund a claim for the user to withdraw 
;; @param - claim-ids: list of claim-ids
(define-public (fund-claim-many (claim-ids (list 1000 uint)))
  (ok (map fund-claim claim-ids))
)

(define-public (fund-claim (claim-id uint))
  (let (
    (claim (try! (get-claim claim-id)))
    (total-amount (+ (get amount claim) (get fee claim)))
    (cooled-down (>= (get-current-ts) (get claim-ts claim)))
    (is-manager (get manager (contract-call? .test-hq-vaults-v1 get-keeper contract-caller)))
  )
    (asserts! (not (get funded claim)) ERR_ALREADY_FUNDED)

    (if is-manager
      true
      (asserts! cooled-down ERR_NOT_COOLED_DOWN)
    )
    (try! (contract-call? .test-reserve-hbtc2-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token total-amount this-contract))
    (map-set claims { claim-id: claim-id } (merge claim { funded: true }))
    (print { action: "fund-claim", user: contract-caller, is-manager: is-manager, data: { claim-id: claim-id, claim: (try! (get-claim claim-id)) } })
    (ok true)
  )
)