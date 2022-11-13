;; Title: EDE007 Snapshot Proposal Voting
;; Author: Marvin Janssen
;; Depends-On: 
;; Synopsis:
;; This extension is an EcosystemDAO concept that allows all STX holders to
;; vote on proposals based on their STX balance.
;; Description:
;; This extension allows anyone with STX to vote on proposals. The maximum upper
;; bound, or voting power, depends on the amount of STX tokens the tx-sender
;; owned at the start block height of the proposal. The name "snapshot" comes
;; from the fact that the extension effectively uses the STX balance sheet
;; at a specific block heights to determine voting power. 
;; Custom majority thresholds for voting are also possible on a per proposal basis.
;; A custom majority of 66% mean the percent of votes for must be greater than 66 for
;; the vote to carry.

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-proposal-already-executed (err u3001))
(define-constant err-proposal-already-exists (err u3002))
(define-constant err-unknown-proposal (err u3003))
(define-constant err-proposal-already-concluded (err u3004))
(define-constant err-proposal-inactive (err u3005))
(define-constant err-insufficient-voting-capacity (err u3006))
(define-constant err-end-block-height-not-reached (err u3007))
(define-constant err-not-majority (err u3008))
(define-constant err-exceeds-voting-cap (err u3009))

(define-constant custom-majority-upper u10000)
(define-constant vote-cap u140000000000)

(define-map proposals
	principal
	{
		votes-for: uint,
		votes-against: uint,
		start-block-height: uint,
		end-block-height: uint,
		concluded: bool,
		passed: bool,
		custom-majority: (optional uint), ;; u10000 = 100%
		proposer: principal
	}
)

(define-map member-total-votes {proposal: principal, voter: principal} uint)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .ecosystem-dao) (contract-call? .ecosystem-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; Proposals

(define-public (add-proposal (proposal <proposal-trait>) (data {start-block-height: uint, end-block-height: uint, proposer: principal, custom-majority: (optional uint)}))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (is-none (contract-call? .ecosystem-dao executed-at proposal)) err-proposal-already-executed)
		(asserts! (match (get custom-majority data) majority (> majority u5000) true) err-not-majority)
		(print {event: "propose", proposal: proposal, proposer: tx-sender})
		(ok (asserts! (map-insert proposals (contract-of proposal) (merge {votes-for: u0, votes-against: u0, concluded: false, passed: false} data)) err-proposal-already-exists))
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

(define-read-only (get-historical-values (height uint) (who principal))
	(at-block (unwrap! (get-block-info? id-header-hash height) none)
		(some 
			{
				user-balance: (stx-get-balance who), 
				voting-cap: vote-cap, 
				;;voting-cap: (contract-call? 'SP000000000000000000002Q6VF78.pox get-stacking-minimum)
			}
		)
	)
)

(define-public (vote (amount uint) (for bool) (proposal principal))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals proposal) err-unknown-proposal))
			(new-total-votes (+ (get-current-total-votes proposal tx-sender) amount))
			(historical-values (unwrap! (get-historical-values (get start-block-height proposal-data) tx-sender) err-proposal-inactive))
		)
		(asserts! (>= block-height (get start-block-height proposal-data)) err-proposal-inactive)
		(asserts! (< block-height (get end-block-height proposal-data)) err-proposal-inactive)
		(asserts!
			(<= new-total-votes (get user-balance historical-values))
			err-insufficient-voting-capacity
		)
		(asserts! 
			(< new-total-votes (get voting-cap historical-values)) 
			err-exceeds-voting-cap)
			
		(map-set member-total-votes {proposal: proposal, voter: tx-sender} new-total-votes)
		(map-set proposals proposal
			(if for
				(merge proposal-data {votes-for: (+ (get votes-for proposal-data) amount)})
				(merge proposal-data {votes-against: (+ (get votes-against proposal-data) amount)})
			)
		)
		(print {event: "vote", proposal: proposal, voter: tx-sender, for: for, amount: amount})
		(ok true)
	)
)

;; Conclusion

(define-public (conclude (proposal <proposal-trait>))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals (contract-of proposal)) err-unknown-proposal))
			(passed
				(match (get custom-majority proposal-data)
					majority (> (* (get votes-for proposal-data) custom-majority-upper) (* (+ (get votes-for proposal-data) (get votes-against proposal-data)) majority))
					(> (get votes-for proposal-data) (get votes-against proposal-data))
				)
			)
		)
		(asserts! (not (get concluded proposal-data)) err-proposal-already-concluded)
		(asserts! (>= block-height (get end-block-height proposal-data)) err-end-block-height-not-reached)
		(map-set proposals (contract-of proposal) (merge proposal-data {concluded: true, passed: passed}))
		(print {event: "conclude", proposal: proposal, passed: passed})
		(and passed (try! (contract-call? .ecosystem-dao execute proposal tx-sender)))
		(ok passed)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
