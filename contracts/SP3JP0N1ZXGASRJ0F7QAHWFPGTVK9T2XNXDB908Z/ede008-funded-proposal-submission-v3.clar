;; Title: EDE008 Funded Proposal Submission
;; Author: Marvin Janssen
;; Depends-On: EDE001
;; Synopsis:
;; This extension part of the core of ExecutorDAO. It allows members to
;; bring proposals to the voting phase by funding them with a preset amount
;; of tokens. 
;; Description:
;; The level of funding is determined by a DAO parameter and can be changed by proposal.
;; Any funder can reclaim their stx up to the point the proposal is fully funded and submitted.
;; Proposals can also be marked as refundable in which case a funder can reclaim their stx
;; even after submission (during or after the voting period).
;; This extension provides the ability for the final funding transaction to set a
;; custom majority for voting. This changes the threshold from the 
;; default of 50% to anything up to 100%.

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u3100))
(define-constant err-not-governance-token (err u3101))
(define-constant err-insufficient-balance (err u3102))
(define-constant err-unknown-parameter (err u3103))
(define-constant err-proposal-minimum-start-delay (err u3104))
(define-constant err-proposal-maximum-start-delay (err u3105))
(define-constant err-already-funded (err u3106))
(define-constant err-nothing-to-refund (err u3107))
(define-constant err-refund-not-allowed (err u3108))

(define-map refundable-proposals principal bool)
(define-map funded-proposals principal bool)
(define-map proposal-funding principal uint)
(define-map funding-per-principal {proposal: principal, funder: principal} uint)

(define-map parameters (string-ascii 20) uint)

(map-set parameters "funding-cost" u1000000000) ;; funding cost in uSTX. 1000 STX in this case.
(map-set parameters "proposal-duration" u288) ;; ~4 weeks is 4032 blocks at ~10 minute block time.
(map-set parameters "proposal-start-delay" u6) ;; ~1 hour minimum delay before voting on a proposal can start.

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .ecosystem-dao) (contract-call? .ecosystem-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; Proposals

(define-private (submit-proposal-for-vote (proposal <proposal-trait>) (start-block-height uint) (custom-majority (optional uint)))
	(contract-call? .ede007-snapshot-proposal-voting-v3 add-proposal
		proposal
		{
			start-block-height: start-block-height,
			end-block-height: (+ start-block-height (try! (get-parameter "proposal-duration"))),
			custom-majority: custom-majority,
			proposer: tx-sender ;; change to original submitter
		}
	)
)

;; Parameters

(define-public (set-parameter (parameter (string-ascii 20)) (value uint))
	(begin
		(try! (is-dao-or-extension))
		(try! (get-parameter parameter))
		(ok (map-set parameters parameter value))
	)
)

;; Refunds

(define-public (set-refundable (proposal principal) (refundable bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set refundable-proposals proposal refundable))
	)
)

;; --- Public functions

;; Parameters

(define-read-only (get-parameter (parameter (string-ascii 20)))
	(ok (unwrap! (map-get? parameters parameter) err-unknown-parameter))
)

;; Funding status

(define-read-only (is-proposal-funded (proposal principal))
	(default-to false (map-get? funded-proposals proposal))
)

(define-read-only (get-proposal-funding (proposal principal))
	(default-to u0 (map-get? proposal-funding proposal))
)

(define-read-only (get-proposal-funding-by-principal (proposal principal) (funder principal))
	(default-to u0 (map-get? funding-per-principal {proposal: proposal, funder: funder}))
)

(define-read-only (can-refund (proposal principal) (funder principal))
	(or
		(default-to false (map-get? refundable-proposals proposal))
		(and (not (is-proposal-funded proposal)) (is-eq funder tx-sender))
	)
)

;; Proposals

(define-public (fund (proposal <proposal-trait>) (amount uint) (custom-majority (optional uint)))
	(let
		(
			(proposal-principal (contract-of proposal))
			(current-total-funding (get-proposal-funding proposal-principal))
			(funding-cost (try! (get-parameter "funding-cost")))
			(difference (if (> funding-cost current-total-funding) (- funding-cost current-total-funding) u0))
			(funded (<= difference amount))
			(transfer-amount (if funded difference amount))
		)
		(asserts! (not (is-proposal-funded proposal-principal)) err-already-funded)
		(and (> transfer-amount u0) (try! (stx-transfer? transfer-amount tx-sender .ede006-treasury)))
		(map-set funding-per-principal {proposal: proposal-principal, funder: tx-sender} (+ (get-proposal-funding-by-principal proposal-principal tx-sender) transfer-amount))
		(map-set proposal-funding proposal-principal (+ current-total-funding transfer-amount))
		(asserts! funded (ok false))
		(map-set funded-proposals proposal-principal true)
		(submit-proposal-for-vote proposal (+ block-height (try! (get-parameter "proposal-start-delay"))) custom-majority)
	)
)

(define-public (refund (proposal principal) (funder (optional principal)))
	(let
		(
			(recipient (default-to tx-sender funder))
			(refund-amount (get-proposal-funding-by-principal proposal recipient))
		)
		(asserts! (> refund-amount u0) err-nothing-to-refund)
		(asserts! (can-refund proposal recipient) err-refund-not-allowed)
		(map-set funding-per-principal {proposal: proposal, funder: recipient} u0)
		(map-set proposal-funding proposal (- (get-proposal-funding proposal) refund-amount))
		(contract-call? .ede006-treasury stx-transfer refund-amount recipient none)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
