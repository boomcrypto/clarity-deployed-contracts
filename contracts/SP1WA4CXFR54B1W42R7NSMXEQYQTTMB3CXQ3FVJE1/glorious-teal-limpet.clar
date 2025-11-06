;; glorious-teal-limpet

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .amused-teal-basilisk.dlmm-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NO_RESULT_DATA (err u2001))
(define-constant ERR_MINIMUM_X_AMOUNT (err u2002))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u2003))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u2004))

;; Add liquidity to multiple bins in multiple pools
(define-public (add-liquidity-helper
    (positions (list 120 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, x-amount: uint, y-amount: uint}))
    (min-dlp uint)
  )
  (let (
    (add-liquidity-result (try! (fold fold-add-liquidity-helper positions (ok u0))))
  )
    (asserts! (>= add-liquidity-result min-dlp) ERR_MINIMUM_LP_AMOUNT)
    (ok add-liquidity-result)
  )
)

;; Withdraw liquidity from multiple bins in multiple pools
(define-public (withdraw-liquidity-helper
    (positions (list 120 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, amount: uint}))
    (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    (withdraw-liquidity-result (try! (fold fold-withdraw-liquidity-helper positions (ok {x-amount: u0, y-amount: u0}))))
  )
    (asserts! (>= (get x-amount withdraw-liquidity-result) min-x-amount) ERR_MINIMUM_X_AMOUNT)
    (asserts! (>= (get y-amount withdraw-liquidity-result) min-y-amount) ERR_MINIMUM_Y_AMOUNT)
    (ok withdraw-liquidity-result)
  )
)


;; Fold function to add liquidity to multiple bins in multiple pools
(define-private (fold-add-liquidity-helper
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, x-amount: uint, y-amount: uint})
    (result (response uint uint))
  )
  (let (
    (add-liquidity-result (try! (contract-call? .statutory-apricot-mule add-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) (get bin-id position) (get x-amount position) (get y-amount position) u1)))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) add-liquidity-result))
  )
    (ok updated-result)
  )
)

;; Fold function to withdraw liquidity from multiple bins in multiple pools
(define-private (fold-withdraw-liquidity-helper
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: uint, amount: uint})
    (result (response {x-amount: uint, y-amount: uint} uint))
  )
  (let (
    (result-data (unwrap! result ERR_NO_RESULT_DATA))
    (bin-id (get bin-id position))
    (min-x-amount (if (>= bin-id u500) u1 u0))
    (min-y-amount (if (>= bin-id u500) u0 u1))
    (withdraw-liquidity-result (try! (contract-call? .statutory-apricot-mule withdraw-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) bin-id (get amount position) min-x-amount min-y-amount)))
    (updated-x-amount (+ (get x-amount result-data) (get x-amount withdraw-liquidity-result)))
    (updated-y-amount (+ (get y-amount result-data) (get y-amount withdraw-liquidity-result)))
  )
    (ok {x-amount: updated-x-amount, y-amount: updated-y-amount})
  )
)