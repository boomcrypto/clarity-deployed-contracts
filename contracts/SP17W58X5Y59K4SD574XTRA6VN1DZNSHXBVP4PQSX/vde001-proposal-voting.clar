(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u2000))
(define-constant err-proposal-already-executed (err u2002))
(define-constant err-proposal-already-exists (err u2003))
(define-constant err-unknown-proposal (err u2004))
(define-constant err-proposal-already-concluded (err u2005))
(define-constant err-proposal-inactive (err u2006))
(define-constant err-proposal-not-concluded (err u2007))
(define-constant err-no-votes-to-return (err u2008))
(define-constant err-end-block-height-not-reached (err u2009))
(define-constant err-disabled (err u2010))

(define-constant locker-address (as-contract tx-sender))

(define-map proposals
	principal
	{
		votes-for: uint,
		votes-against: uint,
		start-block-height: uint,
		end-block-height: uint,
		concluded: bool,
		passed: bool,
		proposer: principal
	}
)

(define-map member-total-votes {proposal: principal, voter: principal} uint)
(define-map total-locked-tokens {voter: principal} uint)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; Proposals

(define-public (add-proposal (proposal <proposal-trait>) (data {start-block-height: uint, end-block-height: uint, proposer: principal}))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (is-none (contract-call? .vibeDAO executed-at proposal)) err-proposal-already-executed)
		(print {event: "propose", proposal: proposal, proposer: tx-sender})
		(ok (asserts! (map-insert proposals (contract-of proposal) (merge {votes-for: u0, votes-against: u0, concluded: false, passed: false} data)) err-proposal-already-exists))
	)
)

;; Locking and unlocking tokens

(define-private (vibe-lock (amount uint))
	(let
		(
			(locked (default-to u0 (map-get? total-locked-tokens {voter: tx-sender})))
		)
		(try! (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender locker-address none))
		(map-set total-locked-tokens {voter: tx-sender} (+ locked amount))
		(ok true)
	)
)

(define-private (vibe-unlock (amount uint) (owner principal))
	(let
		(
			(locked (default-to u0 (map-get? total-locked-tokens {voter: owner})))
		)
		(try! (as-contract (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender owner none)))
		(map-set total-locked-tokens {voter: owner} (- locked amount))
		(ok true)
	)
)

;; --- Public functions

;; Proposals

(define-read-only (get-proposal-data (proposal principal))
	(map-get? proposals proposal)
)

;; Votes

(define-read-only (get-current-total-votes (proposal principal) (voter principal))
	(default-to u0 (map-get? member-total-votes {proposal: proposal, voter: voter}))
)

(define-read-only (get-total-locked-tokens (voter principal))
	(default-to u0 (map-get? total-locked-tokens {voter: voter}))
)


(define-public (vote (amount uint) (for bool) (proposal principal))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals proposal) err-unknown-proposal))
		)
		(asserts! (>= burn-block-height (get start-block-height proposal-data)) err-proposal-inactive)
		(asserts! (< burn-block-height (get end-block-height proposal-data)) err-proposal-inactive)
		(map-set member-total-votes {proposal: proposal, voter: tx-sender}
			(+ (get-current-total-votes proposal tx-sender) amount)
		)
		(map-set proposals proposal
			(if for
				(merge proposal-data {votes-for: (+ (get votes-for proposal-data) amount)})
				(merge proposal-data {votes-against: (+ (get votes-against proposal-data) amount)})
			)
		)
		(print {event: "vote", proposal: proposal, voter: tx-sender, for: for, amount: amount})
		(vibe-lock amount)
	)
)

;; Conclusion

(define-public (conclude (proposal <proposal-trait>))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals (contract-of proposal)) err-unknown-proposal))
			(passed (> (get votes-for proposal-data) (get votes-against proposal-data)))
		)

		;; only the original proposer can conclude the proposal
		(asserts! (is-eq tx-sender (get proposer proposal-data)) err-unauthorised)

		(asserts! (not (get concluded proposal-data)) err-proposal-already-concluded)
		(asserts! (>= burn-block-height (get end-block-height proposal-data)) err-end-block-height-not-reached)
		(map-set proposals (contract-of proposal) (merge proposal-data {concluded: true, passed: passed}))
		(print {event: "conclude", proposal: proposal, passed: passed})
		(and passed (try! (contract-call? .vibeDAO execute proposal tx-sender)))
		(ok passed)
	)
)

;; Discard

(define-public (discard (proposal-address principal))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals proposal-address) err-unknown-proposal))
		)
		
		(try! (is-dao-or-extension))

		(asserts! (not (get concluded proposal-data)) err-proposal-already-concluded)
		(asserts! (>= burn-block-height (get end-block-height proposal-data)) err-end-block-height-not-reached)
		(map-set proposals proposal-address (merge proposal-data {concluded: true, passed: false}))
		(print {event: "discard", proposal: proposal-address})
		(ok false)
	)
)

;; Reclamation

(define-read-only (is-reclaimed (proposal principal) (voter principal)) 
	(is-none (map-get? member-total-votes {proposal: proposal, voter: voter}))
)

(define-public (reclaim-votes (proposal <proposal-trait>))
	(let
		(
			(proposal-principal (contract-of proposal))
			(proposal-data (unwrap! (map-get? proposals proposal-principal) err-unknown-proposal))
			(votes (unwrap! (map-get? member-total-votes {proposal: proposal-principal, voter: tx-sender}) err-no-votes-to-return))
		)
		(asserts! (get concluded proposal-data) err-proposal-not-concluded)
		(map-delete member-total-votes {proposal: proposal-principal, voter: tx-sender})
		(vibe-unlock votes tx-sender)
	)
)

(define-public (reclaim-and-vote (amount uint) (for bool) (proposal principal) (reclaim-from <proposal-trait>))
	(begin
		(try! (reclaim-votes reclaim-from))
		(vote amount for proposal)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)