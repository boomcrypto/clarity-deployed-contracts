;; Title: DMP000 Bootstrap
;; Author: Ross Ragsdale
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, 
;; extensions, and mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "DME000 Governance Token", "DME001 Proposal Voting",
;; "DME002 Proposal Submission", "DME003 Emergency Proposals",
;; "DME004 Emergency Execute".

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .dungeon-master set-extensions
			(list
				{extension: .dme000-governance-token, enabled: true}
				{extension: .dme001-proposal-voting, enabled: true}
				{extension: .dme002-proposal-submission, enabled: true}
				{extension: .dme003-emergency-proposals, enabled: true}
				{extension: .dme004-emergency-execute, enabled: true}
			)
		))

		;; Set emergency team members.
		(try! (contract-call? .dme003-emergency-proposals set-emergency-team-member 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ true))

		;; Set executive team members.
		(try! (contract-call? .dme004-emergency-execute set-executive-team-member 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ true))

		;; Mint initial token supply.
		(try! (contract-call? .dme000-governance-token dmg-mint-many
			(list
				{amount: u2000, recipient: sender}
				{amount: u1000, recipient: 'SP3TW60M88XFKRT9E5QXKA3RW7YZCH2G93NJ8EDAK}
				{amount: u1000, recipient: 'SP2T424HFWWMSYMWRZV6J3PJ2K36X3HWZ7S0KTXZ3}
			)
		))

		(print "You are not entering this world in the usual manner, for you are setting forth to be a Dungeon Master. Certainly there are stout fighters, mighty magic-users, wily thieves, and courageous clerics who will make their mark in the magical lands of bitgear adventure. You however, are above even the greatest of these, for as DM you are to become the Shaper of the Cosmos. It is you who will give form and content to the all the universe. You will breathe life into the stillness, giving meaning and purpose to all the actions which are to follow.")
		(ok true)
	)
)
