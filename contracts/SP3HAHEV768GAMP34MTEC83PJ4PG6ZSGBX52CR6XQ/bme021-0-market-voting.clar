;; Title: BME021 Market Voting
;; Synopsis:
;; Intended for prediction market resolution via community voting.
;; Description:
;; Market votes are connected to a specific market via the market data hash and
;; votes are created via challenges to the market outcome. Any user with a stake in the market
;; can challenge the outcome. Voting begins on challenge and runs for a DAO configured window.
;; DAO governance voting resolves the market - either confirmaing or changing hte original 
;; outcome based on a simple majority.
;; Unlike proposal voting - market voting is categorical - voters are voting to select an
;; outcome from at least 2 and up to 10 potential outcomes.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait prediction-market-trait .prediction-market-trait.prediction-market-trait)

(define-constant err-unauthorised (err u2100))
(define-constant err-poll-already-exists (err u2102))
(define-constant err-unknown-proposal (err u2103))
(define-constant err-proposal-inactive (err u2105))
(define-constant err-already-voted (err u2106))
(define-constant err-proposal-start-no-reached (err u2109))
(define-constant err-expecting-root (err u2110))
(define-constant err-invalid-signature (err u2111))
(define-constant err-proposal-already-concluded (err u2112))
(define-constant err-end-burn-height-not-reached (err u2113))
(define-constant err-no-votes-to-return (err u2114))
(define-constant err-not-concluded (err u2115))
(define-constant err-invalid-category (err u2116))
(define-constant err-invalid-extension (err u2117))


(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap! (to-consensus-buff?
	{
		name: "BigMarket",
		version: "1.0.0",
		chain-id: chain-id
	}
    ) err-unauthorised)
))

