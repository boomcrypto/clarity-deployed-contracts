;; TRAITS

(impl-trait .proposal-trait.proposal-trait)
(impl-trait .ccip015-trait.ccip015-trait)

;; ERRORS

(define-constant ERR_PANIC (err u1700))
(define-constant ERR_VOTED_ALREADY (err u1701))
(define-constant ERR_NOTHING_STACKED (err u1702))
(define-constant ERR_USER_NOT_FOUND (err u1703))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u1704))
(define-constant ERR_PROPOSAL_STILL_ACTIVE (err u1705))
(define-constant ERR_NO_CITY_ID (err u1706))
(define-constant ERR_VOTE_FAILED (err u1707))

;; CONSTANTS

(define-constant SELF (as-contract tx-sender))
(define-constant CCIP_017 {
  name: "Extend Direct Execute Sunset Period",
  link: "https://github.com/citycoins/governance/blob/feat/add-ccip-017/ccips/ccip-017/ccip-017-extend-direct-execute-sunset-period.md",
  hash: "7ddbf6152790a730faa059b564a8524abc3c70d3",
})
(define-constant SUNSET_BLOCK u147828)

(define-constant VOTE_SCALE_FACTOR (pow u10 u16)) ;; 16 decimal places
(define-constant MIA_SCALE_BASE (pow u10 u4)) ;; 4 decimal places
(define-constant MIA_SCALE_FACTOR u8823) ;; 0.8823 or 88.23%
;; MIA votes scaled to make 1 MIA = 1 NYC
;; full calculation available in CCIP-017

;; DATA VARS

;; vote block heights
(define-data-var voteActive bool true)
(define-data-var voteStart uint u0)
(define-data-var voteEnd uint u0)

(var-set voteStart block-height)

;; vote tracking
(define-data-var yesVotes uint u0)
(define-data-var yesTotal uint u0)
(define-data-var noVotes uint u0)
(define-data-var noTotal uint u0)

;; DATA MAPS

(define-map UserVotes
  uint ;; user ID
  { ;; vote
    vote: bool,
    mia: uint,
    nyc: uint,
    total: uint,
  }
)

;; PUBLIC FUNCTIONS

(define-public (execute (sender principal))
  (begin
    ;; check vote complete/passed
    (try! (is-executable))
    ;; update vote variables
    (var-set voteEnd block-height)
    (var-set voteActive false)
    ;; extend sunset height in ccd001-direct-execute
    (try! (contract-call? .ccd001-direct-execute set-sunset-block SUNSET_BLOCK))
    (ok true)
  )
)

(define-public (vote-on-proposal (vote bool))
  (let
    (
      (miaId (unwrap! (contract-call? .ccd004-city-registry get-city-id "mia") ERR_NO_CITY_ID))
      (nycId (unwrap! (contract-call? .ccd004-city-registry get-city-id "nyc") ERR_NO_CITY_ID))
      (voterId (unwrap! (contract-call? .ccd003-user-registry get-user-id contract-caller) ERR_USER_NOT_FOUND))
      (voterRecord (map-get? UserVotes voterId))
    )
    ;; check that proposal is active
    (asserts! (var-get voteActive) ERR_PROPOSAL_NOT_ACTIVE)
    ;; check if vote record exists
    (match voterRecord record
      ;; if the voterRecord exists
      (begin
        ;; check vote is not the same as before
        (asserts! (not (is-eq (get vote record) vote)) ERR_VOTED_ALREADY)
        ;; record the new vote for the user
        (map-set UserVotes voterId
          (merge record { vote: vote })
        )
        ;; update the overall vote totals
        (if vote
          (begin
            (var-set yesVotes (+ (var-get yesVotes) u1))
            (var-set yesTotal (+ (var-get yesTotal) (get total record)))
            (var-set noVotes (- (var-get noVotes) u1))
            (var-set noTotal (- (var-get noTotal) (get total record)))
          )
          (begin
            (var-set yesVotes (- (var-get yesVotes) u1))
            (var-set yesTotal (- (var-get yesTotal) (get total record)))
            (var-set noVotes (+ (var-get noVotes) u1))
            (var-set noTotal (+ (var-get noTotal) (get total record)))
          )
        )
      )
      ;; if the voterRecord does not exist
      (let
        (
          (scaledVoteMia (default-to u0 (get-mia-vote miaId voterId true)))
          (scaledVoteNyc (default-to u0 (get-nyc-vote nycId voterId true)))
          (voteMia (scale-down scaledVoteMia))
          (voteNyc (scale-down scaledVoteNyc))
          (voteTotal (+ voteMia voteNyc))
        )
        ;; record the vote for the user
        (map-insert UserVotes voterId {
          vote: vote,
          mia: voteMia,
          nyc: voteNyc,
          total: voteTotal,
        })
        ;; update the overall vote totals
        (if vote
          (begin
            (var-set yesVotes (+ (var-get yesVotes) u1))
            (var-set yesTotal (+ (var-get yesTotal) voteTotal))
          )
          (begin
            (var-set noVotes (+ (var-get noVotes) u1))
            (var-set noTotal (+ (var-get noTotal) voteTotal))
          )
        )
      )
    )
    ;; print voter information
    (print (map-get? UserVotes voterId))
    ;; print vote totals
    (print (get-vote-totals))
    (ok true)
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-executable)
  (begin
    ;; check that there is at least one vote
    (asserts! (or (> (var-get yesVotes) u0) (> (var-get noVotes) u0)) ERR_VOTE_FAILED)
    ;; check that yes total is more than no total
    (asserts! (> (var-get yesTotal) (var-get noTotal)) ERR_VOTE_FAILED)
    (ok true)
  )
)

