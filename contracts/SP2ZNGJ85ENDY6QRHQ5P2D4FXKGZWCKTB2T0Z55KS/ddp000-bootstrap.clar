;; Title: DDP000 Bootstrap
;; Author: rozar.btc
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, 
;; extensions, and mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "DDE000 Governance Token", "DDE001 Proposal Voting", "DDE002 Proposal Submission"

(impl-trait .dao-traits-v0.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .degrants-dao set-extensions
			(list
				{extension: .dde000-governance-token, enabled: true}
				{extension: .dde001-proposal-voting, enabled: true}
				{extension: .dde002-proposal-submission, enabled: true}
				{extension: .dde003-token-vault, enabled: true}
			)		
		))

		;; Mint initial token supply.
		(try! (contract-call? .dde000-governance-token dmg-mint-many
			(list
				{amount: u100000000, recipient: sender}
			)
		))

		(print "Here's to the crazy ones, the misfits, the rebels, the troublemakers, the round pegs in the square holes... the ones who see things differently - they're not fond of rules... You can quote them, disagree with them, glorify or vilify them, but the only thing you can't do is ignore them because they change things... they push the human race forward, and while some may see them as the crazy ones, we see genius, because the ones who are crazy enough to think that they can change the world, are the ones who do.")
		(ok true)
	)
)
