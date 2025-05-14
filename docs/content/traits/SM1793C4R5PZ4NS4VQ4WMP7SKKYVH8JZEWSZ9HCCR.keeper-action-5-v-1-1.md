---
title: "Trait keeper-action-5-v-1-1"
draft: true
---
```

;; keeper-action-5-v-1-1

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
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-uint-list (unwrap! uint-list ERR_INVALID_PARAMETER_LIST))

    ;; Get y-amount if adding to Stableswap pool
    (stableswap-y-amount (default-to u0 (element-at? unwrapped-uint-list u0)))

    ;; Get quote for adding liquidity to XYK or Stableswap pool
    (add-liquidity-result (if (is-eq (len unwrapped-xyk-pool-list) u1)
      (try! (xyk-add-liquidity amount owner-address fee-recipient unwrapped-token-list unwrapped-xyk-pool-list false false))
      (if (is-eq (len unwrapped-stableswap-pool-list) u1)
        (try! (stableswap-add-liquidity amount stableswap-y-amount owner-address fee-recipient unwrapped-token-list unwrapped-stableswap-pool-list false false))
        {keeper-fee-amount: u0, dlp-after-keeper-fee: u0}
    )))
    (dlp-after-keeper-fee (get dlp-after-keeper-fee add-liquidity-result))
  )
    ;; Return dlp-after-keeper-fee
    (ok dlp-after-keeper-fee)
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
    (unwrapped-xyk-staking-list (unwrap! xyk-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-staking-list (unwrap! stableswap-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-uint-list (unwrap! uint-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get y-amount if adding to Stableswap pool
    (stableswap-y-amount (default-to u0 (element-at? unwrapped-uint-list u0)))

    ;; Get number of cycles to stake if staking
    (cycles-to-stake (unwrap! (element-at? unwrapped-uint-list u1) ERR_INVALID_LIST_ELEMENT))

    ;; Get transfer-to-owner
    (transfer-to-owner (default-to true (element-at? unwrapped-bool-list u0)))

    ;; Get stake-lp-tokens if staking
    (stake-lp-tokens (default-to false (element-at? unwrapped-bool-list u1)))

    ;; Add liquidity to XYK or Stableswap pool
    (add-liquidity-result (if (is-eq (len unwrapped-xyk-pool-list) u1)
      (try! (xyk-add-liquidity amount owner-address fee-recipient unwrapped-token-list unwrapped-xyk-pool-list transfer-to-owner true))
      (if (is-eq (len unwrapped-stableswap-pool-list) u1)
        (try! (stableswap-add-liquidity amount stableswap-y-amount owner-address fee-recipient unwrapped-token-list unwrapped-stableswap-pool-list transfer-to-owner true))
        {keeper-fee-amount: u0, dlp-after-keeper-fee: u0}
    )))
    (keeper-fee-amount (get keeper-fee-amount add-liquidity-result))
    (dlp-after-keeper-fee (get dlp-after-keeper-fee add-liquidity-result))

    ;; Stake LP tokens if stake-lp-tokens is true
    (stake-lp-result (if stake-lp-tokens 
      (if (is-eq (len unwrapped-xyk-staking-list) u1)
        (try! (xyk-stake-lp dlp-after-keeper-fee unwrapped-xyk-staking-list cycles-to-stake))
        (if (is-eq (len unwrapped-stableswap-staking-list) u1) (try! (stableswap-stake-lp dlp-after-keeper-fee unwrapped-stableswap-staking-list cycles-to-stake)) u0)
      )
      u0
    ))
  )
    (begin
      ;; Assert dlp-after-keeper-fee is greater than or equal to min-received
      (asserts! (>= dlp-after-keeper-fee min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return dlp-after-keeper-fee
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          stableswap-y-amount: stableswap-y-amount,
          transfer-to-owner: transfer-to-owner,
          stake-lp-tokens: stake-lp-tokens,
          cycles-to-stake: cycles-to-stake,
          dlp-after-keeper-fee: dlp-after-keeper-fee,
          stake-lp-result: stake-lp-result
        }
      })
      (ok dlp-after-keeper-fee)
    )
  )
)

;; Add liquidity to 1 XYK pool or get quote
(define-private (xyk-add-liquidity
  (x-amount uint)
  (owner-address principal) (fee-recipient principal)
  (tokens (list 26 <ft-trait>))
  (xyk-pools (list 26 <xyk-pool-trait>))
  (transfer-to-owner bool) (is-executing bool)
)
  (let (
    ;; Get tokens and XYK pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Perform add-liquidity or get quote result
    (add-liquidity-result (if is-executing
      (try! (contract-call? .xyk-core-v-1-2 add-liquidity xyk-pool-trait-a token-trait-a token-trait-b x-amount u1))
      (get dlp (try! (contract-call? .xyk-core-v-1-2 get-dlp xyk-pool-trait-a token-trait-a token-trait-b x-amount)))
    ))

    ;; Get keeper fee and calculate updated dlp
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount add-liquidity-result) ERR_INVALID_HELPER_DATA))
    (dlp-after-keeper-fee (- add-liquidity-result keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? xyk-pool-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))
  )
    ;; Transfer dlp-after-keeper-fee LP tokens from the contract to owner-address if transfer-to-owner and is-executing are true
    (if (and transfer-to-owner is-executing) (try! (contract-call? xyk-pool-trait-a transfer dlp-after-keeper-fee tx-sender owner-address none)) false)

    ;; Return relevant values
    (ok {
      keeper-fee-amount: keeper-fee-amount,
      dlp-after-keeper-fee: dlp-after-keeper-fee
    })
  )
)

;; Add liquidity to 1 Stableswap pool or get quote
(define-private (stableswap-add-liquidity
  (x-amount uint) (y-amount uint)
  (owner-address principal) (fee-recipient principal)
  (tokens (list 26 <ft-trait>))
  (stableswap-pools (list 26 <stableswap-pool-trait>))
  (transfer-to-owner bool) (is-executing bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Perform add-liquidity or get quote result
    (add-liquidity-result (if is-executing
      (try! (contract-call? .stableswap-core-v-1-2 add-liquidity stableswap-pool-trait-a token-trait-a token-trait-b x-amount y-amount u1))
      (try! (contract-call? .stableswap-core-v-1-2 get-dlp stableswap-pool-trait-a token-trait-a token-trait-b x-amount y-amount))
    ))

    ;; Get keeper fee and calculate updated dlp
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount add-liquidity-result) ERR_INVALID_HELPER_DATA))
    (dlp-after-keeper-fee (- add-liquidity-result keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? stableswap-pool-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))
  )
    ;; Transfer dlp-after-keeper-fee LP tokens from the contract to owner-address if transfer-to-owner and is-executing are true
    (if (and transfer-to-owner is-executing) (try! (contract-call? stableswap-pool-trait-a transfer dlp-after-keeper-fee tx-sender owner-address none)) false)

    ;; Return relevant values
    (ok {
      keeper-fee-amount: keeper-fee-amount,
      dlp-after-keeper-fee: dlp-after-keeper-fee
    })
  )
)

;; Stake LP tokens for 1 XYK pool
(define-private (xyk-stake-lp
  (amount uint)
  (xyk-staking-traits (list 26 <xyk-staking-trait>))
  (cycles-to-stake uint)
)
  (let (
    ;; Get XYK staking trait
    (xyk-staking-trait-a (unwrap! (element-at? xyk-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Perform stake-lp-tokens
    (stake-lp-result (try! (contract-call? xyk-staking-trait-a stake-lp-tokens amount cycles-to-stake)))
  )
    ;; Return amount staked
    (ok amount)
  )
)

;; Stake LP tokens for 1 Stableswap pool
(define-private (stableswap-stake-lp
  (amount uint)
  (stableswap-staking-traits (list 26 <stableswap-staking-trait>))
  (cycles-to-stake uint)
)
  (let (
    ;; Get Stableswap staking trait
    (stableswap-staking-trait-a (unwrap! (element-at? stableswap-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Perform stake-lp-tokens
    (stake-lp-result (try! (contract-call? stableswap-staking-trait-a stake-lp-tokens amount cycles-to-stake)))
  )
    ;; Return amount staked
    (ok amount)
  )
)
```