(define-read-only (is-vote-active)
  (some (var-get voteActive))
)

(define-read-only (get-proposal-info)
  (some CCIP_017)
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

(define-read-only (get-vote-totals)
  (some {
    yesVotes: (var-get yesVotes),
    yesTotal: (var-get yesTotal),
    noVotes: (var-get noVotes),
    noTotal: (var-get noTotal)
  })
)

(define-read-only (get-voter-info (id uint))
  (map-get? UserVotes id)
)

;; MIA vote calculation
;; returns (some uint) or (none)
;; optionally scaled by VOTE_SCALE_FACTOR (10^6)
(define-read-only (get-mia-vote (cityId uint) (userId uint) (scaled bool))
  (let
    (
      ;; MAINNET: MIA cycle 64 / first block BTC 800,450 STX 114,689
      (cycle64Hash (unwrap! (get-block-hash u114700) none))
      (cycle64Data (at-block cycle64Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u64 userId)))
      (cycle64Amount (get stacked cycle64Data))
      ;; MAINNET: MIA cycle 65 / first block BTC 802,550 STX 116,486
      (cycle65Hash (unwrap! (get-block-hash u116500) none))
      (cycle65Data (at-block cycle65Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u65 userId)))
      (cycle65Amount (get stacked cycle65Data))
      ;; MIA vote calculation
      (avgStacked (/ (+ (scale-up cycle64Amount) (scale-up cycle65Amount)) u2))
      (scaledVote (/ (* avgStacked MIA_SCALE_FACTOR) MIA_SCALE_BASE))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle64Amount u0) (> cycle65Amount u0)) none)
    ;; return scaled or unscaled value
    (if scaled (some scaledVote) (some (/ scaledVote VOTE_SCALE_FACTOR)))
  )
)

;; NYC vote calculation
;; returns (some uint) or (none)
;; optionally scaled by VOTE_SCALE_FACTOR (10^6)
(define-read-only (get-nyc-vote (cityId uint) (userId uint) (scaled bool))
  (let
    (
      ;; NYC cycle 64 / first block BTC 800,450 STX 114,689
      (cycle64Hash (unwrap! (get-block-hash u114700) none))
      (cycle64Data (at-block cycle64Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u64 userId)))
      (cycle64Amount (get stacked cycle64Data))
      ;; NYC cycle 65 / first block BTC 802,550 STX 116,486
      (cycle65Hash (unwrap! (get-block-hash u116500) none))
      (cycle65Data (at-block cycle65Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u65 userId)))
      (cycle65Amount (get stacked cycle65Data))
      ;; NYC vote calculation
      (scaledVote (/ (+ (scale-up cycle64Amount) (scale-up cycle65Amount)) u2))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle64Amount u0) (> cycle65Amount u0)) none)
    ;; return scaled or unscaled value
    (if scaled (some scaledVote) (some (/ scaledVote VOTE_SCALE_FACTOR)))
  )
)

;; PRIVATE FUNCTIONS

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
