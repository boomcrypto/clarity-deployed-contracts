;; Title: AGP000 Bootstrap
;; Author: Marvin Janssen / ALEX Dev Team
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, and extensions, and
;; mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "age000 Governance Token", "age001 Proposal Voting",
;; "age002 Emergency Proposals",
;; "age003 Emergency Execute".

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
        (try! (contract-call? .age002-emergency-proposals set-emergency-team-member 'SP1PA7MBFJQP5BJ23BNAM83GWY2T9B3AAGZDCJ9WQ true))
    
		;; Set executive team members.
		(try! (contract-call? .age003-emergency-execute set-executive-team-member 'SP1PA7MBFJQP5BJ23BNAM83GWY2T9B3AAGZDCJ9WQ true))

		;; Set approved-contracts to governance token
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .alex-reserve-pool))
	
		(print "ALEX DAO has risen.")
		(ok true)
	)
)