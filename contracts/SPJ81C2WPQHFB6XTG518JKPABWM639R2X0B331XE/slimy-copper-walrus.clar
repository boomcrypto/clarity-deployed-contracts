
;; TRAITS

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)
(use-trait proposal-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u3000))
(define-constant ERR_NOT_APPROVER (err u3001))

;; DATA MAPS AND VARS

;; signals required for an action
(define-data-var signalsRequired uint u1)

;; approver information
(define-map Approvers
  principal ;; address
  bool      ;; status
)
(define-map ApproverSignals
  {
    proposal: principal,
    approver: principal
  }
  bool ;; yes/no
)
(define-map SignalCount
  principal ;; proposal
  uint      ;; signals
)

;; Authorization Check

(define-public (is-dao-or-extension)
  (ok (asserts!
    (or
      (is-eq tx-sender 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.major-orange-snake)
      (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.major-orange-snake is-extension contract-caller))
    ERR_UNAUTHORIZED
  ))
)

;; Internal DAO functions

(define-public (set-approver (who principal) (status bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set Approvers who status))
  )
)

(define-public (set-signals-required (newRequirement uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set signalsRequired newRequirement))
  )
)

;; Public Functions

(define-read-only (is-approver (who principal))
  (default-to false (map-get? Approvers who))
)

(define-read-only (has-signaled (proposal principal) (who principal))
  (default-to false (map-get? ApproverSignals {proposal: proposal, approver: who}))
)

(define-read-only (get-signals-required)
  (var-get signalsRequired)
)

(define-read-only (get-signals (proposal principal))
  (default-to u0 (map-get? SignalCount proposal))
)

(define-public (direct-execute (proposal <proposal-trait>))
  (let
    (
      (proposalPrincipal (contract-of proposal))
      (signals (+ (get-signals proposalPrincipal) (if (has-signaled proposalPrincipal tx-sender) u0 u1)))
    )
    (asserts! (is-approver tx-sender) ERR_NOT_APPROVER)
    (and (>= signals (var-get signalsRequired))
      (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.major-orange-snake execute proposal tx-sender))
    )
    (map-set ApproverSignals {proposal: proposalPrincipal, approver: tx-sender} true)
    (map-set SignalCount proposalPrincipal signals)
    (ok signals)
  )
)

;; Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
