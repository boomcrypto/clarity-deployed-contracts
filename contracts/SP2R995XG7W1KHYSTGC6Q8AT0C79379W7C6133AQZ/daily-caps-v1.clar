;; TITLE: daily-caps-module
;; VERSION: 1.0

(use-trait token-trait .trait-sip-010.sip-010-trait)

;; CONSTANTS
(define-constant LP-CONTRACT (as-contract .liquidity-provider-v1))
(define-constant BORROWER-CONTRACT (as-contract .borrower-v1))
(define-constant SUCCESS (ok true))
(define-constant SCALING-FACTOR u100000000)
(define-constant ACTION_SET_LP_CAP u0)
(define-constant ACTION_SET_DEBT_CAP u1)
(define-constant ACTION_SET_COLLATERAL_CAP u2)
(define-constant ACTION_SET_TIME_WINDOW u3)
;; Threshold to either execute or remove proposal
(define-constant THRESHOLD u60) ;; 60% and above

;; ERRORS
(define-constant ERR-RESTRICTED (err u90000))
(define-constant ERR-FAILED-TO-GET-BALANCE (err u90001))
(define-constant ERR-DAILY-LP-CAP-EXCEEDED (err u90002))
(define-constant ERR-DAILY-DEBT-CAP-EXCEEDED (err u90003))
(define-constant ERR-DAILY-COLLATERAL-CAP-EXCEEDED (err u90004))
(define-constant ERR-INVALID-CAP-FACTOR (err u90005))
;; governance-related errors
(define-constant ERR-INVALID-ACTION (err u90006))
(define-constant ERR-UNKNOWN-PROPOSAL (err u90007))
(define-constant ERR-SUBMITTED-VOTE (err u90008))
(define-constant ERR-PROPOSAL-COMPLETED (err u90009))
(define-constant ERR-CONTRACT-ALREADY-INITIALIZED (err u90010))
(define-constant ERR-CONTRACT-NOT-INITIALIZED (err u90011))
(define-constant ERR-NOT-CONTRACT-DEPLOYER (err u90012))
(define-constant ERR-PROPOSAL-ALREADY-EXISTS (err u90013))
(define-constant ERR-FAILED-TO-GENERATE-PROPOSAL-ID (err u90014))
(define-constant ERR-PROPOSAL-VOTING-INCOMPLETE (err u90015))
(define-constant ERR-PROPOSAL-CANNOT-CLOSE (err u90016))
(define-constant ERR-PROPOSAL-EXPIRED (err u90017))

;; VARIABLES

(define-data-var time-window uint u86400)

;; LP
(define-data-var lp-cap-factor uint u0)
(define-data-var last-lp-bucket-update uint u0)
(define-data-var lp-bucket uint u0) ;; current available lp withdrawal credit

;; Debt
(define-data-var debt-cap-factor uint u0)
(define-data-var last-debt-bucket-update uint u0)
(define-data-var debt-bucket uint u0) ;; current available debt borrowing credit

;; Collateral
(define-map last-collateral-bucket-update principal uint)
(define-map collateral-bucket principal uint) ;; current available collateal withdrawal credit
(define-map collateral-cap-factor principal uint)

;; Governance
(define-data-var next-proposal-nonce uint u0)
(define-map governance-proposal (buff 32) {
  action: uint,
  approve-count: uint,
  deny-count: uint,
  completed: bool,
  expires-at: uint,
})
(define-map proposal-approved-members { proposal-id: (buff 32), member: principal} bool)
(define-map proposal-denied-members { proposal-id: (buff 32), member: principal} bool)
(define-map lp-cap-data (buff 32) uint)
(define-map debt-cap-data (buff 32) uint)
(define-map collateral-cap-data (buff 32) {
    collateral: principal,
    factor: uint
  }
)
(define-map time-window-data (buff 32) uint)

(define-read-only (get-time-window) (var-get time-window))

(define-read-only (get-lp-cap-factor) (var-get lp-cap-factor))
(define-read-only (get-last-lp-bucket-update) (var-get last-lp-bucket-update))
(define-read-only (get-lp-bucket) (var-get lp-bucket))

(define-read-only (get-debt-cap-factor) (var-get debt-cap-factor))
(define-read-only (get-last-debt-bucket-update) (var-get last-debt-bucket-update))
(define-read-only (get-debt-bucket) (var-get debt-bucket))

