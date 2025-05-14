;; keeper-action-9-v-1-1

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
    (unwrapped-xyk-staking-list (unwrap! xyk-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-staking-list (unwrap! stableswap-staking-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-uint-list (unwrap! uint-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get token a trait
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get transfer-to-owner
    (transfer-to-owner (default-to true (element-at? unwrapped-bool-list u0)))

    ;; Get early-unstake-lp-tokens if early unstaking
    (early-unstake-lp-tokens (default-to false (element-at? unwrapped-bool-list u1)))

    ;; Get number of cycles to stake
    (cycles-to-stake (unwrap! (element-at? unwrapped-uint-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Unstake or early unstake LP tokens for XYK or Stableswap pool
    (unstake-lp-result (if (is-eq (len unwrapped-xyk-staking-list) u1)
      (try! (xyk-unstake-lp owner-address unwrapped-token-list unwrapped-xyk-staking-list amount transfer-to-owner early-unstake-lp-tokens))
      (if (is-eq (len unwrapped-stableswap-staking-list) u1)
        (try! (stableswap-unstake-lp owner-address unwrapped-token-list unwrapped-stableswap-staking-list amount transfer-to-owner early-unstake-lp-tokens))
        {total-lp-unstaked: u0, lp-to-restake: u0, unstake-lp-result: u0, early-unstake-lp-result: {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}}
    )))
    (lp-to-restake (get lp-to-restake unstake-lp-result))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount lp-to-restake) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- lp-to-restake keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? token-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Stake LP tokens for XYK or Stableswap pool
    (stake-lp-result (if (is-eq (len unwrapped-xyk-staking-list) u1)
      (try! (xyk-stake-lp amount-after-keeper-fee unwrapped-xyk-staking-list cycles-to-stake))
      (if (is-eq (len unwrapped-stableswap-staking-list) u1) (try! (stableswap-stake-lp amount-after-keeper-fee unwrapped-stableswap-staking-list cycles-to-stake)) u0)
    ))
  )
    (begin
      ;; Print action data and return stake-lp-result
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          transfer-to-owner: transfer-to-owner,
          early-unstake-lp-tokens: early-unstake-lp-tokens,
          cycles-to-stake: cycles-to-stake,
          unstake-lp-result: unstake-lp-result,
          stake-lp-result: stake-lp-result
        }
      })
      (ok stake-lp-result)
    )
  )
)

;; Unstake or early unstake LP tokens for 1 XYK pool
(define-private (xyk-unstake-lp
  (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (xyk-staking-traits (list 26 <xyk-staking-trait>))
  (lp-to-transfer uint) (transfer-to-owner bool) (is-early-unstake bool)
)
  (let (
    ;; Get token and XYK staking traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-staking-trait-a (unwrap! (element-at? xyk-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Unstake LP tokens if is-early-unstake is false
    (unstake-lp-result (if (not is-early-unstake) (try! (contract-call? xyk-staking-trait-a unstake-lp-tokens)) u0))

    ;; Early unstake LP tokens if is-early-unstake is true
    (early-unstake-lp-result (if is-early-unstake (try! (contract-call? xyk-staking-trait-a early-unstake-lp-tokens)) {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}))

    ;; Calculate total LP tokens unstaked and amount to restake
    (total-lp-unstaked (+ unstake-lp-result (get early-lp-to-unstake-user early-unstake-lp-result) (get matured-lp-to-unstake-user early-unstake-lp-result)))
    (lp-to-restake (if transfer-to-owner (- total-lp-unstaked lp-to-transfer) total-lp-unstaked))
  )
    ;; Transfer lp-to-transfer LP tokens from the contract to owner-address if transfer-to-owner is true
    (if (and transfer-to-owner (> lp-to-transfer u0)) (try! (contract-call? token-trait-a transfer lp-to-transfer tx-sender owner-address none)) false)

    ;; Return relevant values
    (ok {
      total-lp-unstaked: total-lp-unstaked,
      lp-to-restake: lp-to-restake,
      unstake-lp-result: unstake-lp-result,
      early-unstake-lp-result: early-unstake-lp-result
    })
  )
)

;; Unstake or early unstake LP tokens for 1 Stableswap pool
(define-private (stableswap-unstake-lp
  (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (stableswap-staking-traits (list 26 <stableswap-staking-trait>))
  (lp-to-transfer uint) (transfer-to-owner bool) (is-early-unstake bool)
)
  (let (
    ;; Get token and Stableswap staking traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-staking-trait-a (unwrap! (element-at? stableswap-staking-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Unstake LP tokens if is-early-unstake is false
    (unstake-lp-result (if (not is-early-unstake) (try! (contract-call? stableswap-staking-trait-a unstake-lp-tokens)) u0))

    ;; Early unstake LP tokens if is-early-unstake is true
    (early-unstake-lp-result (if is-early-unstake (try! (contract-call? stableswap-staking-trait-a early-unstake-lp-tokens)) {early-lp-to-unstake-user: u0, matured-lp-to-unstake-user: u0}))

    ;; Calculate total LP tokens unstaked and amount to restake
    (total-lp-unstaked (+ unstake-lp-result (get early-lp-to-unstake-user early-unstake-lp-result) (get matured-lp-to-unstake-user early-unstake-lp-result)))
    (lp-to-restake (if transfer-to-owner (- total-lp-unstaked lp-to-transfer) total-lp-unstaked))
  )
    ;; Transfer lp-to-transfer LP tokens from the contract to owner-address if transfer-to-owner is true
    (if (and transfer-to-owner (> lp-to-transfer u0)) (try! (contract-call? token-trait-a transfer lp-to-transfer tx-sender owner-address none)) false)

    ;; Return relevant values
    (ok {
      total-lp-unstaked: total-lp-unstaked,
      lp-to-restake: lp-to-restake,
      unstake-lp-result: unstake-lp-result,
      early-unstake-lp-result: early-unstake-lp-result
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