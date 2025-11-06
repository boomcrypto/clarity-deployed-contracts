;; TRAITS
(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; CONSTANTS

;; Action to update owner
(define-constant ACTION_SET_OWNER u0)

;; Action to update operator
(define-constant ACTION_SET_OPERATOR u1)

;; Action to update flash loan contract
(define-constant ACTION_SET_FLASH_LOAN_CONTRACT u2)

;; Action to update unprofitability threshold
(define-constant ACTION_SET_UNPROFITABILITY_THRESHOLD u3)

;; Action to withdraw token
(define-constant ACTION_WITHDRAW_TOKEN u4)

;; Action to update usdh threshold
(define-constant ACTION_SET_USDH_THRESHOLD u5)

;; Threshold to either execute or remove proposal
;; 60% and above
(define-constant THRESHOLD u60)

;; Threshold to update unprofitability threshold 
;; 20% and above
(define-constant THRESHOLD_MINIMAL u20)

;; Success response
(define-constant SUCCESS (ok true))

;; ERRORS
(define-constant ERR-INVALID-ACTION (err u20000))
(define-constant ERR-UNKNOWN-PROPOSAL (err u20001))
(define-constant ERR-SUBMITTED-VOTE (err u20002))
(define-constant ERR-PROPOSAL-COMPLETED (err u20003))
(define-constant ERR-CONTRACT-ALREADY-INITIALIZED (err u20004))
(define-constant ERR-CONTRACT-NOT-INITIALIZED (err u20005))
(define-constant ERR-NOT-CONTRACT-DEPLOYER (err u20006))
(define-constant ERR-PROPOSAL-ALREADY-EXISTS (err u20007))
(define-constant ERR-FAILED-TO-GENERATE-PROPOSAL-ID (err u20008))
(define-constant ERR-PROPOSAL-VOTING-INCOMPLETE (err u20009))
(define-constant ERR-PROPOSAL-CANNOT-CLOSE (err u20010))
(define-constant ERR-PROPOSAL-EXPIRED (err u20011))

;; DATA VARS

;; Next proposal nonce
(define-data-var next-proposal-nonce uint u0)

;; Governance proposal
(define-map governance-proposal (buff 32) {
  action: uint,
  approve-count: uint,
  deny-count: uint,
  completed: bool,
  expires-at: uint,
})

;; approved multisigs for given proposal
(define-map proposal-approved-members { proposal-id: (buff 32), member: principal} bool)

;; denied multisigs for given proposal
(define-map proposal-denied-members { proposal-id: (buff 32), member: principal} bool)

;; Update Principal data
(define-map set-principal-data (buff 32) principal)

;; Update unprofitability threshold data
(define-map set-unprofitability-threshold (buff 32) uint)

;; Update usdh threshold data
(define-map set-usdh-threshold (buff 32) uint)

;; Withdraw data
(define-map withdraw-data (buff 32) {
    amount: uint,
    token: uint,
    recipient: principal
  }
)

;; PRIVATE FUNCTIONS
(define-private (create-proposal (proposal-id (buff 32)) (action uint) (expires-in uint))
  (begin
    (try! (is-governance-member contract-caller))
    (asserts! (not (is-some (map-get? governance-proposal proposal-id))) ERR-PROPOSAL-ALREADY-EXISTS)
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

(define-private (has-submitted-vote (proposal-id (buff 32)))
  (or 
    (default-to false (map-get? proposal-approved-members {proposal-id: proposal-id, member: contract-caller}))
    (default-to false (map-get? proposal-denied-members {proposal-id: proposal-id, member: contract-caller}))
))

(define-private (execute-set-owner (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? set-principal-data proposal-id))))
    (contract-call? .liquidator set-owner data)
  )
)

(define-private (execute-set-operator (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? set-principal-data proposal-id))))
    (contract-call? .liquidator set-operator data)
  )
)

(define-private (execute-set-flash-loan-contract (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? set-principal-data proposal-id))))
    (contract-call? .liquidator set-flash-loan-sc data)
  )
)

(define-private (execute-set-unprofitability-threshold (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? set-unprofitability-threshold proposal-id))))
    (contract-call? .liquidator set-unprofitability-threshold data)
  )
)

(define-private (execute-set-usdh-threshold (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? set-usdh-threshold proposal-id))))
    (contract-call? .liquidator set-usdh-threshold data)
  )
)

(define-private (action-threshold (action uint))
  (if (is-eq action ACTION_SET_UNPROFITABILITY_THRESHOLD) THRESHOLD_MINIMAL THRESHOLD)
)