(define-read-only (get-collateral-cap-factor (collateral <token-trait>)) (default-to u0 (map-get? collateral-cap-factor (contract-of collateral))))
(define-read-only (get-last-collateral-bucket-update (collateral <token-trait>)) (default-to u0 (map-get? last-collateral-bucket-update (contract-of collateral))))
(define-read-only (get-collateral-bucket (collateral <token-trait>)) (default-to u0 (map-get? collateral-bucket (contract-of collateral))))

(define-read-only (min (a uint) (b uint)) (if (> a b) b a ))

(define-read-only (is-governance-member (member principal))
  (contract-call? .meta-governance-v1 is-governance-member member)
)

(define-read-only (get-proposal (proposal-id (buff 32)))
  (map-get? governance-proposal proposal-id)
)

;; PRIVATE FUNCTIONS

(define-private (sync-lp-bucket)
  (let
    (
      (cap-reset-time (var-get time-window))
      (time-now (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (last-ts (var-get last-lp-bucket-update))
      (elapsed (if (is-eq last-ts u0) cap-reset-time (- time-now last-ts)))
      (total-liquidity (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-lp-bucket (/ (* total-liquidity (var-get lp-cap-factor)) SCALING-FACTOR))
      (refill-amount (if (>= elapsed cap-reset-time) 
                     max-lp-bucket
                     (/ (* max-lp-bucket elapsed) cap-reset-time)))
      (current-bucket (var-get lp-bucket))
      (new-bucket-value (min (+ current-bucket refill-amount) max-lp-bucket))
    )
    (print {
      old-lp-bucket-value: (var-get lp-bucket),
      new-lp-bucket-value: new-bucket-value,
      sender: contract-caller,
      action: "sync-lp-bucket"
    })
    (var-set lp-bucket new-bucket-value)
    (var-set last-lp-bucket-update time-now)
    SUCCESS
  )
)

(define-private (sync-debt-bucket)
  (let
    (
      (cap-reset-time (var-get time-window))
      (time-now (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (last-ts (var-get last-debt-bucket-update))
      (elapsed (if (is-eq last-ts u0) cap-reset-time (- time-now last-ts)))
      (total-liquidity (contract-call? .state-v1 get-borrowable-balance))
      (max-debt-bucket (/ (* total-liquidity (var-get debt-cap-factor)) SCALING-FACTOR))
      (refill-amount (if (>= elapsed cap-reset-time) 
                     max-debt-bucket
                     (/ (* max-debt-bucket elapsed) cap-reset-time)))
      (current-bucket (var-get debt-bucket))
      (new-bucket-value (min (+ current-bucket refill-amount) max-debt-bucket))
    )
    (print {
      old-debt-bucket-value: (var-get debt-bucket),
      new-debt-bucket-value: new-bucket-value,
      sender: contract-caller,
      action: "sync-debt-bucket"
    })
    (var-set debt-bucket new-bucket-value)
    (var-set last-debt-bucket-update time-now)
    SUCCESS
  )
)

(define-private (sync-collateral-bucket (collateral <token-trait>))
  (let
    (
      (cap-reset-time (var-get time-window))
      (collateral-token (contract-of collateral))
      (time-now (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (last-ts (default-to u0 (map-get? last-collateral-bucket-update collateral-token)))
      (elapsed (if (is-eq last-ts u0) cap-reset-time (- time-now last-ts)))
      (total-liquidity (unwrap! (contract-call? collateral get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-collateral-bucket (/ (* total-liquidity (default-to u0 (map-get? collateral-cap-factor collateral-token))) SCALING-FACTOR))
      (refill-amount (if (>= elapsed cap-reset-time) 
                     max-collateral-bucket
                     (/ (* max-collateral-bucket elapsed) cap-reset-time)))
      (current-bucket (default-to u0 (map-get? collateral-bucket collateral-token)))
      (new-bucket-value (min (+ current-bucket refill-amount) max-collateral-bucket))
    )
    (print {
      old-collateral-bucket-value: (default-to u0 (map-get? collateral-bucket collateral-token)),
      new-collateral-bucket-value: new-bucket-value,
      sender: contract-caller,
      action: "sync-collateral-bucket"
    })
    (map-set collateral-bucket collateral-token new-bucket-value)
    (map-set last-collateral-bucket-update collateral-token time-now)
    SUCCESS
  )
)

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

(define-private (execute-set-lp-cap (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? lp-cap-data proposal-id))))
    (print {
      action: "execute-set-lp-cap",
      proposal-id: proposal-id,
      old-value: (var-get lp-cap-factor),
      new-value: data
    })
    (var-set lp-cap-factor data)
    SUCCESS
  )
)

(define-private (execute-set-debt-cap (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? debt-cap-data proposal-id))))
    (print {
      action: "execute-set-debt-cap",
      proposal-id: proposal-id,
      old-value: (var-get lp-cap-factor),
      new-value: data
    })
    (var-set debt-cap-factor data)
    SUCCESS
  )
)

(define-private (execute-set-collateral-cap (proposal-id (buff 32)))
  (let (
      (data (unwrap-panic (map-get? collateral-cap-data proposal-id)))
      (collateral (get collateral data))
      (factor (get factor data))
    )
    (print {
      action: "execute-set-collateral-cap",
      proposal-id: proposal-id,
      collateral: collateral,
      old-value: (default-to u0 (map-get? collateral-cap-factor collateral)),
      new-value: factor
    })
    (map-set collateral-cap-factor collateral factor)
    SUCCESS
  )
)

(define-private (execute-set-time-window (proposal-id (buff 32)))
  (let (
      (factor (unwrap-panic (map-get? time-window-data proposal-id)))
    )
    (print {
      action: "execute-set-time-window",
      proposal-id: proposal-id,
      old-value: (var-get time-window),
      new-value: factor
    })
    (var-set time-window factor)
    SUCCESS
  )
)

(define-private (approve-threshold-met (proposal-id (buff 32)) (action uint))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (approve-count (get approve-count proposal))
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
      (percentage (/ (* approve-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (deny-threshold-met (proposal-id (buff 32)) (action uint))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (deny-count (get deny-count proposal))
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
      (percentage (/ (* deny-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (execute-proposal (proposal-id (buff 32)) (action uint))
  (begin
    (asserts! (not (is-eq action ACTION_SET_LP_CAP)) (execute-set-lp-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_DEBT_CAP)) (execute-set-debt-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_COLLATERAL_CAP)) (execute-set-collateral-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_TIME_WINDOW)) (execute-set-time-window proposal-id))
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

;; PUBLIC FUNCTIONS
(define-public (check-daily-lp-cap (amount uint))
  (begin 
    (asserts! (is-eq contract-caller LP-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (var-get lp-cap-factor) u0)
      SUCCESS
      (begin
        (try! (sync-lp-bucket))
        (asserts! (<= amount (var-get lp-bucket)) ERR-DAILY-LP-CAP-EXCEEDED)
        (var-set lp-bucket (- (var-get lp-bucket) amount))
        SUCCESS
      )
    )
  )
)

(define-public (check-daily-debt-cap (amount uint))
  (begin 
    (asserts! (is-eq contract-caller BORROWER-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (var-get debt-cap-factor) u0)
      SUCCESS
      (begin
        (unwrap-panic (sync-debt-bucket))
        (asserts! (<= amount (var-get debt-bucket)) ERR-DAILY-DEBT-CAP-EXCEEDED)
        (var-set debt-bucket (- (var-get debt-bucket) amount))
        SUCCESS
      )
    )
  )
)

(define-public (check-daily-collateral-cap (collateral <token-trait>) (amount uint))
  (let
    (
      (collateral-token (contract-of collateral))
    )
    (asserts! (is-eq contract-caller BORROWER-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (default-to u0 (map-get? collateral-cap-factor collateral-token)) u0) 
      SUCCESS
      (begin 
        (try! (sync-collateral-bucket collateral))
        (asserts! (<= amount (default-to u0 (map-get? collateral-bucket collateral-token))) ERR-DAILY-COLLATERAL-CAP-EXCEEDED)
        (map-set collateral-bucket collateral-token (- (default-to u0 (map-get? collateral-bucket collateral-token)) amount))
        SUCCESS
      )
    )
  )
)

(define-public (initiate-proposal-to-update-param (action uint) (data uint) (collateral (optional <token-trait>)) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        factor: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
      (token (match collateral tkn (some (contract-of tkn)) none))
    )
    (asserts! (or 
      (is-eq action ACTION_SET_DEBT_CAP)
      (is-eq action ACTION_SET_LP_CAP)
      (is-eq action ACTION_SET_COLLATERAL_CAP)
      (is-eq action ACTION_SET_TIME_WINDOW)
    ) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (if (is-eq action ACTION_SET_TIME_WINDOW)
      (map-set time-window-data proposal-id data)
      (if (is-eq action ACTION_SET_DEBT_CAP)
        (map-set debt-cap-data proposal-id data)
        (if (is-eq action ACTION_SET_LP_CAP)
          (map-set lp-cap-data proposal-id data)
          (map-set collateral-cap-data proposal-id { factor: data, collateral: (unwrap-panic token) })
        )
      )
    )
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
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
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
