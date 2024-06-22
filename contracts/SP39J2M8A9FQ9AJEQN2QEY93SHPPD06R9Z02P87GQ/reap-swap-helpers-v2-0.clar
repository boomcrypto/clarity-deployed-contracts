;; TODO Add different error for different pairs
(define-constant ERR-GET-PAIR-BALANCE (err u109))


(define-constant ONE_8 u100000000)
(define-constant FIXED_POOL_WEIGHT u50000000)

;; ============================================================================================================
;;                                              STX-DIKO SWAPS
;; ============================================================================================================

(define-public (arkadiko-get-stx-diko-swap-result (stx-amount uint))
  (let 
    (
      (stx-diko-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-diko-pair u0) ERR-GET-PAIR-BALANCE))
      (diko-pool-balance (unwrap! (element-at? stx-diko-pair u1) ERR-GET-PAIR-BALANCE))
      (stx-with-fees (/ (* u997 stx-amount) u1000))
    )
    (ok (/ (* stx-with-fees diko-pool-balance) (+ stx-with-fees stx-pool-balance)))
  )
)

(define-public (arkadiko-get-diko-stx-swap-result (diko-amount uint))
  (let 
    (
      (stx-diko-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-diko-pair u0) ERR-GET-PAIR-BALANCE))
      (diko-pool-balance (unwrap! (element-at? stx-diko-pair u1) ERR-GET-PAIR-BALANCE))
      (diko-with-fees (/ (* u997 diko-amount) u1000))
    )
    (ok (/ (* diko-with-fees stx-pool-balance) (+ diko-with-fees diko-pool-balance)))
  )
)

(define-public (alexlab-get-stx-diko-swap-result (amount uint)) 
  (let 
    (
      (stx-amount (* amount u100))
      ;; GET STX-ALEX SWAP RESULT
      (stx-alex-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex ONE_8)))
      (stx-alex-fee (mul-up stx-amount (get fee-rate-x stx-alex-pool)))
      (stx-net-fees (if (<= stx-amount stx-alex-fee) u0 (- stx-amount stx-alex-fee)))
      (alex-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex ONE_8 stx-net-fees)))
      ;; GET ALEX-DIKO SWAP RESULT
      (alex-diko-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8)))
      (alex-diko-fee (mul-up alex-amount (get fee-rate-x alex-diko-pool)))
      (alex-net-fees (if (<= alex-amount alex-diko-fee) u0 (- alex-amount alex-diko-fee)))
      (diko-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8 alex-net-fees)))
    ) 
    (ok (/ diko-amount u100))
  )
)

(define-public (alexlab-get-diko-stx-swap-result (amount uint)) 
  (let 
    (
      (diko-amount (* amount u100))
      ;; GET DIKO-ALEX SWAP RESULT
      (alex-diko-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8)))
      (alex-diko-fee (mul-up diko-amount (get fee-rate-y alex-diko-pool)))
      (diko-net-fees (if (<= diko-amount alex-diko-fee) u0 (- diko-amount alex-diko-fee)))
      (alex-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-x-given-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8 diko-net-fees))) 
      ;; GET STX-ALEX SWAP RESULT
      (stx-alex-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex ONE_8)))
      (stx-alex-fee (mul-up alex-amount (get fee-rate-y stx-alex-pool)))
      (alex-net-fees (if (<= alex-amount stx-alex-fee) u0 (- alex-amount stx-alex-fee)))
      (stx-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-x-given-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex ONE_8 alex-net-fees)))
    ) 
    (ok (/ stx-amount u100))
  )
)

(define-public (get-expected-diko-amount-with-best-ratio-swap (stx-amount uint))
  (let 
    (
      (alex-expected-swap-amount (try! (alexlab-get-stx-diko-swap-result stx-amount)))
      (arkadiko-expected-swap-amount (try! (arkadiko-get-stx-diko-swap-result stx-amount)))
    )
    (if (> alex-expected-swap-amount arkadiko-expected-swap-amount) 
      (ok alex-expected-swap-amount)
      (ok arkadiko-expected-swap-amount)
    )
  )
)

;; ;; ============================================================================================================
;; ;;                                              STX-USDA SWAPS
;; ;; ============================================================================================================

