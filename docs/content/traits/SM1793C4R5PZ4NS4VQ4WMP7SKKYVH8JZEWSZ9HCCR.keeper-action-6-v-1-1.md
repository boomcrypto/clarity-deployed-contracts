---
title: "Trait keeper-action-6-v-1-1"
draft: true
---
```

;; keeper-action-6-v-1-1

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
  (ok u0)
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
    (unwrapped-xyk-staking-list (unwrap! xyk-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-staking-list (unwrap! stableswap-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-uint-list (unwrap! uint-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get min-y-amount if withdrawing from Stableswap pool
    (min-y-amount (default-to u0 (element-at? unwrapped-uint-list u0)))

    ;; Get transfer-to-owner
    (transfer-to-owner (default-to true (element-at? unwrapped-bool-list u0)))

    ;; Get unstake-lp-tokens if unstaking
    (unstake-lp-tokens (default-to false (element-at? unwrapped-bool-list u1)))
    
    ;; Get early-unstake-lp-tokens if early unstaking
    (early-unstake-lp-tokens (default-to false (element-at? unwrapped-bool-list u2)))

    ;; Unstake LP tokens for XYK or Stableswap pool if unstake-lp-tokens or early-unstake-lp-tokens is true
    (unstake-lp-result (if (or unstake-lp-tokens early-unstake-lp-tokens)
      (if (is-eq (len unwrapped-xyk-staking-list) u1)
        (try! (xyk-unstake-lp unwrapped-xyk-staking-list early-unstake-lp-tokens))
        (if (is-eq (len unwrapped-stableswap-staking-list) u1)
          (try! (stableswap-unstake-lp unwrapped-stableswap-staking-list early-unstake-lp-tokens))
          {unstake-lp-result: u0, early-unstake-lp-result: {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}}
        )
      )
      {unstake-lp-result: u0, early-unstake-lp-result: {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}}
    ))

    ;; Withdraw liquidity from XYK or Stableswap pool
    (withdraw-liquidity-result (if (is-eq (len unwrapped-xyk-pool-list) u1)
      (try! (xyk-withdraw-liquidity amount owner-address fee-recipient unwrapped-token-list unwrapped-xyk-pool-list transfer-to-owner))
      (if (is-eq (len unwrapped-stableswap-pool-list) u1)
        (try! (stableswap-withdraw-liquidity amount owner-address fee-recipient unwrapped-token-list unwrapped-stableswap-pool-list transfer-to-owner))
        {keeper-fee-amount: u0, x-amount: u0, y-amount: u0}
    )))
    (keeper-fee-amount (get keeper-fee-amount withdraw-liquidity-result))
    (x-amount (get x-amount withdraw-liquidity-result))
    (y-amount (get y-amount withdraw-liquidity-result))
  )
    (begin
      ;; Assert x-amount is greater than or equal to min-received
      (asserts! (>= x-amount min-received) ERR_MINIMUM_RECEIVED)

      ;; Assert y-amount is greater than or equal to min-y-amount
      (asserts! (>= y-amount min-y-amount) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return amount of LP tokens withdrawn
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          min-x-amount: min-received,
          min-y-amount: min-y-amount,
          transfer-to-owner: transfer-to-owner,
          unstake-lp-tokens: unstake-lp-tokens,
          early-unstake-lp-tokens: early-unstake-lp-tokens,
          unstake-lp-result: unstake-lp-result,
          x-amount: x-amount,
          y-amount: y-amount
        }
      })
      (ok amount)
    )
  )
)

;; Withdraw liquidity from 1 XYK pool
(define-private (xyk-withdraw-liquidity
  (amount uint)
  (owner-address principal) (fee-recipient principal)
  (tokens (list 26 <ft-trait>))
  (xyk-pools (list 26 <xyk-pool-trait>))
  (transfer-to-owner bool)
)
  (let (
    ;; Get tokens and XYK pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? xyk-pool-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Perform withdraw-liquidity
    (withdraw-liquidity-result (try! (contract-call? .xyk-core-v-1-2 withdraw-liquidity xyk-pool-trait-a token-trait-a token-trait-b amount-after-keeper-fee u1 u1)))
    (x-amount (get x-amount withdraw-liquidity-result))
    (y-amount (get y-amount withdraw-liquidity-result))
  )
    ;; Transfer withdraw-liquidity-result a and b tokens from the contract to owner-address if transfer-to-owner is true
    (if transfer-to-owner
      (and (if (> x-amount u0) (try! (contract-call? token-trait-a transfer x-amount tx-sender owner-address none)) false)
           (if (> y-amount u0) (try! (contract-call? token-trait-b transfer y-amount tx-sender owner-address none)) false))
    false)

    ;; Return relevant values
    (ok {
      keeper-fee-amount: keeper-fee-amount,
      x-amount: x-amount,
      y-amount: y-amount
    })
  )
)

;; Withdraw liquidity from 1 Stableswap pool
(define-private (stableswap-withdraw-liquidity
  (amount uint)
  (owner-address principal) (fee-recipient principal)
  (tokens (list 26 <ft-trait>))
  (stableswap-pools (list 26 <stableswap-pool-trait>))
  (transfer-to-owner bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? stableswap-pool-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Perform withdraw-liquidity
    (withdraw-liquidity-result (try! (contract-call? .stableswap-core-v-1-2 withdraw-liquidity stableswap-pool-trait-a token-trait-a token-trait-b amount-after-keeper-fee u1 u1)))
    (x-amount (get x-amount withdraw-liquidity-result))
    (y-amount (get y-amount withdraw-liquidity-result))
  )
    ;; Transfer withdraw-liquidity-result a and b tokens from the contract to owner-address if transfer-to-owner is true
    (if transfer-to-owner
      (and (if (> x-amount u0) (try! (contract-call? token-trait-a transfer x-amount tx-sender owner-address none)) false)
           (if (> y-amount u0) (try! (contract-call? token-trait-b transfer y-amount tx-sender owner-address none)) false))
    false)

    ;; Return relevant values
    (ok {
      keeper-fee-amount: keeper-fee-amount,
      x-amount: x-amount,
      y-amount: y-amount
    })
  )
)

;; Unstake LP tokens for 1 XYK pool
(define-private (xyk-unstake-lp
  (xyk-staking-traits (list 26 <xyk-staking-trait>))
  (is-early-unstake bool)
)
  (let (
    ;; Get XYK staking trait
    (xyk-staking-trait-a (unwrap! (element-at? xyk-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Unstake LP tokens if is-early-unstake is false
    (unstake-lp-result (if (not is-early-unstake) (try! (contract-call? xyk-staking-trait-a unstake-lp-tokens)) u0))

    ;; Early unstake LP tokens if is-early-unstake is true
    (early-unstake-lp-result (if is-early-unstake (try! (contract-call? xyk-staking-trait-a early-unstake-lp-tokens)) {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}))
  )
    ;; Return relevant values
    (ok {
      unstake-lp-result: unstake-lp-result,
      early-unstake-lp-result: early-unstake-lp-result
    })
  )
)

;; Unstake LP tokens for 1 Stableswap pool
(define-private (stableswap-unstake-lp
  (stableswap-staking-traits (list 26 <stableswap-staking-trait>))
  (is-early-unstake bool)
)
  (let (
    ;; Get Stableswap staking trait
    (stableswap-staking-trait-a (unwrap! (element-at? stableswap-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Unstake LP tokens if is-early-unstake is false
    (unstake-lp-result (if (not is-early-unstake) (try! (contract-call? stableswap-staking-trait-a unstake-lp-tokens)) u0))

    ;; Early unstake LP tokens if is-early-unstake is true
    (early-unstake-lp-result (if is-early-unstake (try! (contract-call? stableswap-staking-trait-a early-unstake-lp-tokens)) {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}))
  )
    ;; Return relevant values
    (ok {
      unstake-lp-result: unstake-lp-result,
      early-unstake-lp-result: early-unstake-lp-result
    })
  )
)
```
