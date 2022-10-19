;; Title: EDP000 Bootstrap
;; Author: Clarity Lab (Mike Cohen, Marvin Janssen)
;; Synopsis: Bootstraps the DAO
;; Description:
;; The bootstrap proposal sets the starting conditions for the DAO. Activates
;; initial extensions and sets the DAOs parameters and the executive team.


(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .ecosystem-dao set-extensions
			(list
				{extension: .ede004-emergency-execute, enabled: true}
				{extension: .ede006-treasury, enabled: true}
				{extension: .ede007-snapshot-proposal-voting-v2, enabled: true}
				{extension: .ede008-funded-proposal-submission-v2, enabled: true}
			)
		))

		;; Set executive parameters.
		(try! (contract-call? .ede004-emergency-execute set-executive-team-member 'SPND1YC648T2SDW26NACCB8GAY8KSZJPNBS26GFD true))
		(try! (contract-call? .ede004-emergency-execute set-executive-team-member 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z true))
		(try! (contract-call? .ede004-emergency-execute set-executive-team-member 'SP3YZYAR5T90J6GCZ9M0338WMT5MTZ7G671JED9P0 true))
		(try! (contract-call? .ede004-emergency-execute set-executive-team-sunset-height u13140)) 
		(try! (contract-call? .ede004-emergency-execute set-signals-required u2))

		;; Set dao parameters.
		;; (try! (contract-call? .ede008-funded-proposal-submission-v2 set-parameter "proposal-duration" u2016)) 
		(try! (contract-call? .ede008-funded-proposal-submission-v2 set-parameter "funding-cost" u10000000)) 

		(print "Ecosystem DAO has risen.")
		(ok true)
	)
)
