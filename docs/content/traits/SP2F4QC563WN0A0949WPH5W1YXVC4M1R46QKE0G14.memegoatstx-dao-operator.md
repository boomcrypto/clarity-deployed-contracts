---
title: "Trait memegoatstx-dao-operator"
draft: true
---
```
;;
;; MEMEGOAT OPERATORS
;;
(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-UNAUTHORISED (err u1000))
(define-constant ERR-NOT-OPERATOR (err u1001))
(define-constant ERR-ALREADY-APPROVED (err u1002))
(define-constant ERR-PROPOSAL-EXPIRED (err u1003))
(define-constant ERR-PROPOSAL-NOT-ENDED (err u1004))
(define-constant ERR-UNKNOWN-PROPOSAL (err u1005))
(define-constant ERR-REUSED-PROPOSAL (err u1006))

;; STORAGE
(define-data-var proposal-duration uint u0)
(define-data-var approval-threshold int 0)
(define-data-var votes-threshold uint u0)
(define-data-var operators-update-height uint burn-block-height)
(define-map operators principal bool)
(define-map proposals principal { proposed-at: uint, approvals: int, executed: bool })
(define-map proposal-approvals { proposal: principal, operator: principal } uint)

;; READ-ONLY CALLS
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-UNAUTHORISED))
)

(define-read-only (is-operator)
	(ok (asserts! (default-to false (map-get? operators tx-sender)) ERR-NOT-OPERATOR))
)

(define-read-only (get-votes-threshold)
	(ok (var-get votes-threshold))
)

(define-read-only (get-approval-threshold)
	(ok (var-get approval-threshold))
)

(define-read-only (get-proposal-duration)
	(ok (var-get proposal-duration))
)

;; PUBLIC CALLS
(define-public (trigger (proposal <proposal-trait>))
	(let (
		(proposal-principal (contract-of proposal))
		(proposal-data (unwrap! (map-get? proposals proposal-principal) ERR-UNKNOWN-PROPOSAL))
		(proposal-height (get proposed-at proposal-data))
		(approvals (+ (get approvals proposal-data) 1))
		(approval-threshold-met (>= approvals (var-get approval-threshold)))
		(proposal-votes (try! (contract-call? proposal get-votes)))
		(total-votes (try! (contract-call? proposal get-total-votes)))
		(vote-threshold-met (>= total-votes (var-get votes-threshold)))
		(highest-voted (get-highest-votes proposal-votes))
		)
		(try! (is-operator))
		(asserts! (check-validity proposal-height) ERR-PROPOSAL-EXPIRED)
		(asserts! (check-proposal-ended proposal-height) ERR-PROPOSAL-NOT-ENDED)
		(asserts! (<
			(default-to u0 (map-get? proposal-approvals { proposal: proposal-principal, operator: tx-sender }))
			proposal-height)
			ERR-ALREADY-APPROVED
		)
		(map-set proposal-approvals { proposal: proposal-principal, operator: tx-sender } burn-block-height)
		(map-set proposals proposal-principal (merge proposal-data {approvals: approvals, executed: (and approval-threshold-met vote-threshold-met)}))
		(if (and approval-threshold-met vote-threshold-met)
			(as-contract (contract-call? .memegoat-community-dao execute proposal tx-sender (get id highest-voted)))
			(ok false)
		)
	)
)

(define-public (propose (proposal <proposal-trait>))
	(let ((proposal-principal (contract-of proposal)))
		(try! (is-operator))
		(asserts! (is-none (map-get? proposals proposal-principal)) ERR-REUSED-PROPOSAL)
		(map-set proposals proposal-principal { proposed-at: burn-block-height, approvals: 0, executed: false })
		(as-contract (contract-call? proposal activate (var-get proposal-duration)))
	)
)

(define-public (set-operators (entries (list 20 {operator: principal, enabled: bool})))
	(begin
		(try! (is-dao-or-extension))
		(var-set operators-update-height burn-block-height)
		(ok (map set-operator entries))
	)
)

(define-public (set-approval-threshold (threshold int))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> threshold 0) ERR-UNAUTHORISED)
		(var-set operators-update-height burn-block-height)
		(ok (var-set approval-threshold threshold))
	)
)

(define-public (set-votes-threshold (threshold uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> threshold u0) ERR-UNAUTHORISED)
		(var-set operators-update-height burn-block-height)
		(ok (var-set votes-threshold threshold))
	)
)

(define-public (set-proposal-duration (duration uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> duration u0) ERR-UNAUTHORISED)
		(var-set operators-update-height burn-block-height)
		(ok (var-set proposal-duration duration))
	)
)

;; PRIVATE CALLS
(define-private (set-operator (entry {operator: principal, enabled: bool}))
	(map-set operators (get operator entry) (get enabled entry))
)

(define-private (check-proposal-ended (proposed-at uint))
	(> burn-block-height (+ proposed-at (var-get proposal-duration)))
)

(define-private (check-validity (proposed-at uint))
	(< (var-get operators-update-height) proposed-at)
)

(define-private (get-highest-votes 
	(votes 
		{
			op1: {id: uint, votes: uint}, op2: {id: uint, votes: uint}, 
			op3: {id: uint, votes: uint}, op4: {id: uint, votes: uint}
		} 
	)
)
	(fold get-highest-iter (list (get op1 votes) (get op2 votes) (get op3 votes) (get op4 votes)) {id: u0, votes: u0})
)

(define-private (get-highest-iter (next {id: uint, votes: uint}) (highest {id: uint, votes: uint}))
  (if (> (get votes highest) (get votes next))
		highest
		next
  )
)

;; --- Extension callback

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true)
)
```
