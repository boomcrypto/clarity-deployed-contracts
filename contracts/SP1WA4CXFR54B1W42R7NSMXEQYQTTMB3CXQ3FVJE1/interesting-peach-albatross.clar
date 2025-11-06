;; interesting-peach-albatross

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .consistent-harlequin-crane.dlmm-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Error constants
(define-constant ERR_NO_RESULT_DATA (err u2001))
(define-constant ERR_BIN_SLIPPAGE (err u2002))
(define-constant ERR_MINIMUM_RECEIVED (err u2003))
(define-constant ERR_NO_ACTIVE_BIN_DATA (err u2004))
(define-constant ERR_EMPTY_SWAPS_LIST (err u2005))

;; Swap through multiple bins in multiple pools
(define-public (swap-multi
    (swaps (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, expected-bin-id: int, amount: uint, x-for-y: bool}))
    (min-received uint) (max-unfavorable-bins uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-multi swaps (ok {received: u0, unfavorable: u0}))))
    (received (get received swap-result))
  )
    (asserts! (> (len swaps) u0) ERR_EMPTY_SWAPS_LIST)
    (asserts! (<= (get unfavorable swap-result) max-unfavorable-bins) ERR_BIN_SLIPPAGE)
    (asserts! (>= received min-received) ERR_MINIMUM_RECEIVED)
    (ok received)
  )
)

;; Fold function to swap through multiple bins in multiple pools
(define-private (fold-swap-multi
    (swap {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, expected-bin-id: int, amount: uint, x-for-y: bool})
    (result (response {received: uint, unfavorable: uint} uint))
  )
  (let (
      (pool-trait (get pool-trait swap))
      (x-token-trait (get x-token-trait swap))
      (y-token-trait (get y-token-trait swap))
      (amount (get amount swap))
      (x-for-y (get x-for-y swap))
      (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
      (bin-id-delta (- active-bin-id (get expected-bin-id swap)))
      (is-unfavorable (if x-for-y (> bin-id-delta 0) (< bin-id-delta 0)))
      (swap-result (if x-for-y
                       (try! (contract-call? .working-amaranth-clownfish swap-x-for-y pool-trait x-token-trait y-token-trait active-bin-id amount))
                       (try! (contract-call? .working-amaranth-clownfish swap-y-for-x pool-trait x-token-trait y-token-trait active-bin-id amount))))
      (result-data (unwrap! result ERR_NO_RESULT_DATA))
  )
    (ok {
      received: (+ (get received result-data) swap-result),
      unfavorable: (+ (get unfavorable result-data) (if is-unfavorable (abs-int bin-id-delta) u0))
    })
  )
)

;; Get absolute value of a signed int as uint
(define-private (abs-int (value int))
  (to-uint (if (>= value 0) value (- value)))
)