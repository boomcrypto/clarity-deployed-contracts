---
title: "Trait reap-swap-helpers"
draft: true
---
```
;; TODO Add different error for different pairs
(define-constant ERR-GET-PAIR-BALANCE (err u109))


(define-constant ONE_8 u100000000)

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
      (stx-alex-pool (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-details 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token ONE_8)))
      (stx-alex-fee (mul-up stx-amount (get fee-rate-x stx-alex-pool)))
      (stx-net-fees (if (<= stx-amount stx-alex-fee) u0 (- stx-amount stx-alex-fee)))
      (alex-amount (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-y-given-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token ONE_8 stx-net-fees)))
      ;; GET ALEX-DIKO SWAP RESULT
      (alex-diko-pool (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-details 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko ONE_8)))
      (alex-diko-fee (mul-up alex-amount (get fee-rate-x alex-diko-pool)))
      (alex-net-fees (if (<= alex-amount alex-diko-fee) u0 (- alex-amount alex-diko-fee)))
      (diko-amount (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-y-given-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko ONE_8 alex-net-fees)))
    ) 
    (ok (/ diko-amount u100))
  )
)

(define-public (alexlab-get-diko-stx-swap-result (amount uint)) 
  (let 
    (
      (diko-amount (* amount u100))
      ;; GET DIKO-ALEX SWAP RESULT
      (alex-diko-pool (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-details 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko ONE_8)))
      (alex-diko-fee (mul-up diko-amount (get fee-rate-y alex-diko-pool)))
      (diko-net-fees (if (<= diko-amount alex-diko-fee) u0 (- diko-amount alex-diko-fee)))
      (alex-amount (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-x-given-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko ONE_8 diko-net-fees))) 
      ;; GET STX-ALEX SWAP RESULT
      (stx-alex-pool (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-pool-details 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token ONE_8)))
      (stx-alex-fee (mul-up alex-amount (get fee-rate-y stx-alex-pool)))
      (alex-net-fees (if (<= alex-amount stx-alex-fee) u0 (- alex-amount stx-alex-fee)))
      (stx-amount (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 get-x-given-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token ONE_8 alex-net-fees)))
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

(define-private (mul-up (a uint) (b uint))
  (let ((product (* a b)))
    (if (is-eq product u0)
      u0
      (+ u1 (/ (- product u1) ONE_8))
    )
  )
)
```
