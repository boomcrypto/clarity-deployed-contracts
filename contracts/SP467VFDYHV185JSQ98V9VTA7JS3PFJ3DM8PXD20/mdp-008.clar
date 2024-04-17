;; This is a boilerplate contract for a proposal 


(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-constant MICRO (pow u10 u2))

(define-public (execute (sender principal))
	(begin

    ;; The Pandemonium

    ;; Title: Proposal to request funding for further development and maintenance of Parrot Radio for the benefit of all of Stacks
    ;; Description: Parrot Radio app is free to use for all Stacks addresses. You can listen to, curate, and view your audio and audiovisual stx nft's, as well as view all your stx nfts in a gallery. As well as share them to social media apps and discord straight from the app. I.e. all your megapont assets.

    ;; comment out the below try block if your proposal does not involve fund transfers
		(try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-vault transfer (* MICRO u100) 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6))

		(print {event: "execute", sender: sender})

    ;; edit area ends here
		(ok true)
	)
)
  