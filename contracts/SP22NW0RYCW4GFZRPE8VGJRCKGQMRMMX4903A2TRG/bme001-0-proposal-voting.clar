;; Title: BME01 Proposal Voting
;; Synopsis:
;; Allows governance token holders to vote on and conclude proposals.
;; Description:
;; Once proposals are submitted, they are open for voting after a lead up time
;; passes. Any token holder may vote on an open proposal, where one token equals
;; one vote. Members can vote until the voting period is over. After this period
;; anyone may trigger a conclusion. The proposal will then be executed if the
;; votes in favour exceed the ones against by the custom majority if set or simple majority
;; otherwise. Votes may additionally be submitted as batched list of signed structured 
;; voting messages using SIP-018.
;; The mechanism for voting requires Governance tokens to be burned in exchange for the 
;; equivalent number of lock tokens - these can be re-exchanged after the vote is concluded.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)
(use-trait proposal-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-proposal-already-executed (err u3002))
(define-constant err-proposal-already-exists (err u3003))
(define-constant err-unknown-proposal (err u3004))
(define-constant err-proposal-already-concluded (err u3005))
(define-constant err-proposal-inactive (err u3006))
(define-constant err-proposal-not-concluded (err u3007))
(define-constant err-no-votes-to-return (err u3008))
(define-constant err-end-block-height-not-reached (err u3009))
(define-constant err-disabled (err u3010))
(define-constant err-not-majority (err u3011))

(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap! (to-consensus-buff?
	{
		name: "BigMarket",
		version: "1.0.0",
		chain-id: chain-id
	}
    ) err-unauthorised)
))
(define-constant custom-majority-upper u10000)
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

(define-map proposals
	principal
	{
		custom-majority: (optional uint), ;; u10000 = 100%
		votes-for: uint,
		votes-against: uint,
		start-burn-height: uint,
		end-burn-height: uint,
		concluded: bool,
		passed: bool,
		proposer: principal
	}
)

(define-map member-total-votes {proposal: principal, voter: principal} uint)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; Proposals

(define-public (add-proposal (proposal <proposal-trait>) (data {start-burn-height: uint, end-burn-height: uint, proposer: principal, custom-majority: (optional uint)}))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (is-none (contract-call? .bigmarket-dao executed-at proposal)) err-proposal-already-executed)
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

(define-public (vote (amount uint) (for bool) (proposal principal) (reclaim-proposal (optional principal)))
  (process-vote-internal amount for proposal tx-sender reclaim-proposal)
)

(define-public (batch-vote (votes (list 50 {message: (tuple 
                                                (attestation (string-ascii 100))
                                                (proposal principal) 
                                                (vote bool)
                                                (voter principal)
                                                (amount uint)
                                                (reclaim-proposal (optional principal))), 
                                   signature: (buff 65)})))
  (begin
    (ok (fold fold-vote votes u0))
  )
)

(define-private (fold-vote  (input-vote {message: (tuple 
                                                (attestation (string-ascii 100)) 
                                                (proposal principal) 
                                                (vote bool)
                                                (voter principal)
                                                (amount uint) (reclaim-proposal (optional principal))), 
                                     signature: (buff 65)}) (current uint))
  (let
    (
      (vote-result (process-vote input-vote))
    )
	(if (unwrap! vote-result u0)
		(+ current u1)
		current)
  )
)

(define-private (process-vote (input-vote {message: (tuple 
                                                (attestation (string-ascii 100)) 
                                                (proposal principal) 
                                                (vote bool)
                                                (voter principal)
                                                (amount uint) (reclaim-proposal (optional principal))), 
                                     signature: (buff 65)}))
  (let
    (
      ;; Extract relevant fields from the message
		(message-data (get message input-vote))
		(proposal (get proposal message-data))
		(reclaim-proposal (get reclaim-proposal message-data))
		(voter (get voter message-data))
		(amount (get amount message-data))
		(for (get vote message-data))
		(structured-data-hash (sha256 (unwrap! (to-consensus-buff? message-data) err-unauthorised)))
		;; Verify the signature
		(is-valid-sig (verify-signed-structured-data structured-data-hash (get signature input-vote) voter))
    )
    (if is-valid-sig
		(process-vote-internal amount for proposal voter reclaim-proposal)
	  	(begin 
      		(ok false) ;; Invalid signature, skip vote
	  	)
    )
  )
)

(define-private (process-vote-internal (amount uint) (for bool) (proposal principal) (voter principal) (reclaim-proposal (optional principal)))
	(let
		(
			(proposal-data (unwrap! (map-get? proposals proposal) err-unknown-proposal))
		)
		(if (is-some reclaim-proposal) (try! (reclaim-votes reclaim-proposal)) true)
		(asserts! (>= burn-block-height (get start-burn-height proposal-data)) err-proposal-inactive)
		(asserts! (< burn-block-height (get end-burn-height proposal-data)) err-proposal-inactive)
		(map-set member-total-votes {proposal: proposal, voter: voter}
			(+ (get-current-total-votes proposal voter) amount)
		)
		(map-set proposals proposal
			(if for
				(merge proposal-data {votes-for: (+ (get votes-for proposal-data) amount)})
				(merge proposal-data {votes-against: (+ (get votes-against proposal-data) amount)})
			)
		)
      	(try! (contract-call? .bme030-0-reputation-token mint voter u7 u2))
		(print {event: "vote", proposal: proposal, voter: voter, for: for, amount: amount})
		(contract-call? .bme000-0-governance-token bmg-lock amount voter)
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
		(asserts! (>= burn-block-height (get end-burn-height proposal-data)) err-end-block-height-not-reached)
		(map-set proposals (contract-of proposal) (merge proposal-data {concluded: true, passed: passed}))
		(print {event: "conclude", proposal: proposal, passed: passed})
		(and passed (try! (contract-call? .bigmarket-dao execute proposal tx-sender)))
      	(try! (contract-call? .bme030-0-reputation-token mint tx-sender u3 u5))
		(ok passed)
	)
)

;; Reclamation

(define-public (reclaim-votes (proposal (optional principal)))
	(let
		(
			(reclaim-proposal (unwrap! proposal err-unknown-proposal))
			(proposal-data (unwrap! (map-get? proposals reclaim-proposal) err-unknown-proposal))
			(votes (unwrap! (map-get? member-total-votes {proposal: reclaim-proposal, voter: tx-sender}) err-no-votes-to-return))
		)
		(asserts! (get concluded proposal-data) err-proposal-not-concluded)
		(map-delete member-total-votes {proposal: reclaim-proposal, voter: tx-sender})
      	(try! (contract-call? .bme030-0-reputation-token mint tx-sender u5 u3))
		(contract-call? .bme000-0-governance-token bmg-unlock votes tx-sender)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

(define-read-only (verify-signature (hash (buff 32)) (signature (buff 65)) (signer principal))
	(is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok signer))
)

(define-read-only (verify-signed-structured-data (structured-data-hash (buff 32)) (signature (buff 65)) (signer principal))
	(verify-signature (sha256 (concat structured-data-header structured-data-hash)) signature signer)
)

(define-read-only (verify-signed-tuple
    (message-data (tuple 
                    (attestation (string-ascii 100))
                    (proposal principal)
                    (vote bool)
                    (voter principal)
                    (amount uint)))
    (signature (buff 65))
    (signer principal))
  (let
    (
      ;; Compute the structured data hash
      	(structured-data-hash (sha256 (unwrap! (to-consensus-buff? message-data) err-unauthorised)))
    )
    ;; Verify the signature using the computed hash
    (ok (verify-signed-structured-data structured-data-hash signature signer))
  )
)
