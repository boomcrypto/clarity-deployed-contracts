---
title: "Trait magic-amber-horse"
draft: true
---
```
;; keeper-action-stx-ststx-v1

;; Implement keeper action trait
;; (impl-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-action-trait-v-1-1.keeper-action-trait)

;; Use all required traits
(use-trait keeper-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait keeper-action-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-action-trait-v-1-1.keeper-action-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait xyk-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-trait-v-1-2.xyk-staking-trait)
(use-trait xyk-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-emissions-trait-v-1-2.xyk-emissions-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stableswap-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-trait-v-1-2.stableswap-staking-trait)
(use-trait stableswap-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u10001))
(define-constant ERR_MINIMUM_RECEIVED (err u10002))
(define-constant ERR_INVALID_HELPER_DATA (err u10003))
(define-constant ERR_INVALID_PARAMETER_LIST (err u10004))
(define-constant ERR_INVALID_LIST_ELEMENT (err u10005))

;; ;; Get output for execute-action function
;; (define-public (get-output
;;     (amount uint) (min-received uint)
;;     (fee-recipient principal) (owner-address principal)
;;     (bitcoin-address (buff 64)) (keeper-address principal)
;;     (token-list (optional (list 26 <keeper-ft-trait>)))
;;     (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
;;     (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
;;     (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
;;     (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
;;     (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
;;     (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
;;     (uint-list (optional (list 26 uint)))
;;     (bool-list (optional (list 26 bool)))
;;     (principal-list (optional (list 26 principal)))
;; )
;;   (let (
;;     (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
;;     (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
;;     (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

;;     (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
;;     (token-trait-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
;;     (xyk-pool-trait (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    
;;     (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

;;     (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
;;     (amount-after-fee (- amount keeper-fee-amount))

;;     ;; Quote through both pools
;;     (xyk-result (unwrap-panic (xyk-qa amount-after-fee token-trait-a token-trait-b xyk-pool-trait)))
;;     (legacy-result (unwrap-panic (execute-legacy-quote xyk-result swaps-reversed)))
;;   )
;;     (ok legacy-result)
;;   )
;; )

;; Execute legacy pool swap
(define-public (execute-legacy-swap 
    (amount uint) 
    (min-out uint)
    (swaps-reversed bool)
)
    (if swaps-reversed
        (swap-legacy-y-to-x amount min-out)
        (swap-legacy-x-to-y amount min-out))
)

;; Helper functions for legacy pool swaps
(define-public (swap-legacy-x-to-y (amount uint) (min-out uint))
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y 
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        amount 
        min-out))

(define-public (swap-legacy-y-to-x (amount uint) (min-out uint))
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        amount 
        min-out))

;; Helper functions for legacy pool quotes
(define-public (quote-legacy-x-to-y (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy y-token lp-token amount))))
        (ok quote-result)))

(define-public (quote-legacy-y-to-x (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx y-token lp-token amount))))
        (ok quote-result))) 

;; Check if input and output tokens are swapped relative to the pool's x and y tokens
(define-private (is-xyk-path-reversed
    (token-in <keeper-ft-trait>) 
    (token-out <keeper-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not 
      (and 
        (is-eq (contract-of token-in) (get x-token pool-data))
        (is-eq (contract-of token-out) (get y-token pool-data))
      )
    )
  )
)

;; Perform XYK swap using swap-x-for-y or swap-y-for-x based on token path
(define-public (xyk-sa
    (amount uint)
    (token-in <keeper-ft-trait>) 
    (token-out <keeper-ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    
    ;; Perform swap based on path
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                      pool
                      token-in token-out
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
                      pool
                      token-out token-in
                      amount u1))))
  )
    (ok swap-a)
  )
)

;; Get XYK quote using get-dy or get-dx based on token path
(define-public (xyk-qa
    (amount uint)
    (token-in <keeper-ft-trait>) 
    (token-out <keeper-ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    
    ;; Get quote based on path
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                       pool
                       token-in token-out
                       amount))
                 (try! (contract-call?
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx
                       pool
                       token-out token-in
                       amount))))
  )
    (ok quote-a)
  )
)

;; ;; Execute action implementation
;; (define-public (execute-action
;;     (amount uint) (min-received uint)
;;     (fee-recipient principal) (owner-address principal)
;;     (bitcoin-address (buff 64)) (keeper-address principal)
;;     (token-list (optional (list 26 <keeper-ft-trait>)))
;;     (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
;;     (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
;;     (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
;;     (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
;;     (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
;;     (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
;;     (uint-list (optional (list 26 uint)))
;;     (bool-list (optional (list 26 bool)))
;;     (principal-list (optional (list 26 principal)))
;; )
;;   (let (
;;     ;; Same unwrapping logic as get-output
;;     (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
;;     (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
;;     (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

;;     (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
;;     (token-trait-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
;;     (xyk-pool-trait (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    
;;     (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

;;     (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
;;     (amount-after-fee (- amount keeper-fee-amount))

;;     ;; Execute both swaps
;;     (xyk-result (unwrap-panic (xyk-sa amount-after-fee token-trait-a token-trait-b xyk-pool-trait)))
;;     (legacy-result (unwrap-panic (execute-legacy-swap xyk-result min-received swaps-reversed)))
;;   )
;;     ;; Verify minimum received
;;     (asserts! (>= legacy-result min-received) ERR_MINIMUM_RECEIVED)
    
;;     ;; Print action data
;;     (print {
;;         action: "execute-action",
;;         contract: (as-contract tx-sender),
;;         caller: tx-sender,
;;         data: {
;;             keeper-fee-amount: keeper-fee-amount,
;;             swap-result: legacy-result
;;         }
;;     })
;;     (ok legacy-result)
;;   )
;; )

;; ;; Get minimum required
;; (define-public (get-minimum
;;     (amount uint) (min-received uint)
;;     (fee-recipient principal) (owner-address principal)
;;     (bitcoin-address (buff 64)) (keeper-address principal)
;;     (token-list (optional (list 26 <keeper-ft-trait>)))
;;     (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
;;     (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
;;     (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
;;     (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
;;     (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
;;     (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
;;     (uint-list (optional (list 26 uint)))
;;     (bool-list (optional (list 26 bool)))
;;     (principal-list (optional (list 26 principal)))
;; )
;;   (ok u0)
;; ) 
```
