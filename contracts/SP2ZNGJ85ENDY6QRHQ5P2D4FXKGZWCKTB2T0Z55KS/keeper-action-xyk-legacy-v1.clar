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
(define-constant ERR_INVALID_TOKEN_LENGTH (err u10006))


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

    ;; Verify we have exactly 3 tokens
    (token-length (len unwrapped-token-list))
    (valid-length (asserts! (is-eq token-length u3) ERR_INVALID_TOKEN_LENGTH))

    ;; Get tokens and pool
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT)) ;; Should be STX
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount))

    ;; Get quotes based on path direction
    (result (if swaps-reversed
        ;; Legacy then XYK: token-a -> token-b -> token-c
        (let (
            (legacy-quote (unwrap-panic (execute-legacy-quote amount-after-fee token-a token-b)))
            (xyk-quote (unwrap-panic (xyk-qa legacy-quote token-b token-c xyk-pool)))
        )
            xyk-quote)
        ;; XYK then Legacy: token-a -> token-b -> token-c
        (let (
            (xyk-quote (unwrap-panic (xyk-qa amount-after-fee token-a token-b xyk-pool)))
            (legacy-quote (unwrap-panic (execute-legacy-quote xyk-quote token-b token-c)))
        )
            legacy-quote)
    ))
  )
    (ok result)
  )
)

;; Helper functions for legacy pool quotes
(define-public (quote-legacy-stx-to-ststx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy y-token lp-token amount))))
        (ok quote-result)))

(define-public (quote-legacy-ststx-to-stx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (quote-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx y-token lp-token amount))))
        (ok quote-result)))

(define-public (execute-legacy-quote (amount uint) (token-in <ft-trait>) (token-out <ft-trait>))
    ;; Determine direction based on tokens
    (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (quote-legacy-stx-to-ststx amount)
        (quote-legacy-ststx-to-stx amount))
)

;; Check if input and output tokens are swapped relative to the pool's x and y tokens
(define-private (is-xyk-path-reversed
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
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

;; Get XYK quote using get-dy or get-dx based on token path
(define-public (xyk-qa
    (amount uint)
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
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

    ;; Verify we have exactly 3 tokens
    (token-length (len unwrapped-token-list))
    (valid-length (asserts! (is-eq token-length u3) ERR_INVALID_TOKEN_LENGTH))

    ;; Get tokens and pool
    (token-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))
    (token-b (unwrap! (element-at? unwrapped-token-list u1) ERR_INVALID_LIST_ELEMENT)) ;; Should be STX
    (token-c (unwrap! (element-at? unwrapped-token-list u2) ERR_INVALID_LIST_ELEMENT))
    (xyk-pool (unwrap! (element-at? unwrapped-xyk-pool-list u0) ERR_INVALID_LIST_ELEMENT))
    
    (swaps-reversed (unwrap! (element-at? unwrapped-bool-list u0) ERR_INVALID_LIST_ELEMENT))

    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee if applicable
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? token-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))

    ;; Execute swaps based on path direction
    (result (if swaps-reversed
        ;; Legacy then XYK: token-a -> token-b -> token-c
        (let (
            (legacy-swap (unwrap-panic (execute-legacy-swap amount-after-fee token-a token-b)))
            (xyk-swap (unwrap-panic (xyk-sa legacy-swap token-b token-c xyk-pool)))
        )
            xyk-swap)
        ;; XYK then Legacy: token-a -> token-b -> token-c
        (let (
            (xyk-swap (unwrap-panic (xyk-sa amount-after-fee token-a token-b xyk-pool)))
            (legacy-swap (unwrap-panic (execute-legacy-swap xyk-swap token-b token-c)))
        )
            legacy-swap)
    ))
  )
    (begin
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

        (ok result)
    )
  )
)

;; Helper functions for legacy pool swaps
(define-public (swap-legacy-stx-to-ststx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y y-token lp-token amount u1))))
        (ok swap-result)))

(define-public (swap-legacy-ststx-to-stx (amount uint))
    (let (
        (y-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (lp-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
        (swap-result (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x y-token lp-token amount u1))))
        (ok swap-result)))

(define-public (execute-legacy-swap (amount uint) (token-in <ft-trait>) (token-out <ft-trait>))
    ;; Determine direction based on tokens
    (if (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
        (swap-legacy-stx-to-ststx amount)
        (swap-legacy-ststx-to-stx amount))
)

;; Execute XYK swap using swap-x-for-y or swap-y-for-x based on token path
(define-public (xyk-sa
    (amount uint)
    (token-in <ft-trait>) 
    (token-out <ft-trait>)
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
  (ok u0)
) 