---
title: "Trait keeper-action-xyk-legacy-rc3"
draft: true
---
```
;; keeper-action-xyk-legacy-v1

;; Implement keeper action trait
(impl-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-action-trait-v-1-1.keeper-action-trait)

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
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

;; ========= Legacy Pool Functions =========

;; Quote STX to stSTX
(define-public (quote-legacy-stx-to-ststx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy y-token lp-token amount))))
        (ok quote-result)))

;; Quote stSTX to STX
(define-public (quote-legacy-ststx-to-stx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx y-token lp-token amount))))
        (ok quote-result)))

;; Execute legacy quote based on direction
(define-public (execute-legacy-quote (amount uint) (token-in <ft-trait>) (token-out <ft-trait>))
    (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (quote-legacy-stx-to-ststx amount)
        (quote-legacy-ststx-to-stx amount)))

;; Swap STX to stSTX
(define-public (swap-legacy-stx-to-ststx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y y-token lp-token amount u1))))
        (ok swap-result)))

;; Swap stSTX to STX
(define-public (swap-legacy-ststx-to-stx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x y-token lp-token amount u1))))
        (ok swap-result)))

;; Execute legacy swap based on direction
(define-public (execute-legacy-swap (amount uint) (token-in <ft-trait>) (token-out <ft-trait>))
    (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (swap-legacy-stx-to-ststx amount)
        (swap-legacy-ststx-to-stx amount)))

;; ========= XYK Pool Functions =========

;; Check if path is reversed relative to pool
(define-private (is-xyk-path-reversed
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
    (pool-contract <xyk-pool-trait>))
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool))))
    (not (and 
        (is-eq (contract-of token-in) (get x-token pool-data))
        (is-eq (contract-of token-out) (get y-token pool-data))))))

;; Get XYK quote
(define-public (xyk-quote
    (amount uint)
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
    (pool <xyk-pool-trait>))
  (let (
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    (quote-result (if (is-eq is-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy pool token-in token-out amount))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx pool token-out token-in amount)))))
    (ok quote-result)))

;; Execute XYK swap
(define-public (xyk-swap
    (amount uint)
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
    (pool <xyk-pool-trait>))
  (let (
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    (swap-result (if (is-eq is-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y pool token-in token-out amount u1))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x pool token-out token-in amount u1)))))
    (ok swap-result)))

;; ========= Double Swap Functions =========

;; Quote Legacy then XYK
(define-public (quote-legacy-then-xyk
    (amount uint)
    (token-a <ft-trait>)
    (token-b <ft-trait>)
    (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>))
  (let (
    (legacy-quote (unwrap-panic (execute-legacy-quote amount token-a token-b)))
    (xyk-quote-result (unwrap-panic (xyk-quote legacy-quote token-b token-c xyk-pool))))
    (ok xyk-quote-result)))

;; Quote XYK then Legacy
(define-public (quote-xyk-then-legacy
    (amount uint)
    (token-a <ft-trait>)
    (token-b <ft-trait>)
    (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>))
  (let (
    (xyk-quote-result (unwrap-panic (xyk-quote amount token-a token-b xyk-pool)))
    (legacy-quote (unwrap-panic (execute-legacy-quote xyk-quote-result token-b token-c))))
    (ok legacy-quote)))

;; Execute Legacy then XYK swap
(define-public (swap-legacy-then-xyk
    (amount uint)
    (token-a <ft-trait>)
    (token-b <ft-trait>)
    (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>))
  (let (
    (legacy-swap (unwrap-panic (execute-legacy-swap amount token-a token-b)))
    (xyk-swap-result (unwrap-panic (xyk-swap legacy-swap token-b token-c xyk-pool))))
    (ok xyk-swap-result)))

;; Execute XYK then Legacy swap
(define-public (swap-xyk-then-legacy
    (amount uint)
    (token-a <ft-trait>)
    (token-b <ft-trait>)
    (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>))
  (let (
    (xyk-swap-result (unwrap-panic (xyk-swap amount token-a token-b xyk-pool)))
    (legacy-swap (unwrap-panic (execute-legacy-swap xyk-swap-result token-b token-c))))
    (ok legacy-swap)))

;; ========= Main Keeper Action Functions =========

;; Get output for execute-action function
(define-public (get-output
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
)
  (let (
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))
    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount))
    (result (if swaps-reversed
        (unwrap-panic (quote-legacy-then-xyk amount-after-fee token-a token-b token-c xyk-pool))
        (unwrap-panic (quote-xyk-then-legacy amount-after-fee token-a token-b token-c xyk-pool)))))
    (ok result)))

;; Execute action implementation
(define-public (execute-action
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
)
  (let (
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))
    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount)))

    ;; Transfer keeper fee if applicable
    (if (> keeper-fee-amount u0)
        (try! (contract-call? token-a transfer keeper-fee-amount tx-sender fee-recipient none))
        false)

    ;; Execute swaps based on path direction
    (let ((result (if swaps-reversed
            (unwrap-panic (swap-legacy-then-xyk amount-after-fee token-a token-b token-c xyk-pool))
            (unwrap-panic (swap-xyk-then-legacy amount-after-fee token-a token-b token-c xyk-pool)))))

        ;; Assert result meets minimum
        (asserts! (>= result min-received) ERR_MINIMUM_RECEIVED)

        ;; Print swap info
        (print {
            action: "execute-action",
            keeper: keeper-address,
            data: {
                amount: amount,
                keeper-fee-amount: keeper-fee-amount,
                swap-result: result
            }
        })

        (ok result))))

;; Get minimum required
(define-public (get-minimum
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
)
  (ok u0))
```
