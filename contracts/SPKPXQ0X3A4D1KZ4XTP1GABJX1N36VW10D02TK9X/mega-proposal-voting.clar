;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     _____  _____________  ______________  _  __           
;;    / __/ |/_/_  __/ __/ |/ / __/  _/ __ \/ |/ /           
;;   / _/_>  <  / / / _//    /\ \_/ // /_/ /    /            
;;  /___/_/|_| /_/ /___/_/|_/___/___/\____/_/|_/             

(use-trait sip010-ft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip010-ft-trait.sip010-ft-trait)
(use-trait proposal-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

(define-constant ERR_UNAUTHORIZED (err u2500))
(define-constant ERR_NOT_GOVERNANCE_TOKEN (err u2501))
(define-constant ERR_PROPOSAL_ALREADY_EXECUTED (err u2502))
(define-constant ERR_PROPOSAL_ALREADY_EXISTS (err u2503))
(define-constant ERR_UNKNOWN_PROPOSAL (err u2504))
(define-constant ERR_PROPOSAL_ALREADY_ACTIVE (err u2505))
(define-constant ERR_PROPOSAL_ALREADY_CONCLUDED (err u2506))
(define-constant ERR_PROPOSAL_INACTIVE (err u2507))
(define-constant ERR_PROPOSAL_NOT_CONCLUDED (err u2508))
(define-constant ERR_NO_VOTES_TO_RETURN (err u2509))
(define-constant ERR_QUORUM_NOT_MET (err u2510))
(define-constant ERR_END_BLOCK_HEIGHT_NOT_REACHED (err u2511))
(define-constant ERR_DISABLED (err u2512))
(define-constant ERR_INSUFFICIENT_WEIGHT (err u2513))
(define-constant ERR_ALREADY_VOTED (err u2514))
(define-constant ERR_UNKNOWN_PARAMETER (err u2515))
(define-constant ERR_NOT_TOKEN_OWNER (err u2516))
(define-constant ERR_CANT_DELEGATE_TO_SELF (err u2517))
(define-constant ERR_NOT_ENOUGH_TOKENS (err u2518))
(define-constant ERR_INVALID_WEIGHT (err u2519))
(define-constant ERR_MUST_REVOKE_CURRENT_DELEGATION (err u2520))
(define-constant ERR_NO_DELEGATION_TO_REVOKE (err u2521))
(define-constant ERR_NOT_DELEGATE (err u2522))

(define-constant MICRO (pow u10 u2))

(define-data-var governanceTokenPrincipal principal 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega)
(define-data-var proposalSize uint u0)

(define-map Proposals
	principal
	{
		votesFor: uint,
		votesAgainst: uint,
		startBlockHeight: uint,
		endBlockHeight: uint,
		concluded: bool,
		passed: bool,
		proposer: principal
	}
)
(define-map proposalList uint principal)
(define-map MemberTotalVotes {proposal: principal, voter: principal, governanceToken: principal} uint)
(define-map parameters (string-ascii 34) uint)

(map-set parameters "voteThreshold" u1) ;; Hold at least 1 Mega token to vote
(map-set parameters "quorumThreshold" u12500) ;; 5% of 250k initially distributed to Megapoont holders required for quorum
(map-set parameters "executionDelay" u288) ;; Delay execution of proposal by ~2 days

(define-map Delegates principal principal)
(define-map Delegators principal bool)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; --- Internal DAO functions

(define-public (set-parameter (parameter (string-ascii 34)) (value uint))
	(begin
		(try! (is-dao-or-extension))
		(try! (get-parameter parameter))
		(ok (map-set parameters parameter value))
	)
)

(define-public (add-proposal (proposal <proposal-trait>) (data {startBlockHeight: uint, endBlockHeight: uint, proposer: principal}))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (is-none (contract-call? .mega-dao executed-at proposal)) ERR_PROPOSAL_ALREADY_EXECUTED)
		(var-set proposalSize (+ u1 (var-get proposalSize)))
		(map-insert proposalList (var-get proposalSize) (contract-of proposal))
		(print {event: "propose", proposal: proposal, proposer: tx-sender})
		(ok (asserts! (map-insert Proposals (contract-of proposal) (merge {votesFor: u0, votesAgainst: u0, concluded: false, passed: false} data)) ERR_PROPOSAL_ALREADY_EXISTS))
	)
)

;; --- Public functions

(define-read-only (get-governance-token)
	(var-get governanceTokenPrincipal)
)

(define-read-only (get-parameter (parameter (string-ascii 34)))
	(ok (unwrap! (map-get? parameters parameter) ERR_UNKNOWN_PARAMETER))
)

(define-read-only (get-proposal-data (proposal principal))
	(map-get? Proposals proposal)
)

(define-read-only (get-proposals (atIndex uint))
	(map-get? proposalList atIndex)
)

