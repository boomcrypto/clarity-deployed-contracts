;; TRAITS

(impl-trait .proposal-trait.proposal-trait)

;; ERRORS

(define-constant ERR_PANIC (err u1400))
(define-constant ERR_NOTHING_STACKED (err u1402))
(define-constant ERR_USER_NOT_FOUND (err u1403))
(define-constant ERR_NO_CITY_ID (err u1406))
(define-constant ERR_VOTE_FAILED (err u1407))

;; PUBLIC FUNCTIONS

;; supplements CCIP-014 and removes code that fails before cycle 60 starts
(define-public (execute (sender principal))
  (let
    (
      (miaId (unwrap! (contract-call? .ccd004-city-registry get-city-id "mia") ERR_PANIC))
      (nycId (unwrap! (contract-call? .ccd004-city-registry get-city-id "nyc") ERR_PANIC))
      (miaBalance (contract-call? .ccd002-treasury-mia-mining get-balance-stx))
      (nycBalance (contract-call? .ccd002-treasury-nyc-mining get-balance-stx))
    )

    ;; check vote complete/passed in CCIP-014
    (try! (is-executable))

    ;; enable mining v2 contracts in the DAO
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

    ;; set pool operator to Friedger pool
    (try! (contract-call? .ccd011-stacking-payouts set-pool-operator 'SP21YTSM60CAY6D011EZVEVNKXVW8FVZE198XEFFP))

    (ok true)
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-executable)
  (contract-call? .ccip014-pox-3 is-executable)
)
