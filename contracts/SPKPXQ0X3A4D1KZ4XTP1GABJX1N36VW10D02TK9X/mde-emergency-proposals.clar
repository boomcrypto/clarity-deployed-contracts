;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     _____  _____________  ______________  _  __           
;;    / __/ |/_/_  __/ __/ |/ / __/  _/ __ \/ |/ /           
;;   / _/_>  <  / / / _//    /\ \_/ // /_/ /    /            
;;  /___/_/|_| /_/ /___/_/|_/___/___/\____/_/|_/             

(use-trait proposal-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

(define-constant ERR_UNAUTHORIZED (err u2700))
(define-constant ERR_NOT_EMERGENCY_TEAM_MEMBER (err u2701))
(define-constant ERR_SUNSET_HEIGHT_REACHED (err u2702))
(define-constant ERR_SUNSET_HEIGHT_IN_PAST (err u2703))

(define-data-var emergencyProposalDuration uint u144) ;; ~12 hours
(define-data-var emergencyTeamSunsetHeight uint (+ block-height u13140)) ;; ~3 months from deploy time

(define-map EmergencyTeam principal bool)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; --- Internal DAO functions

(define-public (set-emergency-proposal-duration (duration uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set emergencyProposalDuration duration))
	)
)

(define-public (set-emergency-team-sunset-height (height uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> height block-height) ERR_SUNSET_HEIGHT_IN_PAST)
		(ok (var-set emergencyTeamSunsetHeight height))
	)
)

(define-public (set-emergency-team-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set EmergencyTeam who member))
	)
)

;; --- Public functions

(define-read-only (is-emergency-team-member (who principal))
	(default-to false (map-get? EmergencyTeam who))
)

(define-public (emergency-propose (proposal <proposal-trait>))
	(begin
		(asserts! (is-emergency-team-member tx-sender) ERR_NOT_EMERGENCY_TEAM_MEMBER)
		(asserts! (< block-height (var-get emergencyTeamSunsetHeight)) ERR_SUNSET_HEIGHT_REACHED)
		(contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-proposal-voting add-proposal proposal
			{
				startBlockHeight: block-height,
				endBlockHeight: (+ block-height (var-get emergencyProposalDuration)),
				proposer: tx-sender
			}
		)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)