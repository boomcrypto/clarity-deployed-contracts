;; Title: GOAT Execute Implemented from AGE003 Emergency Execute
;; Author: Marvin Janssen / ALEX Dev Team
;; Depends-On: 
;; Synopsis:
;; This extension allows a small number of very trusted principals to immediately
;; execute a proposal once a super majority is reached.
;; Description:
;; An extension meant for the bootstrapping period of a DAO. It temporarily gives
;; some very trusted principals the ability to perform an "executive action";
;; meaning, they can skip the voting process to immediately executive a proposal.
;; The Emergency Executive extension has a sunset period of ~14 days from deploy
;; time. Executive Team members, the parameters, and sunset period may be changed
;; by means of a future proposal.

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant ERR-UNAUTHORISED (err u3000))
(define-constant ERR-NOT-EXECUTIVE-TEAM-MEMBER (err u3001))
(define-constant ERR-ALREADY-EXECUTED (err u3002))
(define-constant ERR-SUNSET-HEIGHT-REACHED (err u3003))
(define-constant ERR-SUNSET-HEIGHT-IN-PAST (err u3004))

;; STORAGE
(define-data-var executive-team-sunset-height uint (+ block-height u2016)) ;; ~14 days deploy time
(define-map executive-team principal bool)
(define-map executive-action-approvals {proposal: principal, team-member: principal} bool)
(define-map executive-action-approval-count principal uint)
(define-data-var executive-approvals-required uint u1) ;; approvals required for an executive action.

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-UNAUTHORISED))
)

;; --- Internal DAO functions

(define-public (set-executive-team-sunset-height (height uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> height block-height) ERR-SUNSET-HEIGHT-IN-PAST)
		(ok (var-set executive-team-sunset-height height))
	)
)

(define-public (set-executive-team-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set executive-team who member))
	)
)

(define-public (set-approvals-required (new-requirement uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set executive-approvals-required new-requirement))
	)
)

;; --- Public functions

(define-read-only (is-executive-team-member (who principal))
	(default-to false (map-get? executive-team who))
)

(define-read-only (has-approved (proposal principal) (who principal))
	(default-to false (map-get? executive-action-approvals {proposal: proposal, team-member: who}))
)

(define-read-only (get-approvals-required)
	(var-get executive-approvals-required)
)

(define-read-only (get-approvals (proposal principal))
	(default-to u0 (map-get? executive-action-approval-count proposal))
)

(define-public (executive-action (proposal <proposal-trait>))
	(let
		(
			(proposal-principal (contract-of proposal))
			(approvals (+ (get-approvals proposal-principal) (if (has-approved proposal-principal tx-sender) u0 u1)))
		)
		(asserts! (is-executive-team-member tx-sender) ERR-NOT-EXECUTIVE-TEAM-MEMBER)
		(asserts! (< block-height (var-get executive-team-sunset-height)) ERR-SUNSET-HEIGHT-REACHED)
		(and (>= approvals (var-get executive-approvals-required))
			(try! (contract-call? .memegoat-community-dao execute proposal tx-sender u0))
		)
		(map-set executive-action-approvals {proposal: proposal-principal, team-member: tx-sender} true)
		(map-set executive-action-approval-count proposal-principal approvals)
		(ok approvals)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 2048)))
	(ok true)
)

;; --- Constructor Executive Members
(begin 
	(map-set executive-team 'SP3TMS5DMKFXM9K1PZ3EMM0PDESV44GVT6C5CTAA0 true)
	(map-set executive-team 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14 true)
	(map-set executive-team 'SP14693HDB0S5W5J3EA2FWAQAASAC3E41WH739JPW true)
	(var-set executive-approvals-required u2)
	(ok true)
)