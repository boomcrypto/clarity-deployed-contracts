;; TRAITS
(impl-trait 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.proposal-trait.proposal-trait)
(impl-trait 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccip015-trait.ccip015-trait)
;; ERRORS
(define-constant ERR_PANIC (err u16000))
(define-constant ERR_VOTED_ALREADY (err u16002))
(define-constant ERR_NOTHING_STACKED (err u16003))
(define-constant ERR_USER_NOT_FOUND (err u16004))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u16005))
(define-constant ERR_VOTE_FAILED (err u16007))
;; CONSTANTS
(define-constant SELF (as-contract tx-sender))
(define-constant CCIP_016 {
  name: "Refund Incorrect CCD007 Payouts",
  link: "https://github.com/citycoins/governance/blob/main/ccips/ccip-016/ccip-016-refund-incorrect-ccd007-payouts.md",
  hash: "2706386ba4309a9dd01530ec4299a08690edf6047846b45065f2715f4292c645",
})
;; set city ID
(define-constant MIA_ID (default-to u1 (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd004-city-registry get-city-id "mia")))
(define-constant NYC_ID (default-to u2 (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd004-city-registry get-city-id "nyc")))
(define-constant VOTE_SCALE_FACTOR (pow u10 u16)) ;; 16 decimal places
;; DATA VARS
;; vote block heights
(define-data-var voteActive bool true)
(define-data-var voteStart uint u0)
(define-data-var voteEnd uint u0)
;; start the vote when deployed
(var-set voteStart stacks-block-height)
;; vote tracking
(define-data-var yesVotes uint u0)
(define-data-var yesTotal uint u0)
(define-data-var noVotes uint u0)
(define-data-var noTotal uint u0)
;; DATA MAPS
(define-map CityVotes
  uint ;; city ID
  {
    ;; vote
    totalAmountYes: uint,
    totalAmountNo: uint,
    totalVotesYes: uint,
    totalVotesNo: uint,
  }
)
(define-map UserVotes
  uint ;; user ID
  {
    ;; vote
    vote: bool,
    mia: uint,
    nyc: uint,
  }
)
;; PUBLIC FUNCTIONS
(define-public (execute (sender principal))
  (begin
    ;; check vote is complete/passed
    (try! (is-executable))
    ;; update vote variables
    (var-set voteEnd stacks-block-height)
    (var-set voteActive false)
    (try! (pay-all-rewards))
    (ok true)
  )
)

(define-public (vote-on-proposal (vote bool))
  (let (
      (voterId (unwrap! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd003-user-registry get-user-id contract-caller)
        ERR_USER_NOT_FOUND
      ))
      (voterRecord (map-get? UserVotes voterId))
    )
    ;; check if vote is active
    (asserts! (var-get voteActive) ERR_PROPOSAL_NOT_ACTIVE)
    ;; check if vote record exists for user
    (match voterRecord
      record
      ;; if the voterRecord exists
      (let (
          (oldVote (get vote record))
          (miaVoteAmount (get mia record))
          (nycVoteAmount (get nyc record))
        )
        ;; check vote is not the same as before
        (asserts! (not (is-eq oldVote vote)) ERR_VOTED_ALREADY)
        ;; record the new vote for the user
        (map-set UserVotes voterId (merge record { vote: vote }))
        ;; update vote stats for each city
        (update-city-votes MIA_ID miaVoteAmount vote true)
        (update-city-votes NYC_ID nycVoteAmount vote true)
        (ok true)
      )
      ;; if the voterRecord does not exist
      (let (
          (miaVoteAmount (scale-down (default-to u0 (get-vote MIA_ID voterId true))))
          (nycVoteAmount (scale-down (default-to u0 (get-vote NYC_ID voterId true))))
        )
        ;; check that the user has a positive vote
        (asserts! (or (> miaVoteAmount u0) (> nycVoteAmount u0))
          ERR_NOTHING_STACKED
        )
        ;; insert new user vote record
        (map-insert UserVotes voterId {
          vote: vote,
          mia: miaVoteAmount,
          nyc: nycVoteAmount,
        })
        ;; update vote stats for each city
        (update-city-votes MIA_ID miaVoteAmount vote false)
        (update-city-votes NYC_ID nycVoteAmount vote false)
        (ok true)
      )
    )
  )
)

