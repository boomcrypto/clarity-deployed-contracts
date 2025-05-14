---
title: "Trait keeper-action-4-v-1-1"
draft: true
---
```

;; keeper-action-4-v-1-1

;; Implement keeper action trait
(impl-trait .keeper-action-trait-v-1-1.keeper-action-trait)

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait keeper-action-trait .keeper-action-trait-v-1-1.keeper-action-trait)
(use-trait xyk-pool-trait .xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait xyk-staking-trait .xyk-staking-trait-v-1-2.xyk-staking-trait)
(use-trait xyk-emissions-trait .xyk-emissions-trait-v-1-2.xyk-emissions-trait)
(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stableswap-staking-trait .stableswap-staking-trait-v-1-2.stableswap-staking-trait)
(use-trait stableswap-emissions-trait .stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u10001))
(define-constant ERR_MINIMUM_RECEIVED (err u10002))
(define-constant ERR_INVALID_HELPER_DATA (err u10003))
(define-constant ERR_INVALID_PARAMETER_LIST (err u10004))
(define-constant ERR_INVALID_LIST_ELEMENT (err u10005))

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
    ;; Unwrap required lists from parameters
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get tokens and XYK pool traits
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get swaps reversed (false = XYK -> STX-stSTX)
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))
    
    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount))
    
    ;; Get quote for swap
    (quote-result (if swaps-reversed
      (unwrap-panic (quote-legacy-then-xyk amount-after-fee token-a token-b token-c xyk-pool))
      (unwrap-panic (quote-xyk-then-legacy amount-after-fee token-a token-b token-c xyk-pool)))
    )
  )
    ;; Return quote-result
    (ok quote-result)
  )
)

;; Get minimum amount for execute-action function
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
    (ok u0)
)

;; Perform execute-action function
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
    ;; Unwrap required lists from parameters
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get tokens and XYK pool traits
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    
    ;; Get swaps reversed (false = XYK -> STX-stSTX)
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))
    
    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? token-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Perform swap
    (swap-result (if swaps-reversed
      (unwrap-panic (swap-legacy-then-xyk amount-after-fee token-a token-b token-c xyk-pool))
      (unwrap-panic (swap-xyk-then-legacy amount-after-fee token-a token-b token-c xyk-pool)))
    )
  )
    (begin
      ;; Assert swap-result is greater than or equal to min-received
      (asserts! (>= swap-result min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return swap-result
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          swaps-reversed: swaps-reversed,
          swap-result: swap-result
        }
      })
      (ok swap-result)
    )
  )
)

;; Check if token path is relative to x and y tokens in XYK pool
(define-private (is-xyk-path-reversed
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not (and
      (is-eq (contract-of token-in) (get x-token pool-data))
      (is-eq (contract-of token-out) (get y-token pool-data)))
    )
  )
)

;; Get quote for swap via XYK pool based on token path
(define-private (xyk-quote
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    (quote-result (if (is-eq is-reversed false)
      (try! (contract-call? .xyk-core-v-1-2 get-dy pool token-in token-out amount))
      (try! (contract-call? .xyk-core-v-1-2 get-dx pool token-out token-in amount))))
  )
    (ok quote-result)
  )
)

;; Perform swap via XYK pool based on token path
(define-private (xyk-swap
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    (swap-result (if (is-eq is-reversed false)
      (try! (contract-call? .xyk-core-v-1-2 swap-x-for-y pool token-in token-out amount u1))
      (try! (contract-call? .xyk-core-v-1-2 swap-y-for-x pool token-out token-in amount u1))))
  )
    (ok swap-result)
  )
)

;; Get quote for STX to stSTX swap via STX-stSTX pool
(define-private (quote-legacy-stx-to-ststx (amount uint))
  (let (
    (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
    (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy y-token lp-token amount)))
  )
    (ok quote-result)
  )
)

;; Get quote for stSTX to STX swap via STX-stSTX pool
(define-private (quote-legacy-ststx-to-stx (amount uint))
  (let (
    (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
    (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx y-token lp-token amount)))
  )
    (ok quote-result)
  )
)

;; Get quote for swap via STX-stSTX pool based on token path
(define-private (execute-legacy-quote
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
  )
  (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (quote-legacy-stx-to-ststx amount) (quote-legacy-ststx-to-stx amount)))

;; Perform STX to stSTX swap via STX-stSTX pool
(define-private (swap-legacy-stx-to-ststx (amount uint))
  (let (
    (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
    (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y y-token lp-token amount u1)))
  )
    (ok swap-result)
  )
)

;; Perform stSTX to STX swap via STX-stSTX pool
(define-private (swap-legacy-ststx-to-stx (amount uint))
  (let (
    (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
    (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x y-token lp-token amount u1)))
  )
    (ok swap-result)
  )
)

;; Perform swap via STX-stSTX pool based on token path
(define-private (execute-legacy-swap
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
  )
  (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    (swap-legacy-stx-to-ststx amount) (swap-legacy-ststx-to-stx amount)))

;; Get quote for swap via XYK pool then STX-stSTX pool
(define-private (quote-xyk-then-legacy
    (amount uint)
    (token-a <ft-trait>) (token-b <ft-trait>) (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>)
  )
  (let (
    (xyk-quote-result (unwrap-panic (xyk-quote amount token-a token-b xyk-pool)))
    (legacy-quote-result (unwrap-panic (execute-legacy-quote xyk-quote-result token-b token-c)))
  )
    (ok legacy-quote-result)
  )
)

;; Get quote for swap via STX-stSTX pool then XYK pool
(define-private (quote-legacy-then-xyk
    (amount uint)
    (token-a <ft-trait>) (token-b <ft-trait>) (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>)
  )
  (let (
    (legacy-quote-result (unwrap-panic (execute-legacy-quote amount token-a token-b)))
    (xyk-quote-result (unwrap-panic (xyk-quote legacy-quote-result token-b token-c xyk-pool)))
  )
    (ok xyk-quote-result)
  )
)

;; Perform swap via XYK pool then STX-stSTX pool
(define-private (swap-xyk-then-legacy
    (amount uint)
    (token-a <ft-trait>) (token-b <ft-trait>) (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>)
  )
  (let (
    (xyk-swap-result (unwrap-panic (xyk-swap amount token-a token-b xyk-pool)))
    (legacy-swap-result (unwrap-panic (execute-legacy-swap xyk-swap-result token-b token-c)))
  )
    (ok legacy-swap-result)
  )
)

;; Perform swap via STX-stSTX pool then XYK pool
(define-private (swap-legacy-then-xyk
    (amount uint)
    (token-a <ft-trait>) (token-b <ft-trait>) (token-c <ft-trait>)
    (xyk-pool <xyk-pool-trait>)
  )
  (let (
    (legacy-swap-result (unwrap-panic (execute-legacy-swap amount token-a token-b)))
    (xyk-swap-result (unwrap-panic (xyk-swap legacy-swap-result token-b token-c xyk-pool)))
  )
    (ok xyk-swap-result)
  )
)
```
