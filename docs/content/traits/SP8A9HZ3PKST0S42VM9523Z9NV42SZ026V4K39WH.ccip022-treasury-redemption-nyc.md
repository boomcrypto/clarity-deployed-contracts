---
title: "Trait ccip022-treasury-redemption-nyc"
draft: true
---
```
;; TRAITS

(impl-trait .proposal-trait.proposal-trait)
(impl-trait .ccip015-trait.ccip015-trait)

;; ERRORS

(define-constant ERR_PANIC (err u22000))
(define-constant ERR_SAVING_VOTE (err u22001))
(define-constant ERR_VOTED_ALREADY (err u22002))
(define-constant ERR_NOTHING_STACKED (err u22003))
(define-constant ERR_USER_NOT_FOUND (err u22004))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u22005))
(define-constant ERR_PROPOSAL_STILL_ACTIVE (err u22006))
(define-constant ERR_VOTE_FAILED (err u22007))

;; CONSTANTS

(define-constant SELF (as-contract tx-sender))
(define-constant CCIP_022 {
  name: "CityCoins Treasury Redemption (NYC)",
  link: "https://github.com/citycoins/governance/blob/feat/add-ccip-022/ccips/ccip-022/ccip-022-citycoins-treasury-redemption-nyc.md",
  hash: "2a22deaae6e7c12bb7726c3061a0f20515644ca9",
})

(define-constant VOTE_SCALE_FACTOR (pow u10 u16)) ;; 16 decimal places

;; set city ID
(define-constant NYC_ID (default-to u2 (contract-call? .ccd004-city-registry get-city-id "nyc")))

;; DATA VARS

;; vote block heights
(define-data-var voteActive bool true)
(define-data-var voteStart uint u0)
(define-data-var voteEnd uint u0)

;; start the vote when deployed
(var-set voteStart block-height)

;; DATA MAPS

(define-map CityVotes
  uint ;; city ID
  { ;; vote
    totalAmountYes: uint,
    totalAmountNo: uint,
    totalVotesYes: uint,
    totalVotesNo: uint,
  }
)

(define-map UserVotes
  uint ;; user ID
  { ;; vote
    vote: bool,
    nyc: uint,
  }
)
;; PUBLIC FUNCTIONS

(define-public (execute (sender principal))
  (let ((nycRedemptionBalance (stx-get-balance .ccd002-treasury-nyc-mining-v2)))
    ;; check vote is complete/passed
    (try! (is-executable))
    ;; update vote variables
    (var-set voteEnd block-height)
    (var-set voteActive false)
    ;; transfer funds to new redemption extension
    (try! (contract-call? .ccd002-treasury-nyc-mining-v2 withdraw-stx nycRedemptionBalance .ccd012-redemption-nyc))
    ;; initialize redemption extension
    (try! (contract-call? .ccd012-redemption-nyc initialize-redemption))
    (ok true))
)

(define-public (vote-on-proposal (vote bool))
  (let
    (
      (voterId (unwrap! (contract-call? .ccd003-user-registry get-user-id contract-caller) ERR_USER_NOT_FOUND))
      (voterRecord (map-get? UserVotes voterId))
    )
    ;; check if vote is active
    (asserts! (var-get voteActive) ERR_PROPOSAL_NOT_ACTIVE)
    ;; check if vote record exists for user
    (match voterRecord record
      ;; if the voterRecord exists
      (let
        (
          (oldVote (get vote record))
          (nycVoteAmount (get nyc record))
        )
        ;; check vote is not the same as before
        (asserts! (not (is-eq oldVote vote)) ERR_VOTED_ALREADY)
        ;; record the new vote for the user
        (map-set UserVotes voterId
          (merge record { vote: vote })
        )
        ;; update vote stats for each city
        (update-city-votes NYC_ID nycVoteAmount vote true)
        (ok true)
      )
      ;; if the voterRecord does not exist
      (let
        (
          (nycVoteAmount (scale-down (default-to u0 (get-nyc-vote voterId true))))
        )
        ;; check that the user has a positive vote
        (asserts! (or (> nycVoteAmount u0)) ERR_NOTHING_STACKED)
        ;; insert new user vote record
        (asserts! (map-insert UserVotes voterId {
          vote: vote,
          nyc: nycVoteAmount
        }) ERR_SAVING_VOTE)
        ;; update vote stats for each city
        (update-city-votes NYC_ID nycVoteAmount vote false)
        (ok true)
      )
    )
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-executable)
  (let
    (
      (votingRecord (unwrap! (get-vote-totals) ERR_PANIC))
      (nycRecord (get nyc votingRecord))
      (voteTotals (get totals votingRecord))
    )
    ;; check that there is at least one vote
    (asserts! (or (> (get totalVotesYes voteTotals) u0) (> (get totalVotesNo voteTotals) u0)) ERR_VOTE_FAILED)
    ;; check that the yes total is more than no total
    (asserts! (> (get totalVotesYes voteTotals) (get totalVotesNo voteTotals)) ERR_VOTE_FAILED)
    ;; check the "yes" votes are at least 25% of the total
    (asserts! (>= (get totalAmountYes nycRecord) (/ (get totalAmountYes voteTotals) u4)) ERR_VOTE_FAILED)
    ;; allow execution
    (ok true)
  )
)

(define-read-only (is-vote-active)
  (some (var-get voteActive))
)

(define-read-only (get-proposal-info)
  (some CCIP_022)
)

(define-read-only (get-vote-period)
  (if (and
    (> (var-get voteStart)  u0)
    (> (var-get voteEnd) u0))
    ;; if both are set, return values
    (some {
      startBlock: (var-get voteStart),
      endBlock: (var-get voteEnd),
      length: (- (var-get voteEnd) (var-get voteStart))
    })
    ;; else return none
    none
  )
)

(define-read-only (get-vote-total-nyc)
  (map-get? CityVotes NYC_ID)
)

(define-read-only (get-vote-total-nyc-or-default)
  (default-to { totalAmountYes: u0, totalAmountNo: u0, totalVotesYes: u0, totalVotesNo: u0 } (get-vote-total-nyc))
)

(define-read-only (get-vote-totals)
  (let
    (
      (nycRecord (get-vote-total-nyc-or-default))
    )
    (some {
      nyc: nycRecord,
      totals: {
        totalAmountYes: (get totalAmountYes nycRecord),
        totalAmountNo: (get totalAmountNo nycRecord),
        totalVotesYes: (get totalVotesYes nycRecord),
        totalVotesNo: (get totalVotesNo nycRecord),
      }
    })
  )
)

(define-read-only (get-voter-info (id uint))
  (map-get? UserVotes id)
)

;; NYC vote calculation
;; returns (some uint) or (none)
;; optionally scaled by VOTE_SCALE_FACTOR (10^6)
(define-read-only (get-nyc-vote (userId uint) (scaled bool))
  (let
    (
      ;; MAINNET: NYC cycle 82 / first block BTC 838,250 STX 145,643
      (cycle82Hash (unwrap! (get-block-hash u145643) none))
      (cycle82Data (at-block cycle82Hash (contract-call? .ccd007-citycoin-stacking get-stacker NYC_ID u82 userId)))
      (cycle82Amount (get stacked cycle82Data))
      ;; MAINNET: NYC cycle 83 / first block BTC 840,350 STX 147,282
      (cycle83Hash (unwrap! (get-block-hash u147282) none))
      (cycle83Data (at-block cycle83Hash (contract-call? .ccd007-citycoin-stacking get-stacker NYC_ID u83 userId)))
      (cycle83Amount (get stacked cycle83Data))
      ;; NYC vote calculation
      (scaledVote (/ (+ (scale-up cycle82Amount) (scale-up cycle83Amount)) u2))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle82Amount u0) (> cycle83Amount u0)) none)
    ;; return scaled or unscaled value
    (if scaled (some scaledVote) (some (/ scaledVote VOTE_SCALE_FACTOR)))
  )
)

;; PRIVATE FUNCTIONS

;; update city vote map
(define-private (update-city-votes (cityId uint) (voteAmount uint) (vote bool) (changedVote bool))
  (let
    (
      (cityRecord (default-to
        { totalAmountYes: u0, totalAmountNo: u0, totalVotesYes: u0, totalVotesNo: u0 }
        (map-get? CityVotes cityId)))
    )
    ;; do not record if amount is 0
    (if (> voteAmount u0)
      ;; handle vote
      (if vote
        ;; handle yes vote
        (map-set CityVotes cityId {
          totalAmountYes: (+ voteAmount (get totalAmountYes cityRecord)),
          totalVotesYes: (+ u1 (get totalVotesYes cityRecord)),
          totalAmountNo: (if changedVote (- (get totalAmountNo cityRecord) voteAmount) (get totalAmountNo cityRecord)),
          totalVotesNo: (if changedVote (- (get totalVotesNo cityRecord) u1) (get totalVotesNo cityRecord))
        })
        ;; handle no vote
        (map-set CityVotes cityId {
          totalAmountYes: (if changedVote (- (get totalAmountYes cityRecord) voteAmount) (get totalAmountYes cityRecord)),
          totalVotesYes: (if changedVote (- (get totalVotesYes cityRecord) u1) (get totalVotesYes cityRecord)),
          totalAmountNo: (+ voteAmount (get totalAmountNo cityRecord)),
          totalVotesNo: (+ u1 (get totalVotesNo cityRecord)),
        })
      )
      ;; ignore calls with vote amount equal to 0
      false)
  )
)

;; get block hash by height
(define-private (get-block-hash (blockHeight uint))
  (get-block-info? id-header-hash blockHeight)
)

;; CREDIT: ALEX math-fixed-point-16.clar

(define-private (scale-up (a uint))
  (* a VOTE_SCALE_FACTOR)
)

(define-private (scale-down (a uint))
  (/ a VOTE_SCALE_FACTOR)
)

```
