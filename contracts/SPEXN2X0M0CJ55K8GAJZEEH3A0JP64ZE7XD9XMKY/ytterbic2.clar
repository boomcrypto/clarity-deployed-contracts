;; stableswap-midpoint-stx-ststx-v-1-1

;; Error constants
(define-constant ERR_NO_POOL_DATA (err u1008))
(define-constant ERR_INVALID_MIDPOINT_NUMERATOR (err u1027))

;; Public function to check if the pool's midpoint values can be updated
(define-public (get-can-update-midpoint)
  (let (
    (pool-data (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4 get-pool) ERR_NO_POOL_DATA))
    (primary-numerator (get midpoint-primary-numerator pool-data))
    (updated-numerator (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                             'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1)))
  )
    (ok (not (is-eq primary-numerator updated-numerator)))
  )
)

;; Public function to update the pool's midpoint values
(define-public (update-midpoint)
  (let (
    (pool-data (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4 get-pool) ERR_NO_POOL_DATA))
    (primary-numerator (get midpoint-primary-numerator pool-data))
    (primary-denominator (get midpoint-primary-denominator pool-data))
    (withdraw-numerator (get midpoint-withdraw-numerator pool-data))
    (withdraw-denominator (get midpoint-withdraw-denominator pool-data))
    (updated-numerator (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                             'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1)))
  )
    (begin
      (asserts! (not (is-eq primary-numerator updated-numerator)) ERR_INVALID_MIDPOINT_NUMERATOR)
      ;;(try! (as-contract (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-4 set-midpoint
      ;;                   'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4 updated-numerator primary-denominator
      ;;                   withdraw-numerator withdraw-denominator)))
      (print {
        action: "update-midpoint",
        caller: tx-sender,
        data: {
          primary-numerator: primary-numerator,
          primary-denominator: primary-denominator,
          withdraw-numerator: withdraw-numerator,
          withdraw-denominator: withdraw-denominator,
          updated-numerator: updated-numerator
        }
      })
      (ok true)
    )
  )
)