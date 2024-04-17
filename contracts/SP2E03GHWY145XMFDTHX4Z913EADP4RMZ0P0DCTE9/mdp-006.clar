;; This is a boilerplate contract for a proposal 


(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-constant MICRO (pow u10 u2))

(define-public (execute (sender principal))
	(begin

    ;; edit area starts here

    ;; Title: Proposal to change the megaDAO slogan to something else
    ;; Description: The current slogan is outdated and we need to change it to something more modern

    ;; comment out the below try block if your proposal does not involve fund transfers
		;; This will do nothing from mrk

		(print {event: "execute", sender: sender})

    ;; edit area ends here
		(ok true)
	)
)
  