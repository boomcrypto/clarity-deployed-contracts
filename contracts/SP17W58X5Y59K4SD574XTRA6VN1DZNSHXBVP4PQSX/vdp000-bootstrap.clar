;; VibesDAO using ExecutorDAO framework. 
;; Version: 0.1.0

;; Title: VDP000 Bootstrap
;; Description: This contract is used to bootstrap the VibesDAO.

;; ------------------------------------------------
;; All the principal IDs are for testnet.
;; ------------------------------------------------

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .vibeDAO set-extensions
			(list
				{extension: .vde000-treasury, enabled: true}
				{extension: .vde001-proposal-voting, enabled: true}
				{extension: .vde002-proposal-submission, enabled: true}
				{extension: .vde003-emergency-proposals, enabled: true}
				{extension: .vde004-emergency-execute, enabled: true}
				{extension: .vde005-council, enabled: true}
			)
		))

		
		;; Set emergency team members.
		(try! (contract-call? .vde003-emergency-proposals set-emergency-team-member 'SP2P9T9B8WEKQNMNA6DRMRW20KFASA2S1ESD248HZ true))
		(try! (contract-call? .vde003-emergency-proposals set-emergency-team-member 'SP3GKTQDK9KXJ3J7JH9KCA24HSHJM74GFCPX3T80S  true))
		(try! (contract-call? .vde003-emergency-proposals set-emergency-team-member 'SP7F9EMG5A9BKVBG8N6Q2KD2NQNGXMPB5PFG3E77 true))

		;; Set executive team members.
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'SP2P9T9B8WEKQNMNA6DRMRW20KFASA2S1ESD248HZ true))
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'SP3GKTQDK9KXJ3J7JH9KCA24HSHJM74GFCPX3T80S true))
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'SP7F9EMG5A9BKVBG8N6Q2KD2NQNGXMPB5PFG3E77 true))
		(try! (contract-call? .vde004-emergency-execute set-signals-required u2)) ;; signal from 2 out of 3 team members requied.

		(try! (contract-call? .vde005-council set-council-member 'SP2P9T9B8WEKQNMNA6DRMRW20KFASA2S1ESD248HZ true))
		(try! (contract-call? .vde005-council set-council-member 'SP3GKTQDK9KXJ3J7JH9KCA24HSHJM74GFCPX3T80S true))
		(try! (contract-call? .vde005-council set-council-member 'SP7F9EMG5A9BKVBG8N6Q2KD2NQNGXMPB5PFG3E77 true))
		(try! (contract-call? .vde005-council set-approvals-required u2)) ;; approvals from 2 out of 3 team members requied.
		(try! (contract-call? .vde005-council set-disapprovals-required u2)) ;; disapprovals from 2 out of 3 team members requied.


		(print "VibesDAO is live now.")
		(ok true)
	)
)