(define-private (execute-withdraw-token (proposal-id (buff 32)))
  (let (
      (data (unwrap-panic (map-get? withdraw-data proposal-id)))
      (amount (get amount data))
      (token (get token data))
      (recipient (get recipient data))
    )
    (contract-call? .liquidator withdraw-token token amount recipient)
  )
)

(define-private (approve-threshold-met (proposal-id (buff 32)) (action uint))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (approve-count (get approve-count proposal))
      (total-count (contract-call? .meta-governance governance-multisig-count))
      (percentage (/ (* approve-count u100) total-count))
      (threshold (action-threshold action))
    )
    (ok (>= percentage threshold))
))

(define-private (deny-threshold-met (proposal-id (buff 32)) (action uint))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (deny-count (get deny-count proposal))
      (total-count (contract-call? .meta-governance governance-multisig-count))
      (percentage (/ (* deny-count u100) total-count))
      (threshold (action-threshold action))
    )
    (ok (>= percentage threshold))
))

(define-private (execute-proposal (proposal-id (buff 32)) (action uint))
  (begin
    (asserts! (not (is-eq action ACTION_SET_OWNER)) (execute-set-owner proposal-id))
    (asserts! (not (is-eq action ACTION_SET_OPERATOR)) (execute-set-operator proposal-id))
    (asserts! (not (is-eq action ACTION_SET_FLASH_LOAN_CONTRACT)) (execute-set-flash-loan-contract proposal-id))
    (asserts! (not (is-eq action ACTION_SET_UNPROFITABILITY_THRESHOLD)) (execute-set-unprofitability-threshold proposal-id))
    (asserts! (not (is-eq action ACTION_WITHDRAW_TOKEN)) (execute-withdraw-token proposal-id))
    (asserts! (not (is-eq action ACTION_SET_USDH_THRESHOLD)) (execute-set-usdh-threshold proposal-id))
    ERR-INVALID-ACTION
))

(define-private (execute-if-approve-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (action (get action proposal))
      (threshold (try! (approve-threshold-met proposal-id action)))
    )
    (if threshold
      (begin
        (try! (execute-proposal proposal-id action))
        (map-set governance-proposal proposal-id {
          action: (get action proposal),
          approve-count: (get approve-count proposal),
          deny-count: (get deny-count proposal),
          expires-at: (get expires-at proposal),
          completed: true
        })
        (print {
          action: "proposal-executed",
          proposal-id: proposal-id
        })
        SUCCESS
      )
      SUCCESS
    )
))

(define-private (deny-proposal-if-deny-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (action (get action proposal))
      (threshold (try! (deny-threshold-met proposal-id action)))
    )
    (if threshold
      (begin
        (map-set governance-proposal proposal-id {
          action: (get action proposal),
          approve-count: (get approve-count proposal),
          deny-count: (get deny-count proposal),
          expires-at: (get expires-at proposal),
          completed: true
        })
        (print {
          action: "proposal-denied",
          proposal-id: proposal-id
        })
        SUCCESS
      )
      SUCCESS
    )
))


;; READ ONLY FUNCTIONS
(define-read-only (is-governance-member (member principal))
  (contract-call? .meta-governance is-governance-member member)
)

(define-read-only (get-proposal (proposal-id (buff 32)))
  (map-get? governance-proposal proposal-id)
)
  
;; PUBLIC FUNCTIONS
(define-public (initiate-proposal-to-set-principal (action uint) (data principal) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_SET_OWNER) (<= action ACTION_SET_FLASH_LOAN_CONTRACT)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set set-principal-data proposal-id data)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-set-unprofitability-threshold (data uint) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (action ACTION_SET_UNPROFITABILITY_THRESHOLD)
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set set-unprofitability-threshold proposal-id data)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-withdraw-token (data {token: uint, amount: uint, recipient: principal}) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (action ACTION_WITHDRAW_TOKEN)
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set withdraw-data proposal-id data)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-set-usdh-threshold (data uint) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (action ACTION_SET_USDH_THRESHOLD)
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set set-usdh-threshold proposal-id data)
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
    (try! (deny-proposal-if-deny-threshold-met proposal-id))
    SUCCESS
))

;; Close the proposal when
;; - Every one voted
;; - But all the votes does not meet neither approve or deny threshold. Proposal is locked.
;; or proposal is expired
(define-public (close (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (total-voted (+ (get approve-count proposal) (get deny-count proposal)))
      (total-count (contract-call? .meta-governance governance-multisig-count))
      (action (get action proposal))
      (deny-threshold (try! (deny-threshold-met proposal-id action)))
      (approve-threshold (try! (approve-threshold-met proposal-id action)))
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
      action: action,
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
