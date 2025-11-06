;; @contract Silo
;; @version 1

(impl-trait .test-silo-trait4-v1.silo-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_CLAIM_FOR_ID (err u104001))
(define-constant ERR_NOT_COOLED_DOWN (err u104002))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u104003))
(define-constant ERR_ALREADY_FUNDED (err u104004))
(define-constant ERR_NOT_FUNDED (err u104005))

(define-constant hbtc-base (pow u10 u8))
(define-constant bps-base (pow u10 u4))
(define-constant this-contract (as-contract tx-sender))

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant fee-collector .test-fee-collector-hbtc-v1-1)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var current-claim-id uint u0)
(define-data-var unfunded-claims uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims
  { 
    claim-id: uint
  }
  {
    recipient: principal,
    amount: uint,                                 ;; asset amount 
    fee: uint,                                    ;; fee amount in asset
    ts: uint,                               ;; timestamp in s claim after cooldown
    funded: bool,                              ;; true if the claim has been funded
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-current-claim-id)
  (var-get current-claim-id)
)

(define-read-only (get-unfunded-claims)
  (var-get unfunded-claims)
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
  (fold withdraw-iter entries (ok true))
)

(define-private (withdraw-iter (claim-id uint) (previous-result (response bool uint)))
  (match previous-result
    success (withdraw claim-id)
    error (err error)
  )
)

;; @desc - transfers asset to recipient after cooldown window has passed
;; @param - claim-id: uint id of the claim
(define-public (withdraw (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
    (amount (get amount current-claim))
    (fee (get fee current-claim))
    (recipient (get recipient current-claim))
  )
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-withdraw-enabled))
    (asserts! (>= (get-current-ts) (get ts current-claim)) ERR_NOT_COOLED_DOWN)
    (asserts! (get funded current-claim) ERR_NOT_FUNDED)
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount this-contract recipient none)))
    (if (> fee u0)
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer fee this-contract fee-collector none)))
      true
    )
    (print { action: "withdraw", user: contract-caller, data: { claim-id: claim-id, amount: amount, fee: fee, recipient: recipient, fee-address: fee-collector } })
    (ok (map-delete claims { claim-id: claim-id }))
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

;; @desc - called by the protocol to create a claim for the user to withdraw 
;; @param - amount: amount of token processed in the claim
;; @param - recipient: recipient of the claim
(define-public (create-claim (amount-token uint) (recipient principal))
  (let (
    (next-claim-id (+ (get-current-claim-id) u1))
    (price (contract-call? .test-state-hbtc-v1-1 get-token-price))
    (total (/ (* amount-token price) hbtc-base))
    (exit-fee (contract-call? .test-state-hbtc-v1-1 get-custom-exit-fee contract-caller))
    (fee (/ (* total exit-fee) bps-base))
    (amount (- total fee))
    (cooldown (contract-call? .test-state-hbtc-v1-1 get-custom-cooldown recipient))
    (current-ts (get-current-ts))
    (ts (+ current-ts cooldown))
  )
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-protocol contract-caller))
    (asserts! (is-standard recipient) ERR_NOT_STANDARD_PRINCIPAL)
    (map-set claims { claim-id: next-claim-id } 
      {
        recipient: recipient,
        amount: amount,
        fee: fee,
        ts: ts,
        funded: false
      }
    )
    (try! (contract-call? .test-token-hbtc-v1-1 burn-for-protocol amount-token recipient))
    (var-set unfunded-claims (+ (get-unfunded-claims) total))
    (print { action: "create-claim", user: contract-caller, data: { claim-id: next-claim-id, amount-token: amount-token, price: price, amount: amount, fee: fee, recipient: recipient, current-ts: current-ts, ts: ts, cooldown: cooldown, } })
    (var-set current-claim-id next-claim-id)
    (ok next-claim-id)
  )
)


(define-public (fund-claim-many (claim-ids (list 1000 uint)))
  (fold fund-claim-iter claim-ids (ok true))
)

(define-private (fund-claim-iter (claim-id uint) (previous-result (response bool uint)))
  (match previous-result
    success (fund-claim claim-id)
    error (err error)
  )
)

(define-public (fund-claim (claim-id uint))
  (let (
    (claim (try! (get-claim claim-id)))
    (total (+ (get amount claim) (get fee claim)))
    (is-cooled-down (>= (get-current-ts) (get ts claim)))
    (is-manager (get manager (contract-call? .test-hq-vaults-v1-1 get-keeper contract-caller)))
  )
    (asserts! (not (get funded claim)) ERR_ALREADY_FUNDED)

    (if is-manager
      true
      (asserts! is-cooled-down ERR_NOT_COOLED_DOWN)
    )
    
    (try! (contract-call? .test-reserve-hbtc-v1-1 transfer sbtc-token total this-contract))
    (var-set unfunded-claims (- (get-unfunded-claims) total))
    (map-set claims { claim-id: claim-id } (merge claim { funded: true }))
    (print { action: "fund-claim", user: contract-caller, is-manager: is-manager, data: { claim-id: claim-id, claim: (try! (get-claim claim-id)) } })
    (ok true)
  )
)