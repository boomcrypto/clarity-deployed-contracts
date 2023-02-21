;; Title: CCD001 Direct Execute
;; Version: 1.0.0
;; Summary: Allows a small number of very trusted principals to immediately execute a proposal once a super majority is reached. 
;; Description: An extension contract for the bootstrapping period of a DAO. It temporarily gives trusted principals the ability to perform a "direct execution"; meaning, they can immediately execute a proposal with the required signals. The Direct Execute extension is set with a sunset period of ~6 months from deployment. Approvers, the parameters, and sunset period may be changed by means of a future proposal.

;; TRAITS

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u1000))
(define-constant ERR_NOT_APPROVER (err u1001))
(define-constant ERR_SUNSET_REACHED (err u1002))
(define-constant ERR_SUNSET_IN_PAST (err u1003))

;; DATA VARS

(define-data-var sunsetBlock uint (+ block-height u25920))
(define-data-var signalsRequired uint u1)

;; DATA MAPS

(define-map Approvers principal bool)
(define-map ApproverSignals { proposal: principal, approver: principal } bool)
(define-map SignalCount principal uint)

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (set-sunset-block (height uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (> height block-height) ERR_SUNSET_IN_PAST)
    (print {
      event: "set-sunset-block",
      height: height
    })
    (ok (var-set sunsetBlock height))
  )
)

(define-public (set-approver (who principal) (status bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "set-approver",
      who: who,
      status: status
    })
    (ok (map-set Approvers who status))
  )
)

(define-public (set-signals-required (signals uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (> signals u0) ERR_UNAUTHORIZED)
    (print {
      event: "set-signals-required",
      signals: signals
    })
    (ok (var-set signalsRequired signals))
  )
)

(define-public (direct-execute (proposal <proposal-trait>))
  (let
    (
      (proposalPrincipal (contract-of proposal))
      (signals (+ (get-signals proposalPrincipal) (if (has-signalled proposalPrincipal tx-sender) u0 u1)))
    )
    (asserts! (is-approver tx-sender) ERR_NOT_APPROVER)
    (asserts! (< block-height (var-get sunsetBlock)) ERR_SUNSET_REACHED)
    (and (>= signals (var-get signalsRequired))
      (try! (contract-call? .base-dao execute proposal tx-sender))
    )
    (map-set ApproverSignals {proposal: proposalPrincipal, approver: tx-sender} true)
    (map-set SignalCount proposalPrincipal signals)
    (ok signals)
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-approver (who principal))
  (default-to false (map-get? Approvers who))
)

(define-read-only (has-signalled (proposal principal) (who principal))
  (default-to false (map-get? ApproverSignals {proposal: proposal, approver: who}))
)

(define-read-only (get-signals-required)
  (var-get signalsRequired)
)

(define-read-only (get-signals (proposal principal))
  (default-to u0 (map-get? SignalCount proposal))
)