(define-read-only (get-current-total-votes (proposal principal) (voter principal) (governanceToken principal))
	(default-to u0 (map-get? MemberTotalVotes {proposal: proposal, voter: voter, governanceToken: governanceToken}))
)

(define-public (can-vote (who principal) (tokenThreshold uint) (governanceToken <sip010-ft-trait>))
	(let
		(
			(balance (unwrap-panic (contract-call? governanceToken get-balance tx-sender)))
		)
		(ok (>= balance (* MICRO tokenThreshold)))
	)
)

(define-public (vote (for bool) (proposal principal) (delegator (optional principal)))
	(let
		(
			(proposalData (unwrap! (map-get? Proposals proposal) ERR_UNKNOWN_PROPOSAL))
			(voter (default-to tx-sender delegator))
			(amount (unwrap-panic (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega get-balance voter)))
		)
		(asserts! (>= block-height (get startBlockHeight proposalData)) ERR_PROPOSAL_INACTIVE)
		(asserts! (< block-height (get endBlockHeight proposalData)) ERR_PROPOSAL_INACTIVE)
		(asserts! (can-vote-on-behalf tx-sender delegator) ERR_NOT_DELEGATE)
		(asserts! (unwrap-panic (can-vote voter (try! (get-parameter "voteThreshold")) 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega)) ERR_INSUFFICIENT_WEIGHT)
		(asserts! (is-eq u0 (get-current-total-votes proposal voter 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega)) ERR_ALREADY_VOTED)
		(map-set MemberTotalVotes {proposal: proposal, voter: voter, governanceToken: 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega}
			(+ (get-current-total-votes proposal voter 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega) amount)
		)
		(map-set Proposals proposal
			(if for
				(merge proposalData {votesFor: (+ (get votesFor proposalData) amount)})
				(merge proposalData {votesAgainst: (+ (get votesAgainst proposalData) amount)})
			)
		)
		(print {event: "vote", proposal: proposal, voter: voter, delegate: (if (is-none delegator) none (some tx-sender)), for: for, amount: amount})
		(ok true)
	)
)

(define-public (vote-many (votes (list 200 {for: bool, proposal: principal, delegator: (optional principal)})))
	(ok (map vote-map votes))
)

(define-private (vote-map (delegator {for: bool, proposal: principal, delegator: (optional principal)}))
	(let
		(
			(for (get for delegator))
			(proposal (get proposal delegator))
			(voter (get delegator delegator))
		)
		(match voter
			foundDelegator (try! (vote for proposal (some foundDelegator)))
			(try! (vote for proposal none))
		)
		(ok true)
	)
)

(define-public (conclude (proposal <proposal-trait>))
	(let
		(
			(proposalData (unwrap! (map-get? Proposals (contract-of proposal)) ERR_UNKNOWN_PROPOSAL))
			(totalVotes (+ (get votesFor proposalData) (get votesAgainst proposalData)))
			(quorumThreshold (* MICRO (try! (get-parameter "quorumThreshold"))))
            (passed (and (>= totalVotes quorumThreshold) (> (get votesFor proposalData) (get votesAgainst proposalData))))
		)
		(asserts! (not (get concluded proposalData)) ERR_PROPOSAL_ALREADY_CONCLUDED)
		(asserts! (>= block-height (+ (try! (get-parameter "executionDelay")) (get endBlockHeight proposalData))) ERR_END_BLOCK_HEIGHT_NOT_REACHED)
		(map-set Proposals (contract-of proposal) (merge proposalData {concluded: true, passed: passed}))
		(print {event: "conclude", proposal: proposal, totalVotes: totalVotes, quorum: quorumThreshold, passed: passed})
		(and passed (try! (contract-call? .mega-dao execute proposal tx-sender)))
		(ok passed)
	)
)

;; --- Delegation

(define-public (delegate (who principal))
	(begin
		(asserts! (or (not (is-eq tx-sender who)) (not (is-eq contract-caller who))) ERR_CANT_DELEGATE_TO_SELF)
		(print {event: "delegate", who: who, delegator: tx-sender})
		(map-set Delegators tx-sender true)
		(ok (map-set Delegates tx-sender who))
	)
)

(define-public (revoke-delegation (who principal))
	(begin
		(asserts! (or (is-eq tx-sender who) (is-eq contract-caller who)) ERR_NOT_TOKEN_OWNER)
		(asserts! (is-some (map-get? Delegates who)) ERR_NO_DELEGATION_TO_REVOKE)
		(print {event: "revoke-delegation", who: who, delegator: tx-sender})
		(map-delete Delegators tx-sender)
		(ok (map-delete Delegates who))
	)
)

(define-read-only (can-vote-on-behalf (sender principal) (delegator (optional principal)))
	(match delegator
		voter (is-eq (map-get? Delegates voter) (some sender))
		true
	)
)

(define-read-only (get-delegate (who principal))
	(ok (map-get? Delegates who))
)

(define-read-only (is-delegating (who principal))
	(default-to false (map-get? Delegators who))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)