;; READ ONLY FUNCTIONS
(define-read-only (is-executable)
  (let (
      (votingRecord (unwrap! (get-vote-totals) ERR_PANIC))
      (miaRecord (get mia votingRecord))
      (nycRecord (get nyc votingRecord))
      (voteTotals (get totals votingRecord))
    )
    ;; check that there is at least one vote
    (asserts!
      (or (> (get totalVotesYes voteTotals) u0) (> (get totalVotesNo voteTotals) u0))
      ERR_VOTE_FAILED
    )
    ;; check that the yes total is more than no total
    (asserts! (> (get totalVotesYes voteTotals) (get totalVotesNo voteTotals))
      ERR_VOTE_FAILED
    )
    ;; allow execution
    (ok true)
  )
)

(define-read-only (is-vote-active)
  (some (var-get voteActive))
)

(define-read-only (get-proposal-info)
  (some CCIP_016)
)

(define-read-only (get-vote-period)
  (if (and
      (> (var-get voteStart) u0)
      (> (var-get voteEnd) u0)
    )
    ;; if both are set, return values
    (some {
      startBlock: (var-get voteStart),
      endBlock: (var-get voteEnd),
      length: (- (var-get voteEnd) (var-get voteStart)),
    })
    ;; else return none
    none
  )
)

(define-read-only (get-vote-total-mia)
  (map-get? CityVotes MIA_ID)
)

(define-read-only (get-vote-total-mia-or-default)
  (default-to {
    totalAmountYes: u0,
    totalAmountNo: u0,
    totalVotesYes: u0,
    totalVotesNo: u0,
  }
    (get-vote-total-mia)
  )
)

(define-read-only (get-vote-total-nyc)
  (map-get? CityVotes NYC_ID)
)

(define-read-only (get-vote-total-nyc-or-default)
  (default-to {
    totalAmountYes: u0,
    totalAmountNo: u0,
    totalVotesYes: u0,
    totalVotesNo: u0,
  }
    (get-vote-total-nyc)
  )
)

(define-read-only (get-vote-totals)
  (let (
      (miaRecord (get-vote-total-mia-or-default))
      (nycRecord (get-vote-total-nyc-or-default))
    )
    (some {
      mia: miaRecord,
      nyc: nycRecord,
      totals: {
        totalAmountYes: (+ (get totalAmountYes miaRecord) (get totalAmountYes nycRecord)),
        totalAmountNo: (+ (get totalAmountNo miaRecord) (get totalAmountNo nycRecord)),
        totalVotesYes: (+ (get totalVotesYes miaRecord) (get totalVotesYes nycRecord)),
        totalVotesNo: (+ (get totalVotesNo miaRecord) (get totalVotesNo nycRecord)),
      },
    })
  )
)

(define-read-only (get-voter-info (id uint))
  (map-get? UserVotes id)
)

;; vote calculation
;; returns (some uint) or (none)
;; optionally scaled by VOTE_SCALE_FACTOR (10^6)
(define-read-only (get-vote
    (cityId uint)
    (userId uint)
    (scaled bool)
  )
  (let (
      ;; MAINNET: cycle 82 / first block BTC 838,250 STX 145,643
      (cycle82Hash (unwrap! (get-block-hash u145643) none))
      (cycle u82)
      (cycle82Data (at-block cycle82Hash
        (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking get-stacker cityId cycle userId)
      ))
      (cycle82Amount (get stacked cycle82Data))
      ;; MAINNET: cycle 83 / first block BTC 840,350 STX 147,282
      (cycle83Hash (unwrap! (get-block-hash u147282) none))
      (cycle83Data (at-block cycle83Hash
        (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking get-stacker cityId (+ cycle u1) userId)
      ))
      (cycle83Amount (get stacked cycle83Data))
      ;; vote calculation
      (scaledVote (/ (+ (scale-up cycle82Amount) (scale-up cycle83Amount)) u2))
    )
    ;; check that at least one value is positive
    (asserts! (or (> cycle82Amount u0) (> cycle83Amount u0)) none)
    ;; return scaled or unscaled value
    (if scaled
      (some scaledVote)
      (some (/ scaledVote VOTE_SCALE_FACTOR))
    )
  )
)

