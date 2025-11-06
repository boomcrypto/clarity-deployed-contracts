;; previous-moccasin-penguin

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .consistent-harlequin-crane.dlmm-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NO_RESULT_DATA (err u2001))
(define-constant ERR_MINIMUM_X_AMOUNT (err u2002))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u2003))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u2004))
(define-constant ERR_NO_ACTIVE_BIN_DATA (err u2005))
(define-constant ERR_EMPTY_POSITIONS_LIST (err u2006))

;; Add liquidity to multiple bins in multiple pools
(define-public (add-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: int, x-amount: uint, y-amount: uint}))
    (min-dlp uint)
  )
  (let (
    (add-liquidity-result (try! (fold fold-add-liquidity-multi positions (ok u0))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= add-liquidity-result min-dlp) ERR_MINIMUM_LP_AMOUNT)
    (ok add-liquidity-result)
  )
)

;; Add liquidity to multiple bins in multiple pools relative to the active bin
(define-public (add-relative-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, active-bin-id-offset: int, x-amount: uint, y-amount: uint}))
    (min-dlp uint)
  )
  (let (
    (add-liquidity-result (try! (fold fold-add-relative-liquidity-multi positions (ok u0))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= add-liquidity-result min-dlp) ERR_MINIMUM_LP_AMOUNT)
    (ok add-liquidity-result)
  )
)

;; Withdraw liquidity from multiple bins in multiple pools
(define-public (withdraw-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: int, amount: uint}))
    (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    (withdraw-liquidity-result (try! (fold fold-withdraw-liquidity-multi positions (ok {x-amount: u0, y-amount: u0}))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= (get x-amount withdraw-liquidity-result) min-x-amount) ERR_MINIMUM_X_AMOUNT)
    (asserts! (>= (get y-amount withdraw-liquidity-result) min-y-amount) ERR_MINIMUM_Y_AMOUNT)
    (ok withdraw-liquidity-result)
  )
)

;; Withdraw liquidity from multiple bins in multiple pools relative to the active bin
(define-public (withdraw-relative-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, active-bin-id-offset: int, amount: uint}))
    (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    (withdraw-liquidity-result (try! (fold fold-withdraw-relative-liquidity-multi positions (ok {x-amount: u0, y-amount: u0}))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= (get x-amount withdraw-liquidity-result) min-x-amount) ERR_MINIMUM_X_AMOUNT)
    (asserts! (>= (get y-amount withdraw-liquidity-result) min-y-amount) ERR_MINIMUM_Y_AMOUNT)
    (ok withdraw-liquidity-result)
  )
)

;; Move liquidity for multiple bins in multiple pools
(define-public (move-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, from-bin-id: int, to-bin-id: int, amount: uint}))
    (min-dlp uint)
  )
  (let (
    (move-liquidity-result (try! (fold fold-move-liquidity-multi positions (ok u0))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= move-liquidity-result min-dlp) ERR_MINIMUM_LP_AMOUNT)
    (ok move-liquidity-result)
  )
)

;; Move liquidity for multiple bins in multiple pools relative to the active bin
(define-public (move-relative-liquidity-multi
    (positions (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, from-bin-id: int, active-bin-id-offset: int, amount: uint}))
    (min-dlp uint)
  )
  (let (
    (move-liquidity-result (try! (fold fold-move-relative-liquidity-multi positions (ok u0))))
  )
    (asserts! (> (len positions) u0) ERR_EMPTY_POSITIONS_LIST)
    (asserts! (>= move-liquidity-result min-dlp) ERR_MINIMUM_LP_AMOUNT)
    (ok move-liquidity-result)
  )
)

;; Fold function to add liquidity to multiple bins in multiple pools
(define-private (fold-add-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: int, x-amount: uint, y-amount: uint})
    (result (response uint uint))
  )
  (let (
    (add-liquidity-result (try! (contract-call? .working-amaranth-clownfish add-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) (get bin-id position) (get x-amount position) (get y-amount position) u1)))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) add-liquidity-result))
  )
    (ok updated-result)
  )
)

