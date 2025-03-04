;; DATA VARS

;; Proposal nonce
(define-data-var next-proposal-nonce uint u0)

;; Governance mutli-sig accounts
(define-map governance-accounts principal bool)

;; Total count of governance accounts in multisig
(define-data-var governance-accounts-count uint u0)

;; approved multisigs for given proposal
(define-map proposal-approved-members { proposal-id: (buff 32), member: principal} bool)

;; denied multisigs for given proposal
(define-map proposal-denied-members { proposal-id: (buff 32), member: principal} bool)

;; Update governance multisig data
(define-map update-governance-multisig-proposal-data (buff 32) principal)

;; flag to check if the contract is initialized
(define-data-var governance-initialized bool false)

;; Governance proposal
(define-map governance-proposal (buff 32) {
  action: uint,
  approve-count: uint,
  deny-count: uint,
  completed: bool,
  expires-at: uint
})

;; contract deployer. No permissions except to initialize the contract
(define-constant contract-deployer contract-caller)

;; ERRORS
(define-constant ERR-NOT-GOVERNANCE (err u50000))
(define-constant ERR-CONTRACT-NOT-INITIALIZED (err u50001))
(define-constant ERR-UNKNOWN-PROPOSAL (err u50002))
(define-constant ERR-INVALID-ACTION (err u50003))
(define-constant ERR-SUBMITTED-VOTE (err u50004))
(define-constant ERR-CONTRACT-ALREADY-INITIALIZED (err u50005))
(define-constant ERR-NOT-CONTRACT-DEPLOYER (err u50006))
(define-constant ERR-ZERO-GOVERNANCE (err u50007))
(define-constant ERR-ALREADY-GOVERNANCE-MEMBER (err u50008))
(define-constant ERR-NOT-GOVERNANCE-MEMBER (err u50009))
(define-constant ERR-FAILED-TO-GENERATE-PROPOSAL-ID (err u50010))
(define-constant ERR-PROPOSAL-ALREADY-EXISTS (err u50011))
(define-constant ERR-PROPOSAL-COMPLETED (err u50012))
(define-constant ERR-PROPOSAL-VOTING-INCOMPLETE (err u50013))
(define-constant ERR-PROPOSAL-CANNOT-CLOSE (err u50014))
(define-constant ERR-PROPOSAL-EXPIRED (err u50015))

;; CONSTANTS
;; Action to add new principal to governance multisig
(define-constant ACTION_ADD_GOVERNANCE_MULTISIG u0)

;; Action to remove principal from governance multisig
(define-constant ACTION_REMOVE_GOVERNANCE_MULTISIG u1)

;; Threshold to either execute or remove proposal
;; 66% and above
;; 1 & 2 Account Multisig will require all of them to execute or deny proposal
(define-constant THRESHOLD u60)

;; Success response
(define-constant SUCCESS (ok true))

;; PRIVATE FUNCTIONS
(define-private (is-valid-action (action-id uint))
  (<= action-id u1)
)

(define-private (create-proposal (proposal-id (buff 32)) (action uint) (expires-in uint))
  (begin
    (try! (is-governance-member contract-caller))
    (asserts! (not (is-some (map-get? governance-proposal proposal-id))) ERR-PROPOSAL-ALREADY-EXISTS)
    (asserts! (var-get governance-initialized) ERR-CONTRACT-NOT-INITIALIZED)
    (asserts! (is-valid-action action) ERR-INVALID-ACTION)
    (var-set next-proposal-nonce (+ (var-get next-proposal-nonce) u1))
    (map-set governance-proposal proposal-id {
      action: action,
      approve-count: u1,
      deny-count: u0,
      completed: false,
      expires-at: (+ stacks-block-height expires-in)
    })
    (map-set proposal-approved-members {proposal-id: proposal-id, member: contract-caller} true)
    (print {
      action: "proposal-initiated",
      proposal-id: proposal-id
    })
    (print {
      action: "proposal-voted-approved",
      voter: contract-caller,
      proposal-id: proposal-id
    })
    (ok proposal-id)
))

