(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-not-operator (err u1001))
(define-constant err-already-signalled (err u1002))
(define-constant err-proposal-expired (err u1003))
(define-constant err-unknown-proposal (err u1004))
(define-constant err-reused-proposal (err u1005))

(define-constant proposal-validity-period u144)

(define-data-var proposal-threshold int 1)
(define-data-var operators-update-height uint burn-block-height)

(define-map operators principal bool)
(define-map proposals principal { proposed-at: uint, signals: int, executed: bool })
(define-map proposal-signals { proposal: principal, operator: principal } uint)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised))
)

(define-read-only (is-operator)
	(ok (asserts! (default-to false (map-get? operators tx-sender)) err-not-operator))
)

(define-private (set-operator (entry {operator: principal, enabled: bool}))
	(map-set operators (get operator entry) (get enabled entry))
)

;; operators

(define-private (check-validity (proposed-at uint))
	(and
		(< burn-block-height (+ proposed-at proposal-validity-period))
		(< (var-get operators-update-height) proposed-at)
	)
)

(define-public (signal (proposal <proposal-trait>) (for bool))
	(let (
		(proposal-principal (contract-of proposal))
		(proposal-data (unwrap! (map-get? proposals proposal-principal) err-unknown-proposal))
		(proposal-height (get proposed-at proposal-data))
		(signals (+ (get signals proposal-data) (if for 1 -1)))
		(threshold-met (>= signals (var-get proposal-threshold)))
		)
		(try! (is-operator))
		(asserts! (check-validity proposal-height) err-proposal-expired)
		(asserts! (<
			;; operator can signal again on a proposal that was resubmitted
			(default-to u0 (map-get? proposal-signals { proposal: proposal-principal, operator: tx-sender }))
			proposal-height)
			err-already-signalled
		)
		(map-set proposal-signals { proposal: proposal-principal, operator: tx-sender } burn-block-height)
		(map-set proposals proposal-principal (merge proposal-data {signals: signals, executed: threshold-met}))
		(if threshold-met
			(contract-call? .lisa-dao execute proposal tx-sender)
			(ok false)
		)
	)
)

(define-public (propose (proposal <proposal-trait>))
	(let ((proposal-principal (contract-of proposal)))
		(try! (is-operator))
		(asserts! (match (map-get? proposals proposal-principal)
			;; proposal can be resubmitted if it was not executed and it expired
			data (not (or (get executed data) (check-validity (get proposed-at data))))
			true)
			err-reused-proposal
		)
		(map-set proposals proposal-principal { proposed-at: burn-block-height, signals: 0, executed: false })
		(signal proposal true)
	)
)

;; DAO

(define-public (set-operators (entries (list 20 {operator: principal, enabled: bool})))
	(begin
		(try! (is-dao-or-extension))
		(var-set operators-update-height burn-block-height)
		(ok (map set-operator entries))
	)
)

(define-public (set-proposal-threshold (threshold int))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> threshold 0) err-unauthorised)
		(var-set operators-update-height burn-block-height)
		(ok (var-set proposal-threshold threshold))
	)
)