;; Fold function to add liquidity to multiple bins in multiple pools relative to the active bin
(define-private (fold-add-relative-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, active-bin-id-offset: int, x-amount: uint, y-amount: uint})
    (result (response uint uint))
  )
  (let (
    (pool-trait (get pool-trait position))
    (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
    (bin-id (+ active-bin-id (get active-bin-id-offset position)))
    (add-liquidity-result (try! (contract-call? .working-amaranth-clownfish add-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) bin-id (get x-amount position) (get y-amount position) u1)))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) add-liquidity-result))
  )
    (ok updated-result)
  )
)

;; Fold function to withdraw liquidity from multiple bins in multiple pools
(define-private (fold-withdraw-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, bin-id: int, amount: uint})
    (result (response {x-amount: uint, y-amount: uint} uint))
  )
  (let (
    (result-data (unwrap! result ERR_NO_RESULT_DATA))
    (pool-trait (get pool-trait position))
    (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
    (bin-id (get bin-id position))
    (min-x-amount (if (>= bin-id active-bin-id) u1 u0))
    (min-y-amount (if (>= bin-id active-bin-id) u0 u1))
    (withdraw-liquidity-result (try! (contract-call? .working-amaranth-clownfish withdraw-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) bin-id (get amount position) min-x-amount min-y-amount)))
    (updated-x-amount (+ (get x-amount result-data) (get x-amount withdraw-liquidity-result)))
    (updated-y-amount (+ (get y-amount result-data) (get y-amount withdraw-liquidity-result)))
  )
    (ok {x-amount: updated-x-amount, y-amount: updated-y-amount})
  )
)

;; Fold function to withdraw liquidity from multiple bins in multiple pools relative to the active bin
(define-private (fold-withdraw-relative-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, active-bin-id-offset: int, amount: uint})
    (result (response {x-amount: uint, y-amount: uint} uint))
  )
  (let (
    (result-data (unwrap! result ERR_NO_RESULT_DATA))
    (pool-trait (get pool-trait position))
    (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
    (bin-id (+ active-bin-id (get active-bin-id-offset position)))
    (min-x-amount (if (>= bin-id active-bin-id) u1 u0))
    (min-y-amount (if (>= bin-id active-bin-id) u0 u1))
    (withdraw-liquidity-result (try! (contract-call? .working-amaranth-clownfish withdraw-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) bin-id (get amount position) min-x-amount min-y-amount)))
    (updated-x-amount (+ (get x-amount result-data) (get x-amount withdraw-liquidity-result)))
    (updated-y-amount (+ (get y-amount result-data) (get y-amount withdraw-liquidity-result)))
  )
    (ok {x-amount: updated-x-amount, y-amount: updated-y-amount})
  )
)

;; Fold function to move liquidity for multiple bins in multiple pools
(define-private (fold-move-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, from-bin-id: int, to-bin-id: int, amount: uint})
    (result (response uint uint))
  )
  (let (
    (move-liquidity-result (try! (contract-call? .working-amaranth-clownfish move-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) (get from-bin-id position) (get to-bin-id position) (get amount position) u1)))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) move-liquidity-result))
  )
    (ok updated-result)
  )
)

;; Fold function to move liquidity for multiple bins in multiple pools relative to the active bin
(define-private (fold-move-relative-liquidity-multi
    (position {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, from-bin-id: int, active-bin-id-offset: int, amount: uint})
    (result (response uint uint))
  )
  (let (
    (pool-trait (get pool-trait position))
    (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
    (to-bin-id (+ active-bin-id (get active-bin-id-offset position)))
    (move-liquidity-result (try! (contract-call? .working-amaranth-clownfish move-liquidity (get pool-trait position) (get x-token-trait position) (get y-token-trait position) (get from-bin-id position) to-bin-id (get amount position) u1)))
    (updated-result (+ (unwrap! result ERR_NO_RESULT_DATA) move-liquidity-result))
  )
    (ok updated-result)
  )
)