(define-private (approve-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (approve-count (get approve-count proposal))
      (total-count (var-get governance-accounts-count))
      (percentage (/ (* approve-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (deny-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (deny-count (get deny-count proposal))
      (total-count (var-get governance-accounts-count))
      (percentage (/ (* deny-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (execute-update-governance-multisig (proposal-id (buff 32)) (action uint))
  (let ((governance (unwrap-panic (map-get? update-governance-multisig-proposal-data proposal-id))))
    (if (is-eq action ACTION_ADD_GOVERNANCE_MULTISIG) 
      (begin
        (asserts! (not (is-already-member governance)) ERR-ALREADY-GOVERNANCE-MEMBER)
        (map-set governance-accounts governance true)
        (var-set governance-accounts-count (+ (var-get governance-accounts-count) u1))
        SUCCESS
      )
      (if (is-eq action ACTION_REMOVE_GOVERNANCE_MULTISIG)
        (begin
          (asserts! (is-already-member governance) ERR-NOT-GOVERNANCE-MEMBER)
          (asserts! (>= (- (var-get governance-accounts-count) u1) u1) ERR-ZERO-GOVERNANCE)
          (map-delete governance-accounts governance)
          (var-set governance-accounts-count (- (var-get governance-accounts-count) u1))
          SUCCESS
        )
        ERR-INVALID-ACTION
      )
    )
))

(define-private (execute-if-approve-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (threshold (try! (approve-threshold-met proposal-id)))
      (action (get action proposal))
    )
    (if threshold
      (begin
        (try! (execute-update-governance-multisig proposal-id action))
        (print {
          action: "proposal-executed",
          proposal-id: proposal-id
        })
        (map-set governance-proposal proposal-id {
          action: action,
          approve-count: (get approve-count proposal),
          deny-count: (get deny-count proposal),
          expires-at: (get expires-at proposal),
          completed: true
        })
        SUCCESS
      )
      SUCCESS
    )
))

(define-private (close-if-deny-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (threshold (try! (deny-threshold-met proposal-id)))
    )
    (if threshold
      (begin
        (print {
          action: "proposal-denied",
          proposal-id: proposal-id
        })
        (map-set governance-proposal proposal-id {
          action: (get action proposal),
          approve-count: (get approve-count proposal),
          deny-count: (get deny-count proposal),
          expires-at: (get expires-at proposal),
          completed: true
        })
        SUCCESS
      )
      SUCCESS
    )
))

(define-private (has-submitted-vote (proposal-id (buff 32)))
  (or 
    (default-to false (map-get? proposal-approved-members {proposal-id: proposal-id, member: contract-caller}))
    (default-to false (map-get? proposal-denied-members {proposal-id: proposal-id, member: contract-caller}))
))

(define-private (set-governance-multisig (maybe-account (optional principal)))
  (match maybe-account 
    account (begin
      (map-set governance-accounts account true)
      (var-set governance-accounts-count (+ (var-get governance-accounts-count) u1))
      SUCCESS
    )
    SUCCESS
))

(define-private (is-already-member (account principal))
  (default-to false (map-get? governance-accounts account))
)

(define-private (can-add-new-member (account principal))
  (if (is-already-member account) ERR-ALREADY-GOVERNANCE-MEMBER SUCCESS)
)

(define-private (can-remove-member (account principal))
  (if (is-already-member account) SUCCESS ERR-NOT-GOVERNANCE-MEMBER)
)
  
;; READ ONLY FUNCTIONS
(define-read-only (is-governance-member (member principal))
  (begin
    (unwrap! (map-get? governance-accounts member) ERR-NOT-GOVERNANCE)
    SUCCESS
))

(define-read-only (governance-multisig-count)
  (var-get governance-accounts-count)
)

(define-read-only (get-proposal (proposal-id (buff 32)))
  (map-get? governance-proposal proposal-id)
)

;; PUBLIC FUNCTIONS
(define-public (initiate-proposal-to-update-governance-multisig (action uint) (governance-account principal) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: governance-account
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (if (is-eq action ACTION_ADD_GOVERNANCE_MULTISIG) 
      (try! (can-add-new-member governance-account))
      (try! (can-remove-member governance-account))
    )
    (map-set update-governance-multisig-proposal-data proposal-id governance-account)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (approve (proposal-id (buff 32)))
  (let ((proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL)))
    (try! (is-governance-member contract-caller))
    (asserts! (not (get completed proposal)) ERR-PROPOSAL-COMPLETED)
    (asserts! (< stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (not (has-submitted-vote proposal-id)) ERR-SUBMITTED-VOTE)
    (map-set proposal-approved-members {proposal-id: proposal-id, member: contract-caller} true)
    (map-set governance-proposal proposal-id {
      action: (get action proposal),
      approve-count: (+ (get approve-count proposal) u1),
      deny-count: (get deny-count proposal),
      expires-at: (get expires-at proposal),
      completed: (get completed proposal)
    })

    (print {
      action: "proposal-voted-approved",
      voter: contract-caller,
      proposal-id: proposal-id
    })

    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    SUCCESS
))

(define-public (deny (proposal-id (buff 32)))
  (let ((proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL)))
    (try! (is-governance-member contract-caller))
    (asserts! (not (get completed proposal)) ERR-PROPOSAL-COMPLETED)
    (asserts! (< stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (not (has-submitted-vote proposal-id)) ERR-SUBMITTED-VOTE)
    (map-set proposal-denied-members {proposal-id: proposal-id, member: contract-caller} true)
    (map-set governance-proposal proposal-id {
      action: (get action proposal),
      approve-count: (get approve-count proposal),
      deny-count: (+ (get deny-count proposal) u1),
      expires-at: (get expires-at proposal),
      completed: (get completed proposal)
    })

    (print {
      action: "proposal-voted-denied",
      voter: contract-caller,
      proposal-id: proposal-id
    })

    ;; deny proposal if the deny threshold is met
    (try! (close-if-deny-threshold-met proposal-id))
    SUCCESS
))

;; Close the proposal when
;; - Every one voted
;; - But all the votes does not meet neither approve or deny threshold. Proposal is locked.
(define-public (close (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (total-voted (+ (get approve-count proposal) (get deny-count proposal)))
      (total-count (var-get governance-accounts-count))
      (deny-threshold (try! (deny-threshold-met proposal-id)))
      (approve-threshold (try! (approve-threshold-met proposal-id)))
      (has-threshold-met (or deny-threshold approve-threshold))
    )
    (try! (is-governance-member contract-caller))
    (asserts! (not (get completed proposal)) ERR-PROPOSAL-COMPLETED)
    (if (>= stacks-block-height (get expires-at proposal))
      (begin 
        (print {
          action: "proposal-expired",
          proposal-id: proposal-id
        })
        true
      )
      (begin
        (asserts! (is-eq total-count total-voted) ERR-PROPOSAL-VOTING-INCOMPLETE)
        (asserts! (not has-threshold-met) ERR-PROPOSAL-CANNOT-CLOSE)
      )
    )
    (map-set governance-proposal proposal-id {
      action: (get action proposal),
      approve-count: (get approve-count proposal),
      deny-count: (get deny-count proposal),
      expires-at: (get expires-at proposal),
      completed: true
    })
    (print {
      action: "proposal-closed",
      proposal-id: proposal-id
    })
    SUCCESS
))

(define-public (initialize-governance (governance-multisigs (list 5 (optional principal))))
  (begin
    (asserts! (not (var-get governance-initialized)) ERR-CONTRACT-ALREADY-INITIALIZED)
    (asserts! (is-eq contract-caller contract-deployer) ERR-NOT-CONTRACT-DEPLOYER)
    (var-set governance-initialized true)
    (map set-governance-multisig governance-multisigs)
    SUCCESS
))