;; (define-public (arkadiko-get-stx-usda-swap-result (stx-amount uint))
;;   (let 
;;     (
;;       (stx-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
;;       (stx-pool-balance (unwrap! (element-at? stx-usda-pair u0) ERR-GET-PAIR-BALANCE))
;;       (usda-pool-balance (unwrap! (element-at? stx-usda-pair u1) ERR-GET-PAIR-BALANCE))
;;       (stx-with-fees (/ (* u997 stx-amount) u1000))
;;     )
;;     (ok (/ (* stx-with-fees usda-pool-balance) (+ stx-with-fees stx-pool-balance)))
;;   )
;; )

;; (define-public (arkadiko-get-usda-stx-swap-result (usda-amount uint))
;;   (let 
;;     (
;;       (stx-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
;;       (stx-pool-balance (unwrap! (element-at? stx-usda-pair u0) ERR-GET-PAIR-BALANCE))
;;       (usda-pool-balance (unwrap! (element-at? stx-usda-pair u1) ERR-GET-PAIR-BALANCE))
;;       (usda-with-fees (/ (* u997 usda-amount) u1000))
;;     )
;;     (ok (/ (* usda-with-fees stx-pool-balance) (+ usda-with-fees usda-pool-balance)))
;;   )
;; )

;; (define-public (alexlab-get-stx-usda-swap-result (amount uint)) 
;;   (let 
;;     (
;;       (stx-amount (* amount u100))
;;       ;; GET STX-ALEX SWAP RESULT
;;       (stx-alex-pool (try! (contract-call? .fixed-weight-pool-v1-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex FIXED_POOL_WEIGHT FIXED_POOL_WEIGHT)))
;;       (stx-alex-fee (mul-up stx-amount (get fee-rate-x stx-alex-pool)))
;;       (stx-net-fees (if (<= stx-amount stx-alex-fee) u0 (- stx-amount stx-alex-fee)))
;;       (alex-amount (try! (contract-call? .fixed-weight-pool-v1-01 get-y-given-wstx 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex FIXED_POOL_WEIGHT stx-net-fees)))
;;       ;; GET ALEX-USDA SWAP RESULT
;;       (alex-usda-pool (try! (contract-call? .simple-weight-pool-alex get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex .token-wusda)))
;;       (alex-usda-fee (mul-up alex-amount (get fee-rate-x alex-usda-pool)))
;;       (alex-net-fees (if (<= alex-amount alex-usda-fee) u0 (- alex-amount alex-usda-fee)))
;;       (usda-amount (try! (contract-call? .simple-weight-pool-alex get-y-given-alex .token-wusda alex-net-fees)))
;;     ) 
;;     (ok (/ usda-amount u100))
;;   )
;; )

;; (define-public (alexlab-get-usda-stx-swap-result (amount uint)) 
;;   (let 
;;     (
;;       (usda-amount (* amount u100))
;;       ;; GET DIKO-ALEX SWAP RESULT
;;       (alex-usda-pool (try! (contract-call? .simple-weight-pool-alex get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex .token-wusda)))
;;       (alex-usda-fee (mul-up usda-amount (get fee-rate-y alex-usda-pool)))
;;       (usda-net-fees (if (<= usda-amount alex-usda-fee) u0 (- usda-amount alex-usda-fee)))
;;       (alex-amount (try! (contract-call? .simple-weight-pool-alex get-alex-given-y .token-wusda usda-net-fees))) 
;;       ;; GET STX-ALEX SWAP RESULT
;;       (stx-alex-pool (try! (contract-call? .fixed-weight-pool-v1-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex FIXED_POOL_WEIGHT FIXED_POOL_WEIGHT)))
;;       (stx-alex-fee (mul-up alex-amount (get fee-rate-y stx-alex-pool)))
;;       (alex-net-fees (if (<= alex-amount stx-alex-fee) u0 (- alex-amount stx-alex-fee)))
;;       ;; (dx (try! (get-wstx-given-y token-y weight-y dy-net-fees)))
;;       (stx-amount (try! (contract-call? .fixed-weight-pool-v1-01 get-wstx-given-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex FIXED_POOL_WEIGHT alex-net-fees)))
;;     ) 
;;     (ok (/ stx-amount u100))
;;   )
;; )

;; (define-public (get-expected-usda-amount-with-best-ratio-swap (stx-amount uint))
;;   (let 
;;     (
;;       (alex-expected-swap-amount (try! (alexlab-get-stx-usda-swap-result stx-amount)))
;;       (arkadiko-expected-swap-amount (try! (arkadiko-get-stx-usda-swap-result stx-amount)))
;;     )
;;     (if (> alex-expected-swap-amount arkadiko-expected-swap-amount) 
;;       (ok alex-expected-swap-amount)
;;       (ok arkadiko-expected-swap-amount)
;;     )
;;   )
;; )


;; ;; ============================================================================================================
;; ;;                                              STX-USDA SWAPS
;; ;; ============================================================================================================

;; (define-public (arkadiko-get-diko-usda-swap-result (diko-amount uint))
;;   (let 
;;     (
;;       (diko-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
;;       (diko-pool-balance (unwrap! (element-at? diko-usda-pair u0) ERR-GET-PAIR-BALANCE))
;;       (usda-pool-balance (unwrap! (element-at? diko-usda-pair u1) ERR-GET-PAIR-BALANCE))
;;       (diko-with-fees (/ (* u997 diko-amount) u1000))
;;     )
;;     (ok (/ (* diko-with-fees usda-pool-balance) (+ diko-with-fees diko-pool-balance)))
;;   )
;; )

;; (define-public (arkadiko-get-usda-diko-swap-result (usda-amount uint))
;;   (let 
;;     (
;;       (diko-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
;;       (diko-pool-balance (unwrap! (element-at? diko-usda-pair u0) ERR-GET-PAIR-BALANCE))
;;       (usda-pool-balance (unwrap! (element-at? diko-usda-pair u1) ERR-GET-PAIR-BALANCE))
;;       (usda-with-fees (/ (* u997 usda-amount) u1000))
;;     )
;;     (ok (/ (* usda-with-fees diko-pool-balance) (+ usda-with-fees usda-pool-balance)))
;;   )
;; )

;; (define-public (alexlab-get-diko-usda-swap-result (amount uint)) 
;;   (let 
;;     (
;;       (diko-amount (* amount u100))
;;       ;; GET DIKO-ALEX SWAP RESULT
;;       (alex-diko-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8)))
;;       (alex-diko-fee (mul-up diko-amount (get fee-rate-y alex-diko-pool)))
;;       (diko-net-fees (if (<= diko-amount alex-diko-fee) u0 (- diko-amount alex-diko-fee)))
;;       (alex-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-x-given-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8 diko-net-fees))) 
;;       ;; GET ALEX-USDA SWAP RESULT
;;       (alex-usda-pool (try! (contract-call? .simple-weight-pool-alex get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex .token-wusda)))
;;       (alex-usda-fee (mul-up alex-amount (get fee-rate-x alex-usda-pool)))
;;       (alex-net-fees (if (<= alex-amount alex-usda-fee) u0 (- alex-amount alex-usda-fee)))
;;       (usda-amount (try! (contract-call? .simple-weight-pool-alex get-y-given-alex .token-wusda alex-net-fees)))
;;     ) 
;;     (ok (/ usda-amount u100))
;;   )
;; )