(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

(define-data-var voting-duration uint u288)

(define-map resolution-polls
	{market: principal, market-id: uint}
	{
    votes: (list 10 uint), ;; votes for each category. NB with 2 categories the votes at 0 are against and 1 = for and 2+ unused 
		end-burn-height: uint,
		proposer: principal,
		concluded: bool,
    num-categories: uint,
    winning-category: (optional uint),
	}
)
(define-map member-total-votes {market-id: uint, voter: principal} uint)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions
(define-public (set-voting-duration (new-duration uint))
  (begin
    (try! (is-dao-or-extension))
    (var-set voting-duration new-duration)
    (ok true)
  )
)

;; called by a user to begin dispute resolution process.
;; access conditions for this action are determined in the contract-call to the market contract.
(define-public (create-market-vote
    (market <prediction-market-trait>)
    (market-id uint)
    (empty-votes (list 10 uint))
    (num-categories uint)
  )
  (let
    (
      (original-sender tx-sender)
    )

    ;; Verify that the market is a registered extension
    (asserts! (contract-call? .bigmarket-dao is-extension (contract-of market)) err-invalid-extension)
    ;; ensure no market vote already exists
    (asserts! (is-none (map-get? resolution-polls {market-id: market-id, market: (contract-of market)})) err-poll-already-exists)
    (asserts! (is-eq (len empty-votes) num-categories) err-poll-already-exists)
		;; see market for access rules. 
    (try! (as-contract (contract-call? market dispute-resolution market-id original-sender num-categories)))

    ;; Register the poll
    (map-set resolution-polls {market-id: market-id, market: (contract-of market)}
      {
      votes: empty-votes,
      end-burn-height: (+ burn-block-height (var-get voting-duration)),
      proposer: tx-sender,
      concluded: false,
      num-categories: num-categories,
      winning-category: none}
    )

    ;; Emit an event for the new poll
    (print {event: "create-market-vote", market-id: market-id, proposer: tx-sender, market: market})
    (ok true)
  )
)

;; --- Public functions

(define-read-only (get-poll-data (market principal) (market-id uint))
	(map-get? resolution-polls {market-id: market-id, market: market})
)


;; Votes

(define-public (vote
    (market principal)
    (market-id uint) 
    (category-for uint)
    (amount uint) 
    (prev-market-id (optional uint))
  )
  ;; Process the vote using shared logic
  (process-market-vote market market-id tx-sender category-for amount false prev-market-id)
)


(define-public (batch-vote (votes (list 50 {message: (tuple 
                                                (market principal)
                                                (market-id uint)
                                                (attestation (string-ascii 100)) 
                                                (timestamp uint) 
                                                (category-for uint)
                                                (amount uint)
                                                (voter principal)
                                                (prev-market-id (optional uint))),
                                   signature: (buff 65)})))
  (begin
    (ok (fold fold-vote votes u0))
  )
)

(define-private (fold-vote  (input-vote {message: (tuple 
                                                (market principal)
                                                (market-id uint)
                                                (attestation (string-ascii 100)) 
                                                (timestamp uint) 
                                                (category-for uint)
                                                (amount uint)
                                                (voter principal)
                                                (prev-market-id (optional uint))),
                                     signature: (buff 65)}) (current uint))
  (let
    (
      (vote-result (process-vote input-vote))
    )
    (if (is-ok vote-result)
        (if (unwrap! vote-result u0)
            (+ current u1)
            current) 
        current)
  )
)

(define-private (process-vote
    (input-vote {message: (tuple 
                            (market principal)
                            (market-id uint)
                            (attestation (string-ascii 100)) 
                            (timestamp uint) 
                            (category-for uint)
                            (amount uint)
                            (voter principal)
                            (prev-market-id (optional uint))),
                 signature: (buff 65)}))
  (let
      (
        ;; Extract relevant fields from the message
        (message-data (get message input-vote))
        (attestation (get attestation message-data))
        (timestamp (get timestamp message-data))
        (market (get market message-data))
        (market-id (get market-id message-data))
        (voter (get voter message-data))
        (category-for (get category-for message-data))
        (amount (get amount message-data))
        ;; Verify the signature
        (message (tuple (attestation attestation) (market-id market-id) (timestamp timestamp) (vote (get category-for message-data))))
        (structured-data-hash (sha256 (unwrap! (to-consensus-buff? message) err-unauthorised)))
        (is-valid-sig (verify-signed-structured-data structured-data-hash (get signature input-vote) voter))
      )
    (if is-valid-sig
        (process-market-vote market market-id voter category-for amount true (get prev-market-id message-data) )
        (ok false)) ;; Invalid signature
  ))


(define-private (process-market-vote
    (market principal) ;; the market contract
    (market-id uint)   ;; the market id
    (voter principal)         ;; The voter's principal
    (category-for uint)        ;; category voting for (with two categories, we get simple "for" or "against" binary vote)
    (amount uint)             ;; voting power
    (sip18 bool)              ;; sip18 message vote or tx vote
    (prev-market-id (optional uint))
  )
  (let
      (
        ;; Fetch the poll data
        (poll-data (unwrap! (map-get? resolution-polls {market-id: market-id, market: market}) err-unknown-proposal))
        (num-categories (get num-categories poll-data))
        (current-votes (get votes poll-data))
      )
    (begin
      ;; reclaim previously locked tokens
  		(if (is-some prev-market-id) (try! (reclaim-votes market prev-market-id)) true)

      ;; Ensure the voting period is active
      (asserts! (< burn-block-height (get end-burn-height poll-data)) err-proposal-inactive)

      ;; passed category exists
      (asserts! (< category-for num-categories) err-invalid-category)

      ;; Record the vote
      (map-set member-total-votes {market-id: market-id, voter: voter}
        (+ (get-current-total-votes market-id voter) amount)
      )

      ;; update market voting power
      (map-set resolution-polls {market-id: market-id, market: market}
        (merge poll-data 
          {votes: (unwrap! (replace-at? current-votes category-for (+ (unwrap! (element-at? current-votes category-for) err-invalid-category) amount)) err-invalid-category)}
        )
      )

      ;; Emit an event for the vote
      (print {event: "market-vote", market-id: market-id, voter: voter, category-for: category-for, sip18: sip18, amount: amount, prev-market-id: prev-market-id})

		  (contract-call? .bme000-0-governance-token bmg-lock amount voter)
    )
  ))


(define-read-only (get-current-total-votes (market-id uint) (voter principal))
	(default-to u0 (map-get? member-total-votes {market-id: market-id, voter: voter}))
)

(define-read-only (verify-signature (hash (buff 32)) (signature (buff 65)) (signer principal))
	(is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok signer))
)

