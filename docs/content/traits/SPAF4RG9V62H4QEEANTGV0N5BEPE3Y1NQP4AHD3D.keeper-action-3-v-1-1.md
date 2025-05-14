---
title: "Trait keeper-action-3-v-1-1"
draft: true
---
```
;; keeper-action-3-v-1-1

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
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Get quote for swap and get final quote result
    (quote-a (if (is-eq (len unwrapped-token-list) u2) (try! (swap-sa amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list false)) u0))
    (quote-b (if (is-eq (len unwrapped-token-list) u4) (try! (swap-sb amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list false)) u0))
    (quote-c (if (is-eq (len unwrapped-token-list) u6) (try! (swap-sc amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list false)) u0))
    (quote-d (if (is-eq (len unwrapped-token-list) u8) (try! (swap-sd amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list false)) u0))
    (quote-e (if (is-eq (len unwrapped-token-list) u10) (try! (swap-se amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list false)) u0))
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

  )
    (ok u0)
  )
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
    (unwrapped-stableswap-pool-list (unwrap! stableswap-pool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get token a trait
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? token-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Perform swap and get final swap result
    (swap-a (if (is-eq (len unwrapped-token-list) u2) (try! (swap-sa amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list true)) u0))
    (swap-b (if (is-eq (len unwrapped-token-list) u4) (try! (swap-sb amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list true)) u0))
    (swap-c (if (is-eq (len unwrapped-token-list) u6) (try! (swap-sc amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list true)) u0))
    (swap-d (if (is-eq (len unwrapped-token-list) u8) (try! (swap-sd amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list true)) u0))
    (swap-e (if (is-eq (len unwrapped-token-list) u10) (try! (swap-se amount-after-keeper-fee owner-address unwrapped-token-list unwrapped-stableswap-pool-list true)) u0))
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
          swap-result: swap-result
        }
      })
      (ok swap-result)
    )
  )
)

;; Swap or get quote using 1 Stableswap pool
(define-private (swap-sa
  (amount uint) (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (pools (list 26 <stableswap-pool-trait>))
  (is-swap bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? pools u0) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and Stableswap pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b})
    (stableswap-pools-tuple {a: stableswap-pool-trait-a})

    ;; Perform swap or get quote result
    (swap-a (if is-swap
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-a amount u0 tokens-tuple stableswap-pools-tuple))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-a amount tokens-tuple stableswap-pools-tuple))
    ))
  )
    ;; Transfer swap-a b tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-b transfer swap-a tx-sender owner-address none)) false)

    ;; Return swap-a
    (ok swap-a)
  )
)

;; Swap or get quote using 2 Stableswap pools
(define-private (swap-sb
  (amount uint) (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (pools (list 26 <stableswap-pool-trait>))
  (is-swap bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? pools u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-b (unwrap! (element-at? pools u1) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and Stableswap pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d})
    (stableswap-pools-tuple {a: stableswap-pool-trait-a, b: stableswap-pool-trait-b})

    ;; Perform swap or get quote result
    (swap-a (if is-swap
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-b amount u0 tokens-tuple stableswap-pools-tuple))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-b amount tokens-tuple stableswap-pools-tuple))
    ))
  )
    ;; Transfer swap-a d tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-d transfer swap-a tx-sender owner-address none)) false)

    ;; Return swap-a
    (ok swap-a)
  )
)

;; Swap or get quote using 3 Stableswap pools
(define-private (swap-sc
  (amount uint) (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (pools (list 26 <stableswap-pool-trait>))
  (is-swap bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? pools u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-b (unwrap! (element-at? pools u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-c (unwrap! (element-at? pools u2) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and Stableswap pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f})
    (stableswap-pools-tuple {a: stableswap-pool-trait-a, b: stableswap-pool-trait-b, c: stableswap-pool-trait-c})

    ;; Perform swap or get quote result
    (swap-a (if is-swap
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-c amount u0 tokens-tuple stableswap-pools-tuple))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-c amount tokens-tuple stableswap-pools-tuple))
    ))
  )
    ;; Transfer swap-a f tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-f transfer swap-a tx-sender owner-address none)) false)

    ;; Return swap-a
    (ok swap-a)
  )
)

;; Swap or get quote using 4 Stableswap pools
(define-private (swap-sd
  (amount uint) (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (pools (list 26 <stableswap-pool-trait>))
  (is-swap bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
    (token-trait-a (unwrap! (element-at? tokens u0) ERR_INVALID_LIST_ELEMENT))
    (token-trait-b (unwrap! (element-at? tokens u1) ERR_INVALID_LIST_ELEMENT))
    (token-trait-c (unwrap! (element-at? tokens u2) ERR_INVALID_LIST_ELEMENT))
    (token-trait-d (unwrap! (element-at? tokens u3) ERR_INVALID_LIST_ELEMENT))
    (token-trait-e (unwrap! (element-at? tokens u4) ERR_INVALID_LIST_ELEMENT))
    (token-trait-f (unwrap! (element-at? tokens u5) ERR_INVALID_LIST_ELEMENT))
    (token-trait-g (unwrap! (element-at? tokens u6) ERR_INVALID_LIST_ELEMENT))
    (token-trait-h (unwrap! (element-at? tokens u7) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-a (unwrap! (element-at? pools u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-b (unwrap! (element-at? pools u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-c (unwrap! (element-at? pools u2) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-d (unwrap! (element-at? pools u3) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and Stableswap pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f, g: token-trait-g, h: token-trait-h})
    (stableswap-pools-tuple {a: stableswap-pool-trait-a, b: stableswap-pool-trait-b, c: stableswap-pool-trait-c, d: stableswap-pool-trait-d})

    ;; Perform swap or get quote result
    (swap-a (if is-swap
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-d amount u0 tokens-tuple stableswap-pools-tuple))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-d amount tokens-tuple stableswap-pools-tuple))
    ))
  )
    ;; Transfer swap-a h tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-h transfer swap-a tx-sender owner-address none)) false)

    ;; Return swap-a
    (ok swap-a)
  )
)

;; Swap or get quote using 5 Stableswap pools
(define-private (swap-se
  (amount uint) (owner-address principal)
  (tokens (list 26 <ft-trait>))
  (pools (list 26 <stableswap-pool-trait>))
  (is-swap bool)
)
  (let (
    ;; Get tokens and Stableswap pool traits
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
    (stableswap-pool-trait-a (unwrap! (element-at? pools u0) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-b (unwrap! (element-at? pools u1) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-c (unwrap! (element-at? pools u2) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-d (unwrap! (element-at? pools u3) ERR_INVALID_LIST_ELEMENT))
    (stableswap-pool-trait-e (unwrap! (element-at? pools u4) ERR_INVALID_LIST_ELEMENT))

    ;; Create tuples for tokens and Stableswap pool traits
    (tokens-tuple {a: token-trait-a, b: token-trait-b, c: token-trait-c, d: token-trait-d, e: token-trait-e, f: token-trait-f, g: token-trait-g, h: token-trait-h, i: token-trait-i, j: token-trait-j})
    (stableswap-pools-tuple {a: stableswap-pool-trait-a, b: stableswap-pool-trait-b, c: stableswap-pool-trait-c, d: stableswap-pool-trait-d, e: stableswap-pool-trait-e})

    ;; Perform swap or get quote result
    (swap-a (if is-swap
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-e amount u0 tokens-tuple stableswap-pools-tuple))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-e amount tokens-tuple stableswap-pools-tuple))
    ))
  )
    ;; Transfer swap-a j tokens from the contract to owner-address if is-swap is true
    (if is-swap (try! (contract-call? token-trait-j transfer swap-a tx-sender owner-address none)) false)

    ;; Return swap-a
    (ok swap-a)
  )
)
```
