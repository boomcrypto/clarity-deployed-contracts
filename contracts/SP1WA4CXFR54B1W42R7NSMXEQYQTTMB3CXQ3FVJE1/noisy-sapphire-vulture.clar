;; dlmm-swap-helper-v-1-1

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .amused-teal-basilisk.dlmm-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NO_RESULT_DATA (err u2001))
(define-constant ERR_MINIMUM_RECEIVED (err u2002))

;; Swap through multiple bins in multiple pools
(define-public (swap-helper
    (swaps (list 120 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, amount: uint, x-for-y: bool}))
    (min-received uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-helper swaps (ok u0))))
  )
    (asserts! (>= swap-result min-received) ERR_MINIMUM_RECEIVED)
    (ok swap-result)
  )
)

;; Fold function to swap through multiple bins in multiple pools
(define-private (fold-swap-helper
    (swap {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, amount: uint, x-for-y: bool})
    (result (response uint uint))
  )
  (let (
    (swap-result (if (get x-for-y swap)
                     (try! (contract-call? .statutory-apricot-mule swap-x-for-y (get pool-trait swap) (get x-token-trait swap) (get y-token-trait swap) (get bin-id swap) (get amount swap)))
                     (try! (contract-call? .statutory-apricot-mule swap-y-for-x (get pool-trait swap) (get x-token-trait swap) (get y-token-trait swap) (get bin-id swap) (get amount swap)))))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) swap-result))
  )
    (ok updated-result)
  )
)