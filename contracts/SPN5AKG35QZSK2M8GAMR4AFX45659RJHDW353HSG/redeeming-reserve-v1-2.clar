;; @contract Redeeming Reserve
;; @version 1.2

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Constants
;;------------------------------------

(define-constant ERR_NOT_AUTHORIZED_CALLER (err u9001))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u9002))
(define-constant ERR_NOT_AUTHORIZED_RECIPIENT (err u9003))

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map managers
  {
    address: principal
  }
  {
    active: bool
  }
)

(define-map authorized-recipients
  {
    address: principal
  }
  {
    active: bool
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-manager (address principal))
  (default-to
    { active: false }
    (map-get? managers { address: address })
  )
)

(define-read-only (get-authorized-recipient (address principal))
  (default-to
    { active: false }
    (map-get? authorized-recipients { address: address })
  )
)

;;-------------------------------------
;; Transfer
;;-------------------------------------

(define-public (transfer (amount uint) (recipient principal) (redeeming-asset <sip-010-trait>) (memo (optional (buff 34))))
  (let (
    (caller-is-manager (get active (get-manager contract-caller)))
    (caller-is-protocol (contract-call? .hq-v1 get-contract-active contract-caller))
  )
    (asserts! (or caller-is-protocol caller-is-manager) ERR_NOT_AUTHORIZED_CALLER)

    (if caller-is-manager
      (asserts! (get active (get-authorized-recipient recipient)) ERR_NOT_AUTHORIZED_RECIPIENT)
      true
    )
    (ok (try! (as-contract (contract-call? redeeming-asset transfer amount tx-sender recipient memo))))
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-manager (address principal) (active bool))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, old-value: (get active (get-manager address)), new-value: active })
    (ok (map-set managers { address: address } { active: active }))
  )
)

(define-public (set-authorized-recipient (address principal) (active bool))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, old-value: (get active (get-authorized-recipient address)), new-value: active })
    (ok (map-set authorized-recipients { address: address } { active: active }))
  )
)