;; (define-public (alexlab-get-usda-diko-swap-result (amount uint)) 
;;   (let 
;;     (
;;       (usda-amount (* amount u100))
;;       ;; GET USDA-ALEX SWAP RESULT
;;       (alex-usda-pool (try! (contract-call? .simple-weight-pool-alex get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex .token-wusda)))
;;       (alex-usda-fee (mul-up usda-amount (get fee-rate-y alex-usda-pool)))
;;       (usda-net-fees (if (<= usda-amount alex-usda-fee) u0 (- usda-amount alex-usda-fee)))
;;       (alex-amount (try! (contract-call? .simple-weight-pool-alex get-alex-given-y .token-wusda usda-net-fees)))
;;       ;; GET ALEX-DIKO SWAP RESULT
;;       (alex-diko-pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8)))
;;       (alex-diko-fee (mul-up alex-amount (get fee-rate-x alex-diko-pool)))
;;       (alex-net-fees (if (<= alex-amount alex-diko-fee) u0 (- alex-amount alex-diko-fee)))
;;       (diko-amount (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-x-given-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8 alex-net-fees))) 
;;     ) 
;;     (ok (/ usda-amount u100))
;;   )
;; )


(define-private (mul-up (a uint) (b uint))
  (let ((product (* a b)))
    (if (is-eq product u0)
      u0
      (+ u1 (/ (- product u1) ONE_8))
    )
  )
)