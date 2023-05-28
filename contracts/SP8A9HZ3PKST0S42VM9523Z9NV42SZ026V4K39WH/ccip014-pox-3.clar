;; TRAITS

(impl-trait .proposal-trait.proposal-trait)
(impl-trait .ccip015-trait.ccip015-trait)

;; ERRORS

(define-constant ERR_PANIC (err u1400))
(define-constant ERR_VOTED_ALREADY (err u1401))
(define-constant ERR_NOTHING_STACKED (err u1402))
(define-constant ERR_USER_NOT_FOUND (err u1403))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u1404))
(define-constant ERR_PROPOSAL_STILL_ACTIVE (err u1405))
(define-constant ERR_NO_CITY_ID (err u1406))
(define-constant ERR_VOTE_FAILED (err u1407))

;; CONSTANTS

(define-constant SELF (as-contract tx-sender))
(define-constant MISSED_PAYOUT u1)
(define-constant CCIP_014 {
  name: "Upgrade to pox-3",
  link: "https://github.com/Rapha-btc/governance/blob/patch-1/ccips/ccip-014/ccip-014-upgrade-to-pox3.md",
  hash: "0448a33745e8f157214e3da87c512a2cd382dcd2",
})

(define-constant VOTE_SCALE_FACTOR (pow u10 u16)) ;; 16 decimal places
(define-constant MIA_SCALE_BASE (pow u10 u4)) ;; 4 decimal places
(define-constant MIA_SCALE_FACTOR u8760) ;; 0.8760 or 87.60%
;; MIA votes scaled to make 1 MIA = 1 NYC
;; full calculation available in CCIP-014

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
  (let
    (
      (miaId (unwrap! (contract-call? .ccd004-city-registry get-city-id "mia") ERR_PANIC))
      (nycId (unwrap! (contract-call? .ccd004-city-registry get-city-id "nyc") ERR_PANIC))
      (miaBalance (contract-call? .ccd002-treasury-mia-mining get-balance-stx))
      (nycBalance (contract-call? .ccd002-treasury-nyc-mining get-balance-stx))
    )

    ;; check vote complete/passed
    (try! (is-executable))

    ;; update vote variables
    (var-set voteEnd block-height)
    (var-set voteActive false)

    ;; enable mining v2 treasuries in the DAO
    (try! (contract-call? .base-dao set-extensions
      (list
        {extension: .ccd002-treasury-mia-mining-v2, enabled: true}
        {extension: .ccd002-treasury-nyc-mining-v2, enabled: true}
        {extension: .ccd006-citycoin-mining-v2, enabled: true}
      )
    ))

    ;; allow MIA/NYC in respective treasuries
    (try! (contract-call? .ccd002-treasury-mia-mining-v2 set-allowed 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 true))
    (try! (contract-call? .ccd002-treasury-nyc-mining-v2 set-allowed 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 true))

    ;; transfer funds to new treasury extensions
    (try! (contract-call? .ccd002-treasury-mia-mining withdraw-stx miaBalance .ccd002-treasury-mia-mining-v2))
    (try! (contract-call? .ccd002-treasury-nyc-mining withdraw-stx nycBalance .ccd002-treasury-nyc-mining-v2))

    ;; delegate stack the STX in the mining treasuries (up to 50M STX each)
    (try! (contract-call? .ccd002-treasury-mia-mining-v2 delegate-stx u50000000000000 'SP21YTSM60CAY6D011EZVEVNKXVW8FVZE198XEFFP.pox-fast-pool-v2))
    (try! (contract-call? .ccd002-treasury-nyc-mining-v2 delegate-stx u50000000000000 'SP21YTSM60CAY6D011EZVEVNKXVW8FVZE198XEFFP.pox-fast-pool-v2))

    ;; add treasuries to ccd005-city-data
    (try! (contract-call? .ccd005-city-data add-treasury miaId .ccd002-treasury-mia-mining-v2 "mining-v2"))
    (try! (contract-call? .ccd005-city-data add-treasury nycId .ccd002-treasury-nyc-mining-v2 "mining-v2"))

    ;; disable original mining contract and enable v2
    (try! (contract-call? .ccd006-citycoin-mining set-mining-enabled false))
    (try! (contract-call? .ccd006-citycoin-mining-v2 set-mining-enabled true))

    ;; set pool operator to self
    (try! (contract-call? .ccd011-stacking-payouts set-pool-operator SELF))

    ;; pay out missed MIA cycles 56, 57, 58, 59 with 1 uSTX each
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-mia u56 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-mia u57 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-mia u58 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-mia u59 MISSED_PAYOUT)))

    ;; pay out missed NYC cycles 56, 57, 58, 59 with 1 uSTX each
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-nyc u56 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-nyc u57 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-nyc u58 MISSED_PAYOUT)))
    (as-contract (try! (contract-call? .ccd011-stacking-payouts send-stacking-reward-nyc u59 MISSED_PAYOUT)))

    ;; set pool operator to Friedger pool
    (try! (contract-call? .ccd011-stacking-payouts set-pool-operator 'SP21YTSM60CAY6D011EZVEVNKXVW8FVZE198XEFFP))

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
    ;;(asserts! (and
    ;;  (>= block-height (var-get voteStart))
    ;;  (<= block-height (var-get voteEnd)))
    ;;  ERR_PROPOSAL_NOT_ACTIVE)
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
    ;; additional checks could be added here in future proposals
    ;; line below revised since vote will start at deployed height
    ;; (asserts! (>= block-height (var-get voteStart)) ERR_PROPOSAL_NOT_ACTIVE)
    ;; line below revised since vote will end when proposal executes
    ;; (asserts! (>= block-height (var-get voteEnd)) ERR_PROPOSAL_STILL_ACTIVE)
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
  (some CCIP_014)
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
      ;; MAINNET: MIA cycle 54 / first block BTC 779,450 STX 97,453
      (cycle54Hash (unwrap! (get-block-hash u97500) none))
      (cycle54Data (at-block cycle54Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u54 userId)))
      (cycle54Amount (get stacked cycle54Data))
      ;; MAINNET: MIA cycle 55 / first block BTC 781,550 STX 99,112
      (cycle55Hash (unwrap! (get-block-hash u99200) none))
      (cycle55Data (at-block cycle55Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u55 userId)))
      (cycle55Amount (get stacked cycle55Data))
      ;; MIA vote calculation
      (avgStacked (/ (+ (scale-up cycle54Amount) (scale-up cycle55Amount)) u2))
      (scaledVote (/ (* avgStacked MIA_SCALE_FACTOR) MIA_SCALE_BASE))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle54Amount u0) (> cycle55Amount u0)) none)
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
      ;; NYC cycle 54 / first block BTC 779,450 STX 97,453
      (cycle54Hash (unwrap! (get-block-hash u97500) none))
      (cycle54Data (at-block cycle54Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u54 userId)))
      (cycle54Amount (get stacked cycle54Data))
      ;; NYC cycle 55 / first block BTC 781,550 STX 99,112
      (cycle55Hash (unwrap! (get-block-hash u99200) none))
      (cycle55Data (at-block cycle55Hash (contract-call? .ccd007-citycoin-stacking get-stacker cityId u55 userId)))
      (cycle55Amount (get stacked cycle55Data))
      ;; NYC vote calculation
      (scaledVote (/ (+ (scale-up cycle54Amount) (scale-up cycle55Amount)) u2))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle54Amount u0) (> cycle55Amount u0)) none)
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

;; INITIALIZATION

;; fund proposal with 8 uSTX for payouts from deployer
(stx-transfer? (* MISSED_PAYOUT u8) tx-sender (as-contract tx-sender))
