;; Title: BDP000 Manage DAO
;; Author: Mike Cohen
;; Synopsis:
;; Reenables core executions and proposals.
;; Description:
;; This proposal makes bitcoin DAO manageable for running stacks votes
;; Public ability to make proposals is removed for now to prevent
;; potential spam proposals from disrupting community votes. Core
;; execution is reintroduced and the sunset period switched off to
;; facilitate DAO management in the context of community voting.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .bitcoin-dao set-extensions
			(list
				{extension: .bde001-proposal-voting, enabled: true}
				{extension: .bde002-proposal-submission, enabled: false}
				{extension: .bde003-core-proposals, enabled: true}
				{extension: .bde004-core-execute, enabled: true}
				{extension: .bde007-snapshot-proposal-voting, enabled: false}
				{extension: .bde008-flexible-funded-submission, enabled: false}
			)
		))
				;; Set emergency team members.
		(try! (contract-call? .bde003-core-proposals set-core-team-member 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z true))
		(try! (contract-call? .bde003-core-proposals set-core-team-member 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6 true))

		;; Set executive team members.
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z true))
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6 true))
		(try! (contract-call? .bde004-core-execute set-signals-required u1)) ;; signal from 1 out of 42 team members required.

		(print "Bitcoin DAO has been reconfigured.")
		(ok true)
	)
)
