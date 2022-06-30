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

(define-constant ERR_UNAUTHORIZED (err u2800))
(define-constant ERR_NOT_EXECUTIVE_TEAM_MEMBER (err u2801))
(define-constant ERR_ALREADY_EXECUTED (err u2802))
(define-constant ERR_SUNSET_HEIGHT_REACHED (err u2803))
(define-constant ERR_SUNSET_HEIGHT_IN_PAST (err u2804))

(define-map ExecutiveTeam principal bool)
(define-map ExecutiveActionSignals {proposal: principal, teamMember: principal} bool)
(define-map ExecutiveActionSignalCount principal uint)

(define-data-var executiveSignalsRequired uint u3) ;; signals required for an executive action
(define-data-var executiveTeamSunsetHeight uint (+ block-height u13140)) ;; ~3 months from deploy time

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; --- Internal DAO functions

(define-public (set-executive-team-sunset-height (height uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> height block-height) ERR_SUNSET_HEIGHT_IN_PAST)
		(ok (var-set executiveTeamSunsetHeight height))
	)
)

(define-public (set-executive-team-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set ExecutiveTeam who member))
	)
)

(define-public (set-signals-required (newRequirement uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set executiveSignalsRequired newRequirement))
	)
)

;; --- Public functions

(define-read-only (is-executive-team-member (who principal))
	(default-to false (map-get? ExecutiveTeam who))
)

(define-read-only (has-signaled (proposal principal) (who principal))
	(default-to false (map-get? ExecutiveActionSignals {proposal: proposal, teamMember: who}))
)

(define-read-only (get-signals-required)
	(var-get executiveSignalsRequired)
)

(define-read-only (get-signals (proposal principal))
	(default-to u0 (map-get? ExecutiveActionSignalCount proposal))
)

(define-public (executive-action (proposal <proposal-trait>))
	(let
		(
			(proposalPrincipal (contract-of proposal))
			(signals (+ (get-signals proposalPrincipal) (if (has-signaled proposalPrincipal tx-sender) u0 u1)))
		)
		(asserts! (is-executive-team-member tx-sender) ERR_NOT_EXECUTIVE_TEAM_MEMBER)
		(asserts! (is-none (contract-call? .mega-dao executed-at proposal)) ERR_ALREADY_EXECUTED)
		(asserts! (< block-height (var-get executiveTeamSunsetHeight)) ERR_SUNSET_HEIGHT_REACHED)
		(and (>= signals (var-get executiveSignalsRequired))
			(try! (contract-call? .mega-dao execute proposal tx-sender))
		)
		(map-set ExecutiveActionSignals {proposal: proposalPrincipal, teamMember: tx-sender} true)
		(map-set ExecutiveActionSignalCount proposalPrincipal signals)
		(ok signals)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)