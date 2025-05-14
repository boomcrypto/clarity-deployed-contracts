---
title: "Trait keeper-action-2-v-1-2"
draft: true
---
```
;; keeper-action-2-v-1-2

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
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get swaps reversed (false = XYK -> Stableswap)
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Get quote for swap and get final quote result
    (quote-a (if (is-eq (len unwrapped-token-list) u4) (try! (swap-sa amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed false)) u0))
    (quote-b (if (is-eq (len unwrapped-token-list) u6) (try! (swap-sb amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed false)) u0))
    (quote-c (if (is-eq (len unwrapped-token-list) u8) (try! (swap-sc amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed false)) u0))
    (quote-d (if (is-eq (len unwrapped-token-list) u10) (try! (swap-sd amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed false)) u0))
    (quote-e (if (is-eq (len unwrapped-token-list) u12) (try! (swap-se amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed false)) u0))
    (quote-result (+ quote-a quote-b quote-c quote-d quote-e))
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

  )
    (ok u0)
  )
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
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get token a trait
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get swaps reversed (false = XYK -> Stableswap)
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (as-contract (contract-call? token-trait-a transfer keeper-fee-amount tx-sender fee-recipient none)))
      false
    ))

    ;; Perform swap and get final swap result
    (swap-a (if (is-eq (len unwrapped-token-list) u4) (try! (swap-sa amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed true)) u0))
    (swap-b (if (is-eq (len unwrapped-token-list) u6) (try! (swap-sb amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed true)) u0))
    (swap-c (if (is-eq (len unwrapped-token-list) u8) (try! (swap-sc amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed true)) u0))
    (swap-d (if (is-eq (len unwrapped-token-list) u10) (try! (swap-sd amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed true)) u0))
    (swap-e (if (is-eq (len unwrapped-token-list) u12) (try! (swap-se amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-xyk-pool-list unwrapped-stableswap-pool-list swaps-reversed true)) u0))
    (swap-result (+ swap-a swap-b swap-c swap-d swap-e))
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

;; Swap or get quote using 1 XYK pool and 1 Stableswap pool
(define-private (swap-sa
  (amount uint) (owner-address principal)
  (tokens (list 12 <ft-trait>))
  (xyk-pools (list 12 <xyk-pool-trait>))
  (stableswap-pools (list 12 <stableswap-pool-trait>))
  (swaps-reversed bool) (is-swap bool)
)
  (let (
    ;; Get tokens, XYK pool traits, and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple-a {a: token-trait-a, b: token-trait-b})
    (tokens-tuple-b {a: token-trait-c, b: token-trait-d})
    (xyk-pools-tuple {a: xyk-pool-trait-a})

    ;; Perform swaps or get quote result
    (swap-a (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a amount u0 tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-sa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a amount tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-qa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
    ))
    (swap-b (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (stableswap-sa swap-a token-trait-c token-trait-d stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 tokens-tuple-b xyk-pools-tuple))
      )
      (if (is-eq swaps-reversed false)
        (try! (stableswap-qa swap-a token-trait-c token-trait-d stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a swap-a tokens-tuple-b xyk-pools-tuple))
      )
    ))
  )
    ;; Transfer swap-b d tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-d transfer swap-b tx-sender owner-address none)) false)

    ;; Return swap-b
    (ok swap-b)
  )
)

;; Swap or get quote using 2 XYK pools and 1 Stableswap pool
(define-private (swap-sb
  (amount uint) (owner-address principal)
  (tokens (list 12 <ft-trait>))
  (xyk-pools (list 12 <xyk-pool-trait>))
  (stableswap-pools (list 12 <stableswap-pool-trait>))
  (swaps-reversed bool) (is-swap bool)
)
  (let (
    ;; Get tokens, XYK pool traits, and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? xyk-pools u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple-a {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d})
    (tokens-tuple-b {a: token-trait-c, b: token-trait-d, c: token-trait-e, d: token-trait-f})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b})

    ;; Perform swaps or get quote result
    (swap-a (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b amount u0 tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-sa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b amount tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-qa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
    ))
    (swap-b (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (stableswap-sa swap-a token-trait-e token-trait-f stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 tokens-tuple-b xyk-pools-tuple))
      )
      (if (is-eq swaps-reversed false)
        (try! (stableswap-qa swap-a token-trait-e token-trait-f stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b swap-a tokens-tuple-b xyk-pools-tuple))
      )
    ))
  )
    ;; Transfer swap-b f tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-f transfer swap-b tx-sender owner-address none)) false)

    ;; Return swap-b
    (ok swap-b)
  )
)

;; Swap or get quote using 3 XYK pools and 1 Stableswap pool
(define-private (swap-sc
  (amount uint) (owner-address principal)
  (tokens (list 12 <ft-trait>))
  (xyk-pools (list 12 <xyk-pool-trait>))
  (stableswap-pools (list 12 <stableswap-pool-trait>))
  (swaps-reversed bool) (is-swap bool)
)
  (let (
    ;; Get tokens, XYK pool traits, and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (token-trait-g (unwrap! (element-at? tokens u6) ERR_INVALID_LIST_ELEMENT))
    (token-trait-h (unwrap! (element-at? tokens u7) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? xyk-pools u1) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-c (unwrap! (element-at? xyk-pools u2) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple-a {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f})
    (tokens-tuple-b {a: token-trait-c, b: token-trait-d, c: token-trait-e, d: token-trait-f, e: token-trait-g, f: token-trait-h})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b, c: xyk-pool-trait-c})

    ;; Perform swaps or get quote result
    (swap-a (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c amount u0 tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-sa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c amount tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-qa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
    ))
    (swap-b (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (stableswap-sa swap-a token-trait-g token-trait-h stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 tokens-tuple-b xyk-pools-tuple))
      )
      (if (is-eq swaps-reversed false)
        (try! (stableswap-qa swap-a token-trait-g token-trait-h stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c swap-a tokens-tuple-b xyk-pools-tuple))
      )
    ))
  )
    ;; Transfer swap-b h tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-h transfer swap-b tx-sender owner-address none)) false)

    ;; Return swap-b
    (ok swap-b)
  )
)

;; Swap or get quote using 4 XYK pools and 1 Stableswap pool
(define-private (swap-sd
  (amount uint) (owner-address principal)
  (tokens (list 12 <ft-trait>))
  (xyk-pools (list 12 <xyk-pool-trait>))
  (stableswap-pools (list 12 <stableswap-pool-trait>))
  (swaps-reversed bool) (is-swap bool)
)
  (let (
    ;; Get tokens, XYK pool traits, and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (token-trait-g (unwrap! (element-at? tokens u6) ERR_INVALID_LIST_ELEMENT))
    (token-trait-h (unwrap! (element-at? tokens u7) ERR_INVALID_LIST_ELEMENT))
    (token-trait-i (unwrap! (element-at? tokens u8) ERR_INVALID_LIST_ELEMENT))
    (token-trait-j (unwrap! (element-at? tokens u9) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? xyk-pools u1) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-c (unwrap! (element-at? xyk-pools u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-d (unwrap! (element-at? xyk-pools u3) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple-a {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f, g: token-trait-g, h: token-trait-h})
    (tokens-tuple-b {a: token-trait-c, b: token-trait-d, c: token-trait-e, d: token-trait-f, e: token-trait-g, f: token-trait-h, g: token-trait-i, h: token-trait-j})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b, c: xyk-pool-trait-c, d: xyk-pool-trait-d})

    ;; Perform swaps or get quote result
    (swap-a (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-d amount u0 tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-sa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-d amount tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-qa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
    ))
    (swap-b (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (stableswap-sa swap-a token-trait-i token-trait-j stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-d swap-a u0 tokens-tuple-b xyk-pools-tuple))
      )
      (if (is-eq swaps-reversed false)
        (try! (stableswap-qa swap-a token-trait-i token-trait-j stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-d swap-a tokens-tuple-b xyk-pools-tuple))
      )
    ))
  )
    ;; Transfer swap-b j tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-j transfer swap-b tx-sender owner-address none)) false)

    ;; Return swap-b
    (ok swap-b)
  )
)

;; Swap or get quote using 5 XYK pools and 1 Stableswap pool
(define-private (swap-se
  (amount uint) (owner-address principal)
  (tokens (list 12 <ft-trait>))
  (xyk-pools (list 12 <xyk-pool-trait>))
  (stableswap-pools (list 12 <stableswap-pool-trait>))
  (swaps-reversed bool) (is-swap bool)
)
  (let (
    ;; Get tokens, XYK pool traits, and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (token-trait-g (unwrap! (element-at? tokens u6) ERR_INVALID_LIST_ELEMENT))
    (token-trait-h (unwrap! (element-at? tokens u7) ERR_INVALID_LIST_ELEMENT))
    (token-trait-i (unwrap! (element-at? tokens u8) ERR_INVALID_LIST_ELEMENT))
    (token-trait-j (unwrap! (element-at? tokens u9) ERR_INVALID_LIST_ELEMENT))
    (token-trait-k (unwrap! (element-at? tokens u10) ERR_INVALID_LIST_ELEMENT))
    (token-trait-l (unwrap! (element-at? tokens u11) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-a (unwrap! (element-at? xyk-pools u0) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-b (unwrap! (element-at? xyk-pools u1) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-c (unwrap! (element-at? xyk-pools u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-d (unwrap! (element-at? xyk-pools u3) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool-trait-e (unwrap! (element-at? xyk-pools u4) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? stableswap-pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and XYK pool traits
    (tokens-tuple-a {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f, g: token-trait-g, h: token-trait-h, i: token-trait-i, j: token-trait-j})
    (tokens-tuple-b {a: token-trait-c, b: token-trait-d, c: token-trait-e, d: token-trait-f, e: token-trait-g, f: token-trait-h, g: token-trait-i, h: token-trait-j, i: token-trait-k, j: token-trait-l})
    (xyk-pools-tuple {a: xyk-pool-trait-a, b: xyk-pool-trait-b, c: xyk-pool-trait-c, d: xyk-pool-trait-d, e: xyk-pool-trait-e})

    ;; Perform swaps or get quote result
    (swap-a (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-e amount u0 tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-sa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
      (if (is-eq swaps-reversed false)
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-e amount tokens-tuple-a xyk-pools-tuple))
        (try! (stableswap-qa amount token-trait-a token-trait-b stableswap-pool-trait-a))
      )
    ))
    (swap-b (if is-swap
      (if (is-eq swaps-reversed false)
        (try! (stableswap-sa swap-a token-trait-k token-trait-l stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-e swap-a u0 tokens-tuple-b xyk-pools-tuple))
      )
      (if (is-eq swaps-reversed false)
        (try! (stableswap-qa swap-a token-trait-k token-trait-l stableswap-pool-trait-a))
        (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-e swap-a tokens-tuple-b xyk-pools-tuple))
      )
    ))
  )
    ;; Transfer swap-b l tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-l transfer swap-b tx-sender owner-address none)) false)

    ;; Return swap-b
    (ok swap-b)
  )
)

;; Check if input and output tokens are swapped relative to the pool's x and y tokens
(define-private (is-stableswap-path-reversed
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool-contract <stableswap-pool-trait>)
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

;; Get Stableswap quote using get-dy or get-dx based on token path
(define-private (stableswap-qa
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool <stableswap-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-stableswap-path-reversed token-in token-out pool))
    
    ;; Get quote based on path
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dy
                       pool
                       token-in token-out
                       amount))
                 (try! (contract-call?
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dx
                       pool
                       token-out token-in
                       amount))))
  )
    (ok quote-a)
  )
)

;; Perform Stableswap swap using swap-x-for-y or swap-y-for-x based on token path
(define-private (stableswap-sa
    (amount uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (pool <stableswap-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-stableswap-path-reversed token-in token-out pool))
    
    ;; Perform swap based on path
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-x-for-y
                      pool
                      token-in token-out
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-y-for-x
                      pool
                      token-out token-in
                      amount u1))))
  )
    (ok swap-a)
  )
)
```