;; PRIVATE FUNCTIONS
;; update city vote map
(define-private (update-city-votes
    (cityId uint)
    (voteAmount uint)
    (vote bool)
    (changedVote bool)
  )
  (let ((cityRecord (default-to {
      totalAmountYes: u0,
      totalAmountNo: u0,
      totalVotesYes: u0,
      totalVotesNo: u0,
    }
      (map-get? CityVotes cityId)
    )))
    ;; do not record if amount is 0
    (if (> voteAmount u0)
      ;; handle vote
      (if vote
        ;; handle yes vote
        (map-set CityVotes cityId {
          totalAmountYes: (+ voteAmount (get totalAmountYes cityRecord)),
          totalVotesYes: (+ u1 (get totalVotesYes cityRecord)),
          totalAmountNo: (if changedVote
            (- (get totalAmountNo cityRecord) voteAmount)
            (get totalAmountNo cityRecord)
          ),
          totalVotesNo: (if changedVote
            (- (get totalVotesNo cityRecord) u1)
            (get totalVotesNo cityRecord)
          ),
        })
        ;; handle no vote
        (map-set CityVotes cityId {
          totalAmountYes: (if changedVote
            (- (get totalAmountYes cityRecord) voteAmount)
            (get totalAmountYes cityRecord)
          ),
          totalVotesYes: (if changedVote
            (- (get totalVotesYes cityRecord) u1)
            (get totalVotesYes cityRecord)
          ),
          totalAmountNo: (+ voteAmount (get totalAmountNo cityRecord)),
          totalVotesNo: (+ u1 (get totalVotesNo cityRecord)),
        })
      )
      ;; ignore calls with vote amount equal to 0
      false
    )
  )
)

;; get block hash by height
(define-private (get-block-hash (blockHeight uint))
  (get-stacks-block-info? id-header-hash blockHeight)
)

;; CREDIT: ALEX math-fixed-point-16.clar
(define-private (scale-up (a uint))
  (* a VOTE_SCALE_FACTOR)
)

(define-private (scale-down (a uint))
  (/ a VOTE_SCALE_FACTOR)
)