(define-read-only (verify-signed-structured-data (structured-data-hash (buff 32)) (signature (buff 65)) (signer principal))
	(verify-signature (sha256 (concat structured-data-header structured-data-hash)) signature signer)
)

;; Conclusion

(define-read-only (get-poll-status (market principal) (market-id uint))
    (let
        (
            (poll-data (unwrap! (map-get? resolution-polls {market-id: market-id, market: market}) err-unknown-proposal))
            (is-active (< burn-block-height (get end-burn-height poll-data)))
        )
        (ok {active: is-active, concluded: (get concluded poll-data), votes: (get votes poll-data)})
    )
)
    

(define-public (conclude-market-vote (market <prediction-market-trait>) (market-id uint))
	(let
		(
      (poll-data (unwrap! (map-get? resolution-polls {market-id: market-id, market: (contract-of market)}) err-unknown-proposal))
      (votes (get votes poll-data))
      (winning-category (get max-index (find-max-category votes)))
      (total-votes (fold + votes u0))
      (winning-votes (unwrap! (element-at? votes winning-category) err-already-voted))
      (result (try! (contract-call? market resolve-market-vote market-id winning-category)))
		)
		(asserts! (not (get concluded poll-data)) err-proposal-already-concluded)
		(asserts! (>= burn-block-height (get end-burn-height poll-data)) err-end-burn-height-not-reached)
		(map-set resolution-polls {market-id: market-id, market: (contract-of market)} (merge poll-data {concluded: true, winning-category: (some winning-category)}))
		(print {event: "conclude-market-vote", market-id: market-id, winning-category: winning-category, result: result})
    (try! (contract-call? .bme030-0-reputation-token mint tx-sender u13 u2))
		(ok winning-category)
	)
)

(define-public (reclaim-votes (market principal) (id (optional uint)))
	(let
		(
			(market-id (unwrap! id err-unknown-proposal))
      (poll-data (unwrap! (map-get? resolution-polls {market: market, market-id: market-id}) err-unknown-proposal))
			(votes (unwrap! (map-get? member-total-votes {market-id: market-id, voter: tx-sender}) err-no-votes-to-return))
		)
		(asserts! (get concluded poll-data) err-not-concluded)
		(map-delete member-total-votes {market-id: market-id, voter: tx-sender})
		(contract-call? .bme000-0-governance-token bmg-unlock votes tx-sender)
	)
)

;; --- Extension callback
(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)


(define-private (find-max-category (votes (list 10 uint)))
  (fold find-max-iter votes {max-votes: u0, max-index: u0, current-index: u0})
)

(define-private (find-max-iter (current-votes uint) (acc (tuple (max-votes uint) (max-index uint) (current-index uint))))
  (let
    (
      (max-votes (get max-votes acc))  ;; Extract highest vote count so far
      (max-index (get max-index acc))  ;; Extract category index with highest votes
      (current-index (get current-index acc))  ;; Track current category index
    )
    (if (> current-votes max-votes)
      (tuple (max-votes current-votes) (max-index current-index) (current-index (+ current-index u1)))  ;; Update max
      (tuple (max-votes max-votes) (max-index max-index) (current-index (+ current-index u1)))  ;; Keep previous max
    )
  )
)
