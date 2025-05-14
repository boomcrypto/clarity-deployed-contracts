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
    (token-list (optional (list 12 <ft-trait>)))
    (xyk-pool-list (optional (list 12 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 12 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 12 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 12 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 12 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 12 <stableswap-emissions-trait>)))
    (uint-list (optional (list 12 uint)))
    (bool-list (optional (list 12 bool)))
    (principal-list (optional (list 12 principal)))
  )
  (let (
    ;; Unwrap required lists from parameters
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get tokens and XYK pool traits
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? unwrapped-token-list u3) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? unwrapped-xyk-pool-list u1) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b})

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Get quote for swap
    (quote-a (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b
                   amount-after-keeper-fee
                   tokens-tuple xyk-pools-tuple)))
  )
    ;; Return result
    (ok quote-a)
  )
)

;; Get minimum amount for execute-action function
(define-public (get-minimum
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 12 <ft-trait>)))
    (xyk-pool-list (optional (list 12 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 12 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 12 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 12 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 12 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 12 <stableswap-emissions-trait>)))
    (uint-list (optional (list 12 uint)))
    (bool-list (optional (list 12 bool)))
    (principal-list (optional (list 12 principal)))
  )
  (ok u0)
)

;; Perform execute-action function
(define-public (execute-action 
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 12 <ft-trait>)))
    (xyk-pool-list (optional (list 12 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 12 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 12 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 12 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 12 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 12 <stableswap-emissions-trait>)))
    (uint-list (optional (list 12 uint)))
    (bool-list (optional (list 12 bool)))
    (principal-list (optional (list 12 principal)))
  )
  (let (
    ;; Unwrap required lists from parameters
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-pool-list (unwrap! xyk-pool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get tokens and XYK pool traits
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? unwrapped-token-list u3) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? unwrapped-xyk-pool-list u1) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b})

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee
      (if (> keeper-fee-amount u0)
        (try! (as-contract (contract-call? token-trait-a transfer keeper-fee-amount tx-sender fee-recipient none)))
        false
      )
    )

    ;; Perform swap
    (swap-a (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b
                  amount-after-keeper-fee u0
                  tokens-tuple xyk-pools-tuple)))
  )
    (begin
      ;; Assert swap-a is greater than or equal to min-received
      (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)

      ;; Transfer swap-a d tokens from the contract to owner-address
      (try! (contract-call? token-trait-d transfer swap-a tx-sender owner-address none))

      ;; Print action data and return swap-a
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          swap-a: swap-a
        }
      })
      (ok swap-a)
    )
  )
)
```
