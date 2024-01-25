;; Title: BDP000 Bootstrap
;; Author: Mike Cohen
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, and extensions, and
;; mints the initial governance tokens.
;; Description:
;; Bootstraps bitcoin-dao for stacks ecosystem voting.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .bitcoin-dao set-extensions
			(list
				{extension: .bde006-treasury, enabled: true}
				{extension: .bde007-snapshot-proposal-voting, enabled: true}
				{extension: .bde008-flexible-funded-submission, enabled: true}
			)
		))

		(print "Bitcoin DAO has risen.")
		(ok true)
	)
)
