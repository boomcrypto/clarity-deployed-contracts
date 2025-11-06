;; stableswap-midpoint-usdh-susdh-v-1-1

;; Error constants
(define-constant ERR_NO_POOL_DATA (err u1008))
(define-constant ERR_MIDPOINT_ALREADY_UPDATED (err u1033))

;; Public function to check if the pool's midpoint values can be updated
(define-public (get-can-update-midpoint)
  (let (
    (pool-data (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4 get-pool) ERR_NO_POOL_DATA))
    (primary-denominator (get midpoint-primary-denominator pool-data))
    (updated-denominator (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-v1 get-usdh-per-susdh))
  )
    (ok (not (is-eq primary-denominator updated-denominator)))
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
    (updated-denominator (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-v1 get-usdh-per-susdh))
  )
    (begin
      (asserts! (not (is-eq primary-denominator updated-denominator)) ERR_MIDPOINT_ALREADY_UPDATED)
      (try! (as-contract (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-4 set-midpoint
                         'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4 primary-numerator updated-denominator
                         withdraw-numerator withdraw-denominator)))
      (print {
        action: "update-midpoint",
        caller: tx-sender,
        data: {
          primary-numerator: primary-numerator,
          primary-denominator: primary-denominator,
          withdraw-numerator: withdraw-numerator,
          withdraw-denominator: withdraw-denominator,
          updated-denominator: updated-denominator
        }
      })
      (ok true)
    )
  )
)