(define-private (pay-all-rewards)
  (begin
    ;; MIA
    ;; 55: 24130341569 * 1352936000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u17996493 'SP32VE3A2AXWPGT7HH4B76005TJZQK7CF1MM9R0MD
    ))
    ;; 55: 24130341569 * 28700000000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u381761852 'SP1XHV60VPS13DYRN0HEYG8GYYA1S6QF90AXJ0NQR
    ))
    ;; 55: 24130341569 * 5000000000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u66509033 'SP30A13XJEHMK81JVEHMS0FEHFENS1W5KEEFYJDVM
    ))
    ;; 55: 24130341569 * 1000000000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u13301806 'SP1FV4FZ8D32S7GKYRPFWK6YHRJE5BZEYKABK72Q3
    ))
    ;; 55: 24130341569 * 170000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u2261 'SP3B1TPV7Z1767ZQ01RW93HRYR88ZQFX9M7NNXT3V
    ))
    ;; 55: 24130341569 * 900000000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u11971626 'SP33HRM920VHATSFNQ455WMKW9KCT74A5GT8280TB
    ))
    ;; 55: 24130341569 * 25000000000 / 1814064968141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u332545 'SPEW3AKP366Y0CY2322M6BWQY0C00JZAG59EP93C
    ))
    ;; 60: 30143370950 * 250000000000 / 2415283768331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u3120065 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 60: 30143370950 * 15576001000000 / 2415283768331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u194392552 'SP28R593JKNFH8PTWNECR84A83EESKC3CC5P826R5
    ))
    ;; 61: 24002944424 * 1410000000000 / 2381814892331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u14209396 'SP3PX186AERH9CD2A2R73KJYGX79EXHJP23RFGCZ4
    ))
    ;; 61: 24002944424 * 30167000000 / 2381814892331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u304010 'SP2JDKWQ77WN7S0PRCS872HFJ21ZT78P6G1WCW2B
    ))
    ;; 61: 24002944424 * 15000000000000 / 2381814892331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u151163790 'SP16BC59Y29FYZPP7WF8QB376STCVW33W4J9BWP06
    ))
    ;; 61: 24002944424 * 21502459000000 / 2381814892331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u216692879 'SP28R593JKNFH8PTWNECR84A83EESKC3CC5P826R5
    ))
    ;; 61: 24002944424 * 10000000000000 / 2381814892331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u100775860 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK
    ))
    ;; 63: 19641588871 * 1933783000000 / 2445440761331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u15531993 'SP3YJ9487PS0JDDYBBVH0RW3JPY48V0A86PQGDA6V
    ))
    ;; 63: 19641588871 * 2135228000000 / 2445440761331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u17149984 'SP3NX54B0VA0G002FBJE44C1ZJTV7F34VTPS7NB4J
    ))
    ;; 64: 16622163699 * 250000000000 / 2437154668331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1705078 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 64: 16622163699 * 45773000000 / 2437154668331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u312186 'SP19PMPW8J540BTF9S2D4J7W3RBB5CZM28P1BK573
    ))
    ;; 65: 18031083017 * 10000000000000 / 2421248123331462
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u74470199 'SP2Q8TC8QK1QGQEJFT24S4GBD6TQJ0HDC17RWNDQ8
    ))
    ;; 65: 18031083017 * 1500000000000 / 2421248123331462
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u11170529 'SP1ADC8EX6BRGEZVGGHJR44FYVSSD9VRA2JSHZ70B
    ))
    ;; 65: 18031083017 * 2123652000000 / 2421248123331462
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u15814878 'SP2DP70FRC4FFCZR5B2F6S112NK79WAFWHCWPYKQZ
    ))
    ;; 66: 21136466347 * 359529000000 / 2416842777141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u3144256 'SP2DP70FRC4FFCZR5B2F6S112NK79WAFWHCWPYKQZ
    ))
    ;; 66: 21136466347 * 314269000000 / 2416842777141271
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u2748435 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W
    ))
    ;; 68: 15092603850 * 250000000000 / 2565809340525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1470550 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 68: 15092603850 * 4239686000000 / 2565809340525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u24938681 'SP3CHC5CKZGPZ3W4Q4JASMM5ZSMD3P7TQWNSE6BQ8
    ))
    ;; 68: 15092603850 * 1333460000000 / 2565809340525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u7843678 'SP2Q8TC8QK1QGQEJFT24S4GBD6TQJ0HDC17RWNDQ8
    ))
    ;; 69: 14744214112 * 392962000000 / 2702344233525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u2144033 'SP1SYW6GETS33ZDY40N502NK8014KM4BTQ4RE4FS1
    ))
    ;; 69: 14744214112 * 705381000000 / 2702344233525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u3848617 'SP3B1TPV7Z1767ZQ01RW93HRYR88ZQFX9M7NNXT3V
    ))
    ;; 69: 14744214112 * 45773000000 / 2702344233525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u249741 'SP19PMPW8J540BTF9S2D4J7W3RBB5CZM28P1BK573
    ))
    ;; 71: 15933649223 * 4636311000000 / 2571783280525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u28724563 'SP2GGT4HSMSGS5XPEYHCAJTB7HJBPTMHJJ0MBSGHP
    ))
    ;; 71: 15933649223 * 53000000000 / 2571783280525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u328364 'SP30V7ZYEGGY0WQ6EJYZ040V3VHF4234FSTHP128D
    ))
    ;; 71: 15933649223 * 1500000000000 / 2571783280525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u9293346 'SP1ADC8EX6BRGEZVGGHJR44FYVSSD9VRA2JSHZ70B
    ))
    ;; 72: 13140642834 * 3593266000000 / 2660497302525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u17747744 'SP2W4B3KR2PYA980C4DFACT6K4MG6Z0DPT6X4CWH7
    ))
    ;; 72: 13140642834 * 2202860000000 / 2660497302525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u10880295 'SP2DP70FRC4FFCZR5B2F6S112NK79WAFWHCWPYKQZ
    ))
    ;; 72: 13140642834 * 250000000000 / 2660497302525590
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1234791 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 74: 13547686726 * 2078589000000 / 2578143002331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u10922618 'SP22YMFBE5CN1KGCHQDGZ06FF7B3HYFVN92P6Y5X9
    ))
    ;; 74: 13547686726 * 11000000000000 / 2578143002331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u57803059 'SP3F0GZC9WG53MH7SHMFVSM54XKNNHQXJ8Q301GQ7
    ))
    ;; 74: 13547686726 * 3000000000000 / 2578143002331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u15764470 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 74: 13547686726 * 45773000000 / 2578143002331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u240529 'SP19PMPW8J540BTF9S2D4J7W3RBB5CZM28P1BK573
    ))
    ;; 74: 13547686726 * 238572000000 / 2578143002331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1253653 'SP245RKH32CE9JPM26XKM4S0EVX3J17ANA595GA2Y
    ))
    ;; 75: 28962280296 * 16587934000000 / 2594656861331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u185159124 'SP32D4KF64M0FQQK267W8PA08SDXG00DNBB3WCXKT
    ))
    ;; 75: 28962280296 * 154875000000 / 2594656861331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1728757 'SP3BNAH4NPD79KWTABW4GH6QMQ10V34T8MMM39ZYP
    ))
    ;; 80: 7891090017 * 100000000000 / 2680077506331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u294435 'SP2YM5DT3RG8BBD10C59V3AGVTN66GKQ1A91T85Q4
    ))
    ;; 80: 7891090017 * 991822000000 / 2680077506331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u2920272 'SP1BN2V664W50A1HAWDHT2M83M3NMN0AG3B16R2SA
    ))
    ;; 80: 7891090017 * 250000000000 / 2680077506331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u736087 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 80: 7891090017 * 790402000000 / 2680077506331463
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u2327221 'SPVWPTGBEWVQ58J1RDNZQ34TMCRVF49RRFRKXC0Q
    ))
    ;; 82: 5912068120 * 714323000000 / 2653224175753016
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u1591695 'SP2VKCNC1M54EENQT3TWC4D974XRM4519YHKR24PK
    ))
    ;; 82: 5912068120 * 3975859000000 / 2653224175753016
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u8859239 'SP2W4B3KR2PYA980C4DFACT6K4MG6Z0DPT6X4CWH7
    ))
    ;; 82: 5912068120 * 10000000000000 / 2653224175753016
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u22282580 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 82: 5912068120 * 190338000000 / 2653224175753016
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u424122 'SPPYQ5TW7PWMNKHVNG194MACDAEGA1759D5DC7YA
    ))
    ;; 82: 5912068120 * 1995911000000 / 2653224175753016
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u4447404 'SP2GGT4HSMSGS5XPEYHCAJTB7HJBPTMHJJ0MBSGHP
    ))
    ;; 83: 30599097204 * 881694000000 / 2658980059358889
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u10146386 'SPFCFYYJGV3YR9HN9NTQ5P0THR788X260F3BS5VH
    ))
    ;; 83: 30599097204 * 3000000000000 / 2658980059358889
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u34523497 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 83: 30599097204 * 579522000000 / 2658980059358889
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u6669042 'SP2W5AT6FW839WN5VSNCZ6BTTHZRBKC9Y3H2NAZEJ
    ))
    ;; 83: 30599097204 * 7025335000000 / 2658980059358889
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-mia-stacking
      withdraw-stx u80846378 'SP3CHC5CKZGPZ3W4Q4JASMM5ZSMD3P7TQWNSE6BQ8
    ))
    ;; NYC
    ;; 55: 36583295214 * 986684000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u14117816 'SP32VE3A2AXWPGT7HH4B76005TJZQK7CF1MM9R0MD
    ))
    ;; 55: 36583295214 * 15939578000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u228069011 'SP2FSM29506QZYKJMFGNTAF2V6Q58K2Y61DDT7Y0F
    ))
    ;; 55: 36583295214 * 19800000000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u283305268 'SP59S3H7BRN23JR7BHHGK64CB8393BP1W2KCBZQW
    ))
    ;; 55: 36583295214 * 592179000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u8473102 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD
    ))
    ;; 55: 36583295214 * 3700000000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u52940883 'SP3Z6SRQ0AEK2X6P7J0C1FWEC7A7Y1QH01SY407BB
    ))
    ;; 55: 36583295214 * 30000000000000 / 2556780001971496
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u429250406 'SP30A13XJEHMK81JVEHMS0FEHFENS1W5KEEFYJDVM
    ))
    ;; 60: 45695032162 * 1431299000000 / 2993321854182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u21849723 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W
    ))
    ;; 60: 45695032162 * 20841359000000 / 2993321854182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u318157089 'SP28R593JKNFH8PTWNECR84A83EESKC3CC5P826R5
    ))
    ;; 61: 36386519532 * 2370000000000 / 2936173930182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u29370212 'SP3PX186AERH9CD2A2R73KJYGX79EXHJP23RFGCZ4
    ))
    ;; 61: 36386519532 * 1127975000000 / 2936173930182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u13978424 'SP1HYMMTAYXBX9WDJR9F66DCHBPK95HHSB0C1NZME
    ))
    ;; 61: 36386519532 * 27434899000000 / 2936173930182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u339986837 'SP28R593JKNFH8PTWNECR84A83EESKC3CC5P826R5
    ))
    ;; 61: 36386519532 * 1022537000000 / 2936173930182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u12671784 'SP1FV4FZ8D32S7GKYRPFWK6YHRJE5BZEYKABK72Q3
    ))
    ;; 61: 36386519532 * 1105412000000 / 2936173930182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u13698812 'SP1Q0GDNHDRJNKZZMXXCRCM8HNZ2JG8RPCD14W6P9
    ))
    ;; 63: 29773591836 * 1822167000000 / 3025633598182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u17930940 'SP20N3V2AF88G9VM10VBX01TB5R16ATE53AGFKYPV
    ))
    ;; 63: 29773591836 * 2302063000000 / 3025633598182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u22653332 'SP3YJ9487PS0JDDYBBVH0RW3JPY48V0A86PQGDA6V
    ))
    ;; 64: 25195947330 * 104500000000 / 2803012570182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u939338 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 65: 27330659232 * 10000000000000 / 3033564600182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u90094205 'SP2Q8TC8QK1QGQEJFT24S4GBD6TQJ0HDC17RWNDQ8
    ))
    ;; 65: 27330659232 * 1286202000000 / 3033564600182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u11587934 'SP2JBE48HC13J68PCRK2KF3PCNZMCQGYTN955EEFT
    ))
    ;; 66: 32036545780 * 2352389000000 / 2914323307182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u25859319 'SP164MRYJSPBPDK5CT6QDNQ73G4AHNK7G6PNK96NK
    ))
    ;; 66: 32036545780 * 10000000000000 / 2914323307182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u109927905 'SP1FECFVC2H0GJPMDQNPEMGYTF2MG7NA1AH23BES0
    ))
    ;; 66: 32036545780 * 7748554000000 / 2914323307182600
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u85178231 'SP28YTTXCKEVQJX5VC0STK8CDHR9TF4TQ3CYAXHH5
    ))
    ;; 68: 22875310501 * 104500000000 / 2970131399576388
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u804836 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 68: 22875310501 * 1477372000000 / 2970131399576388
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u11378400 'SP222YH94GYEPJJ88R1XH5MVTG3KNHNRRXVTMRRB1
    ))
    ;; 68: 22875310501 * 3064311000000 / 2970131399576388
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u23600661 'SP3CHC5CKZGPZ3W4Q4JASMM5ZSMD3P7TQWNSE6BQ8
    ))
    ;; 68: 22875310501 * 3358630000000 / 2970131399576388
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u25867442 'SP1JGPW1B6QYT8R5QJSZAY6SYGN0Z94D1P4PEA5R6
    ))
    ;; 69: 22346829090 * 65264000000 / 3126067261276388
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u466542 'SP1SYW6GETS33ZDY40N502NK8014KM4BTQ4RE4FS1
    ))
    ;; 71: 24147184987 * 114404000000 / 2996494979065284
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u921921 'SP30V7ZYEGGY0WQ6EJYZ040V3VHF4234FSTHP128D
    ))
    ;; 71: 24147184987 * 595700000000 / 2996494979065284
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u4800434 'SP245RKH32CE9JPM26XKM4S0EVX3J17ANA595GA2Y
    ))
    ;; 72: 19913782531 * 104500000000 / 3112301891851492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u668633 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 73: 15495109117 * 397600000000 / 3119552602508156
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u1974916 'SP322C73BSZGPEFNMND6XQQ53Y6QA3XEG0CTSY1WW
    ))
    ;; 73: 15495109117 * 9515232000000 / 3119552602508156
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u47263045 'SPMJ6PTDSHM17HCDQBV7FYYMM98R1Y2ZQ7GRM06W
    ))
    ;; 73: 15495109117 * 919270000000 / 3119552602508156
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u4566099 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1
    ))
    ;; 74: 20528917568 * 5002500000000 / 3142703827508160
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u32677565 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 75: 43886090272 * 216664000000 / 3112415494508160
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u3055034 'SP2D58ZHFVWMM3P0NPC4K254KH4SM5CM2Y7HJ269W
    ))
    ;; 75: 43886090272 * 10000000000 / 3112415494508160
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u141003 'SP10150G7DRPETGFXZQWQ0WRCJ6XQV1MEMZP6BVNH
    ))
    ;; 75: 43886090272 * 674238000000 / 3112415494508160
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u9506979 'SP31D7CHP0N8SVD89GMHYGBKHSXRESWZ9CW2JN6WP
    ))
    ;; 75: 43886090272 * 14870993000000 / 3112415494508160
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u209685931 'SP32D4KF64M0FQQK267W8PA08SDXG00DNBB3WCXKT
    ))
    ;; 80: 11956403387 * 3979651000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u15102307 'SPAFJV4RV0EFSB9FXT4BZ337FYDGVKA9H091WZMS
    ))
    ;; 80: 11956403387 * 8760619000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u33245517 'SP3BE1XPT0QE75DT3BMTSGGAR6NA4Q1A5TBBYMCKF
    ))
    ;; 80: 11956403387 * 9936720000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u37708682 'SP1BN2V664W50A1HAWDHT2M83M3NMN0AG3B16R2SA
    ))
    ;; 80: 11956403387 * 104700000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u397324 'SP3EXTHZ7PHAJ8DDJB7AMVQXDZ6T68364EZ01WB20
    ))
    ;; 80: 11956403387 * 4942246000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u18755241 'SP31N22Y35NH8R7XQF2Q0WJ17JRTSG1RMKPS15DRS
    ))
    ;; 80: 11956403387 * 1958658000000 / 3150665164841492
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u7432876 'SPVWPTGBEWVQ58J1RDNZQ34TMCRVF49RRFRKXC0Q
    ))
    ;; 81: 8494571191 * 4413486000000 / 3316887116310060
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u11302968 'SP31N22Y35NH8R7XQF2Q0WJ17JRTSG1RMKPS15DRS
    ))
    ;; 82: 8958011022 * 460387000000 / 3039524418778628
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u1356841 'SP2H4HFERWC4208VW51BPGT9C2J74MT1W5JDBGZAZ
    ))
    ;; 82: 8958011022 * 10000000000000 / 3039524418778628
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u29471752 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 82: 8958011022 * 3429056000000 / 3039524418778628
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u10106028 'SP1JGPW1B6QYT8R5QJSZAY6SYGN0Z94D1P4PEA5R6
    ))
    ;; 83: 46365579712 * 694062000000 / 3082839168247196
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u10438620 'SPFCFYYJGV3YR9HN9NTQ5P0THR788X260F3BS5VH
    ))
    ;; 83: 46365579712 * 5002500000000 / 3082839168247196
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u75237078 'SPR51QGAQ1QKCZ8YBJFHKVMTS6Z858BV20QY0819
    ))
    ;; 83: 46365579712 * 5805152000000 / 3082839168247196
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u87308880 'SP3CHC5CKZGPZ3W4Q4JASMM5ZSMD3P7TQWNSE6BQ8
    ))
    ;; 83: 46365579712 * 8100000000000 / 3082839168247196
    (try! (contract-call?
      'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-nyc-stacking
      withdraw-stx u121823155 'SP3JXKKD4MAN04MC0AYJ7WKAKXYJ8RC1S60D6CVPX
    ))
    (ok true)
  )
)
