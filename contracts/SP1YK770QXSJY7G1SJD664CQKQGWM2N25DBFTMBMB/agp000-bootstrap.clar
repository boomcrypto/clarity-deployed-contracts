
;; Author: Marvin Janssen
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, and extensions, and
;; mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "age000 Governance Token", "age001 Proposal Voting",
;; "age002 Proposal Submission", "age003 Emergency Proposals",
;; "age004 Emergency Execute".

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .executor-dao set-extensions
			(list
				{extension: .age000-governance-token, enabled: true}
				{extension: .age001-proposal-voting, enabled: true}
				{extension: .age002-emergency-proposals, enabled: true}
				{extension: .age003-emergency-execute, enabled: true}
			)
		))

		;; Set emergency team members.
		(try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SP1YK770QXSJY7G1SJD664CQKQGWM2N25DBFTMBMB true))
		(try! (contract-call? .age002-emergency-proposals set-emergency-team-sunset-height (+ block-height u26280))) ;; ~6 months
		(try! (contract-call? .age002-emergency-proposals set-emergency-proposal-duration u1440)) ;; ~10 days

		;; Set executive team members.
		(try! (contract-call? .age003-emergency-execute set-executive-team-member 'SP1YK770QXSJY7G1SJD664CQKQGWM2N25DBFTMBMB true))
		(try! (contract-call? .age003-emergency-execute set-signals-required u1))
		(try! (contract-call? .age003-emergency-execute set-executive-team-sunset-height (+ block-height u13140))) ;; ~3 months

		;; Set approved-contracts to governance token
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .alex-reserve-pool))
	
		(print "ALEX DAO has risen.")
		(ok true)
	)
)
