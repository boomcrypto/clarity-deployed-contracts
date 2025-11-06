;; @contract HQ
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_OWNER (err u1001))
(define-constant ERR_NOT_ADMIN (err u1002))
(define-constant ERR_NOT_GUARDIAN (err u1003))
(define-constant ERR_CONTRACTS_DISABLED (err u1004))
(define-constant ERR_MINTING_DISABLED (err u1005))
(define-constant ERR_INACTIVE_CONTRACT (err u1006))
(define-constant ERR_NO_ENTRY (err u1007))
(define-constant ERR_ACTIVATION (err u1008))

(define-constant activation-delay u1)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var contracts-enabled bool true)
(define-data-var minting-enabled bool true)

(define-data-var owner principal tx-sender)

(define-data-var next-owner
  {
    address: principal,
    burn-block-height: uint
  }
  {
    address: tx-sender,
    burn-block-height: burn-block-height
  }
)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map admins
  {
    address: principal
  }
  {
    active: bool,
    burn-block-height: (optional uint)
  }
)

(define-map guardians
  {
    address: principal
  }
  {
    active: bool,
  }
)

(define-map minting-contracts 
  {
    address: principal
  }
  {
    active: bool,
    burn-block-height: (optional uint)
  }
)

(define-map contracts
  {
    address: principal
  }
  {
    active: bool,
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-contracts-enabled)
  (var-get contracts-enabled)
)
(define-read-only (get-minting-enabled)
  (var-get minting-enabled)
)

(define-read-only (get-owner)
  (var-get owner)
)

(define-read-only (get-next-owner)
  (var-get next-owner)
)

(define-read-only (get-admin (address principal))
  (default-to 
    { active: false, burn-block-height: none }
    (map-get? admins { address: address })
  )
)

(define-read-only (get-guardian (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? guardians { address: address })
    )
  )
)

(define-read-only (get-minting-contract (address principal))
  (default-to
    { active: false, burn-block-height: none }
    (map-get? minting-contracts { address: address })
  )
)

(define-read-only (get-contract-active (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? contracts { address: address })
    )
  )
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-enabled)
  (ok (asserts! (var-get contracts-enabled) ERR_CONTRACTS_DISABLED))
)

(define-read-only (check-is-owner (contract principal))
  (ok (asserts! (is-eq contract (get-owner)) ERR_NOT_OWNER))
)

(define-read-only (check-is-admin (contract principal))
  (ok (asserts! (get active (get-admin contract)) ERR_NOT_ADMIN))
)

(define-read-only (check-is-guardian (contract principal))
  (ok (asserts! (get-guardian contract) ERR_NOT_GUARDIAN))
)

(define-read-only (check-is-minting-contract (contract principal))
  (begin
    (asserts! (get-minting-enabled) ERR_MINTING_DISABLED)
    (ok (asserts! (get active (get-minting-contract contract)) ERR_INACTIVE_CONTRACT))
  )
)

(define-read-only (check-is-protocol (contract principal))
  (ok (asserts! (get-contract-active contract) ERR_INACTIVE_CONTRACT))
)

;;-------------------------------------
;; Set
;;-------------------------------------

(define-public (set-contracts-enabled (enabled bool))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (var-set contracts-enabled enabled))
  )
)

(define-public (disable-contracts)
  (begin
    (try! (check-is-guardian tx-sender))
    (ok (var-set contracts-enabled false))
  )
)

(define-public (set-minting-enabled (enabled bool))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (var-set minting-enabled enabled))
  )
)

(define-public (disable-minting)
  (begin
    (try! (check-is-guardian tx-sender))
    (ok (var-set minting-enabled false))
  )
)

(define-public (request-owner-update (address principal))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (var-set next-owner { address: address, burn-block-height: burn-block-height }))
  )
)

(define-public (activate-next-owner)
  (begin
    (try! (check-is-owner tx-sender))
    (asserts! (>= burn-block-height (+ (get burn-block-height (get-next-owner)) activation-delay)) ERR_ACTIVATION)
    (ok (var-set owner (get address (get-next-owner))))
  )
)

(define-public (request-admin-update (address principal))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (map-set admins { address: address } { active: false, burn-block-height: (some burn-block-height) }))
  )
)

(define-public (remove-admin (address principal))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (map-delete admins { address: address }))
  )
)

(define-public (activate-admin (address principal))
  (let (
    (admin-entry (get-admin address))
    (admin-burn-block-height (unwrap! (get burn-block-height admin-entry) ERR_NO_ENTRY))
  )
    (asserts! (or (is-eq tx-sender (get-owner)) (is-eq address tx-sender)) ERR_NOT_OWNER)
    (asserts! (>= burn-block-height (+ admin-burn-block-height activation-delay)) ERR_ACTIVATION)
    (ok (map-set admins { address: address } (merge admin-entry { active: true })))
  )
)

(define-public (set-guardian (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set guardians { address: address } { active: active }))
  )
)

(define-public (request-minting-contract-update (address principal))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (map-set minting-contracts { address: address } { active: false, burn-block-height: (some burn-block-height) }))
  )
)

(define-public (remove-minting-contract (address principal))
  (begin
    (try! (check-is-owner tx-sender))
    (ok (map-delete minting-contracts { address: address }))
  )
)

(define-public (activate-minting-contract (address principal))
  (let (
    (contract-entry (get-minting-contract address))
    (contract-burn-block-height (unwrap! (get burn-block-height contract-entry) ERR_NO_ENTRY))
  )
    (try! (check-is-owner tx-sender))
    (asserts! (>= burn-block-height (+ contract-burn-block-height activation-delay)) ERR_ACTIVATION)
    (ok (map-set minting-contracts {address: address} (merge contract-entry { active: true})))
  )
)

(define-public (set-contract-active (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set contracts { address: address } { active: active }))
  )
)

;;-------------------------------------
;; Init
;;-------------------------------------

(map-set admins { address: tx-sender } { active: true, burn-block-height: none })
(map-set minting-contracts { address: .test-minting-otc-v1 } { active: true, burn-block-height: (some burn-block-height) })
(map-set minting-contracts { address: .test-minting-otc-v1 } { active: true, burn-block-height: (some burn-block-height) })
(map-set minting-contracts { address: .test-controller-v1 } { active: true, burn-block-height: (some burn-block-height) })
(map-set minting-contracts { address: .test-emergency-recover-v1 } { active: true, burn-block-height: (some burn-block-height) })
(map-set minting-contracts { address: .test-staking-v1-1 } { active: true, burn-block-height: (some burn-block-height) })