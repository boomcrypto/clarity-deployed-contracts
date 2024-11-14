---
title: "Trait keeper-2-helper-v-1-1"
draft: true
---
```
;; keeper-2-helper-v-1-1

;; Use all required traits
(use-trait xyk-ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait pontis-bridge-ft-trait 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.bridge-ft-trait.bridge-ft-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u10001))
(define-constant ERR_INVALID_AMOUNT (err u10002))
(define-constant ERR_ALREADY_ADMIN (err u10003))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u10004))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u10005))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u10006))
(define-constant ERR_KEEPER_STATUS (err u10007))
(define-constant ERR_INVALID_FEE (err u10008))
(define-constant ERR_INSUFFICIENT_PSBTC_AVAILABLE (err u10009))
(define-constant ERR_NO_PONTIS_FEE_DATA (err u10010))
(define-constant ERR_NO_POOL_DATA (err u10011))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Maximum BPS
(define-constant BPS u10000)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; Data var used to enable or disable this keeper type
(define-data-var keeper-status bool true)

;; Percent fee taken by this keeper type
(define-data-var keeper-fee uint u0)

;; Buffer fee to cover rounding errors
(define-data-var buffer-fee uint u4)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get keeper status
(define-read-only (get-keeper-status)
  (ok (var-get keeper-status))
)

;; Get keeper fee
(define-read-only (get-keeper-fee)
  (ok (var-get keeper-fee))
)

;; Get buffer fee
(define-read-only (get-buffer-fee)
  (ok (var-get buffer-fee))
)

;; Get keeper fee for a given amount
(define-read-only (get-keeper-fee-amount (amount uint))
  (ok (/ (* amount (var-get keeper-fee)) BPS))
)

;; Get the amount of psBTC to swap for STX to cover Pontis bridge STX fee
(define-read-only (get-psbtc-swap-amount)
  (let (
    ;; Get STX fee required by Pontis and gather all pool data
    (pontis-stx-fee (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager get-runes-base-fee 0x425443) ERR_NO_PONTIS_FEE_DATA))
    (pool-data (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1 get-pool) ERR_NO_POOL_DATA))
    (psbtc-balance (get x-balance pool-data))
    (stx-balance (get y-balance pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))

    ;; Calculate all fee amounts and total STX amount
    (protocol-fee-amount (/ (* pontis-stx-fee protocol-fee) BPS))
    (provider-fee-amount (/ (* pontis-stx-fee provider-fee) BPS))
    (buffer-fee-amount (/ (* pontis-stx-fee (var-get buffer-fee)) BPS))
    (total-fee-amount (+ protocol-fee-amount provider-fee-amount buffer-fee-amount))
    (total-stx-amount (+ pontis-stx-fee total-fee-amount))    

    ;; Calculate amount of psBTC needed for the swap
    (psbtc-swap-amount (/ (* psbtc-balance total-stx-amount) (- stx-balance total-stx-amount)))
  )
    ;; Return amount of psBTC to swap
    (ok psbtc-swap-amount)
  )
)

;; Get output for execute-action-a function
(define-public (get-action-a
    (amount uint)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    ;; Assert keeper type is enabled
    (keeper-check (asserts! (var-get keeper-status) ERR_KEEPER_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (get-keeper-fee-amount amount) ERR_INVALID_FEE))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Get quote for first rune token to psBTC swap via XYK Core
    (quote-rune-to-psbtc (try! (xyk-quote amount-after-keeper-fee (get a xyk-tokens) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get a xyk-pools))))

    ;; Get the amount of psBTC to swap for STX to cover Pontis bridge STX fee
    (psbtc-swap-amount (try! (get-psbtc-swap-amount)))

    ;; Assert sufficient psBTC is available for the psBTC to STX swap
    (psbtc-quote-amount-check (asserts! (> quote-rune-to-psbtc psbtc-swap-amount) ERR_INSUFFICIENT_PSBTC_AVAILABLE))

    ;; Get quote for psBTC to STX swap via XYK Core to cover Pontis bridge STX fee
    (quote-psbtc-to-stx (try! (xyk-quote
                              psbtc-swap-amount
                              'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1)))

    ;; Get quote for psBTC to second rune token swap via XYK Core
    (quote-psbtc-to-rune (try! (xyk-quote (- quote-rune-to-psbtc psbtc-swap-amount) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get b xyk-tokens) (get b xyk-pools))))

    ;; Calculate percent fee required by Pontis based on amount
    (pontis-ft-fee (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager calculate-runes-percent-fee quote-psbtc-to-rune))

    ;; Calculate amount bridged out after subtracting the percent fee
    (amount-after-pontis-ft-fee (- quote-psbtc-to-rune pontis-ft-fee))
  )
    ;; Return action data
    (ok {
      amount: amount,
      keeper-fee-amount: keeper-fee-amount,
      quote-rune-to-psbtc: quote-rune-to-psbtc,
      psbtc-swap-amount: psbtc-swap-amount,
      quote-psbtc-to-stx: quote-psbtc-to-stx,
      quote-psbtc-to-rune: quote-psbtc-to-rune,
      pontis-ft-fee: pontis-ft-fee,
      amount-after-pontis-ft-fee: amount-after-pontis-ft-fee
    })
  )
)

;; Add an admin to the admins list
(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and new admin is not in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)

      ;; Add admin to list with max length of 5
      (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))

      ;; Print add admin data and return true
      (print {action: "add-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and admin to remove is in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)

      ;; Assert contract deployer cannot be removed
      (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)

      ;; Set admin-helper to admin to remove and filter admins-list to remove admin
      (var-set admin-helper admin)
      (var-set admins (filter admin-not-removable admins-list))

      ;; Print remove admin data and return true
      (print {action: "remove-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Enable or disable this keeper type
(define-public (set-keeper-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set keeper-status to status
      (var-set keeper-status status)

      ;; Print function data and return true
      (print {action: "set-keeper-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Set percent fee taken by this keeper type
(define-public (set-keeper-fee (fee uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee is less than maximum BPS
      (asserts! (< fee BPS) ERR_INVALID_FEE)

      ;; Set keeper-fee to fee
      (var-set keeper-fee fee)

      ;; Print function data and return true
      (print {action: "set-keeper-fee", caller: caller, data: {fee: fee}})
      (ok true)
    )
  )
)

;; Set buffer fee used to cover rounding errors
(define-public (set-buffer-fee (fee uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee is less than maximum BPS
      (asserts! (< fee BPS) ERR_INVALID_FEE)

      ;; Set buffer-fee to fee
      (var-set buffer-fee fee)

      ;; Print function data and return true
      (print {action: "set-buffer-fee", caller: caller, data: {fee: fee}})
      (ok true)
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Check if token path for swap via XYK Core is reversed relative to the pool's tokens
(define-private (is-xyk-path-reversed
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
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

;; Get swap quote via XYK Core using appropriate function based on token path
(define-private (xyk-quote
    (amount uint)
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool-contract))

    ;; Get quote based on path direction
    (quote-result (if (is-eq is-reversed false)
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                            pool-contract
                            token-in token-out
                            amount))
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx
                            pool-contract
                            token-out token-in
                            amount))))
  )
    (ok quote-result)
  )
)
```
