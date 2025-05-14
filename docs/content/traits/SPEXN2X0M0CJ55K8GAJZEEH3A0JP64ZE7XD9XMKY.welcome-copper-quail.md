---
title: "Trait welcome-copper-quail"
draft: true
---
```
;; bridge-stx-sbtc-pbtc-btc-v-1-1

;; Use all required traits
(use-trait pontis-bridge-ft-trait 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.bridge-ft-trait.bridge-ft-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u12001))
(define-constant ERR_INVALID_AMOUNT (err u12002))
(define-constant ERR_INVALID_PRINCIPAL (err u12003))
(define-constant ERR_MINIMUM_RECEIVED (err u12004))
(define-constant ERR_ALREADY_ADMIN (err u12005))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u12006))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u12007))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u12008))
(define-constant ERR_BRIDGE_STATUS (err u12009))
(define-constant ERR_INVALID_FEE (err u12010))
(define-constant ERR_AMOUNT_LESS_THAN_FEE (err u12011))
(define-constant ERR_INSUFFICIENT_STX_AVAILABLE (err u12012))
(define-constant ERR_NO_PONTIS_FEE_DATA (err u12013))
(define-constant ERR_NO_PONTIS_MINIMUM_DATA (err u12014))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Maximum BPS
(define-constant BPS u10000)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; Data var used to enable or disable this bridge type
(define-data-var bridge-status bool true)

;; Percent fee taken by this bridge type
(define-data-var bridge-fee uint u0)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get bridge status
(define-read-only (get-bridge-status)
  (ok (var-get bridge-status))
)

;; Get bridge fee
(define-read-only (get-bridge-fee)
  (ok (var-get bridge-fee))
)

;; Get bridge fee for a given amount
(define-read-only (get-bridge-fee-amount (amount uint))
  (ok (/ (* amount (var-get bridge-fee)) BPS))
)

;; Get output for bridge-helper-a function
(define-public (get-helper-a (amount uint))
  (let (
    ;; Assert bridge type is enabled
    (bridge-check (asserts! (var-get bridge-status) ERR_BRIDGE_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get bridge fee and calculate updated amount
    (bridge-fee-amount (unwrap! (get-bridge-fee-amount amount) ERR_INVALID_FEE))
    (amount-after-bridge-fee (- amount bridge-fee-amount))

    ;; Get STX fee required by Pontis bridge
    (pontis-stx-fee (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 get-btc-base-fee 0x425443) ERR_NO_PONTIS_FEE_DATA))

    ;; Assert sufficient STX is available to cover the Pontis bridge STX fee
    (stx-fee-amount-check (asserts! (> amount-after-bridge-fee pontis-stx-fee) ERR_INSUFFICIENT_STX_AVAILABLE))

    ;; Get quote for STX to sBTC swap via XYK Core
    (quote-stx-to-sbtc (try! (contract-call?
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
                             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                             (- amount-after-bridge-fee pontis-stx-fee))))

    ;; Get quote for sBTC to pBTC swap via Stableswap Core
    (quote-sbtc-to-pbtc (try! (contract-call?
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dy
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1
                              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                              'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC
                              quote-stx-to-sbtc)))

    ;; Calculate percent fee required by Pontis based on amount
    (pontis-ft-fee (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 calculate-btc-percent-fee quote-sbtc-to-pbtc))

    ;; Calculate amount bridged out after subtracting the percent fee
    (amount-after-pontis-ft-fee (- quote-sbtc-to-pbtc pontis-ft-fee))
  )
    ;; Return action data
    (ok {
      amount: amount,
      bridge-fee-amount: bridge-fee-amount,
      pontis-stx-fee: pontis-stx-fee,
      quote-stx-to-sbtc: quote-stx-to-sbtc,
      quote-sbtc-to-pbtc: quote-sbtc-to-pbtc,
      pontis-ft-fee: pontis-ft-fee,
      amount-after-pontis-ft-fee: amount-after-pontis-ft-fee
    })
  )
)

;; Get minimum amount of STX needed to use bridge-helper-a function
(define-public (get-min-a)
  (let (
    ;; Get minimum amount of pBTC required to bridge out using Pontis bridge
    (pontis-pbtc-bridge-minimum (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 get-min-btc-bridge) ERR_NO_PONTIS_MINIMUM_DATA))
    
    ;; Get quote for pBTC to sBTC swap via Stableswap Core
    (quote-pbtc-to-sbtc (try! (contract-call?
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dx
                              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1
                              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                              'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC
                              pontis-pbtc-bridge-minimum)))

    ;; Get quote for sBTC to STX swap via XYK Core
    (quote-sbtc-to-stx (try! (contract-call?
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
                             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                             quote-pbtc-to-sbtc)))

    ;; Get STX fee required by Pontis bridge
    (pontis-stx-fee (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 get-btc-base-fee 0x425443) ERR_NO_PONTIS_FEE_DATA))

    ;; Calculate minimum amount after adding the Pontis bridge STX fee
    (amount-with-pontis-stx-fee (+ quote-sbtc-to-stx pontis-stx-fee))
  )
    ;; Return action data
    (ok {
      pontis-pbtc-bridge-minimum: pontis-pbtc-bridge-minimum,
      quote-pbtc-to-sbtc: quote-pbtc-to-sbtc,
      quote-sbtc-to-stx: quote-sbtc-to-stx,
      pontis-stx-fee: pontis-stx-fee,
      amount-with-pontis-stx-fee: amount-with-pontis-stx-fee
    })
  )
)

;; Swap STX to sBTC, then sBTC to pBTC, and then bridge out pBTC to specified Bitcoin address
(define-public (bridge-helper-a
    (amount uint) (min-received uint) (fee-recipient principal)
    (btc-address (buff 64)) (pontis-btc-contract <pontis-bridge-ft-trait>)
  )
  (let (
    (caller tx-sender)

    ;; Assert bridge type is enabled
    (bridge-check (asserts! (var-get bridge-status) ERR_BRIDGE_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Assert fee-recipient is standard principal
    (fee-recipient-check (asserts! (is-standard fee-recipient) ERR_INVALID_PRINCIPAL))

    ;; Get bridge fee and calculate updated amount
    (bridge-fee-amount (unwrap! (get-bridge-fee-amount amount) ERR_INVALID_FEE))
    (amount-after-bridge-fee (- amount bridge-fee-amount))

    ;; Transfer bridge fee from the caller to fee-recipient
    (transfer-bridge-fee
      (if (> bridge-fee-amount u0)
        (try! (stx-transfer? bridge-fee-amount caller fee-recipient))
        false
      )
    )

    ;; Get STX fee required by Pontis bridge
    (pontis-stx-fee (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 get-btc-base-fee 0x425443) ERR_NO_PONTIS_FEE_DATA))

    ;; Assert sufficient STX is available to cover the Pontis bridge STX fee
    (stx-fee-amount-check (asserts! (> amount-after-bridge-fee pontis-stx-fee) ERR_INSUFFICIENT_STX_AVAILABLE))

    ;; Perform STX to sBTC swap via XYK Core
    (swap-stx-to-sbtc (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
                            'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                            (- amount-after-bridge-fee pontis-stx-fee) u1)))

    ;; Perform sBTC to pBTC swap via Stableswap Core
    (swap-sbtc-to-pbtc (try! (contract-call?
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-x-for-y
                             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1
                             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                             'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC
                             swap-stx-to-sbtc u1)))

    ;; Bridge out pBTC to Bitcoin using Pontis bridge
    (bridge-btc-out (try! (pontis-bridge-btc-out swap-sbtc-to-pbtc btc-address pontis-btc-contract)))
  )
    (begin
      ;; Assert bridge-btc-out is greater than or equal to min-received
      (asserts! (>= bridge-btc-out min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return true
      (print {
        action: "bridge-helper-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          fee-recipient: fee-recipient,
          bridge-fee-amount: bridge-fee-amount,
          pontis-stx-fee: pontis-stx-fee,
          swap-stx-to-sbtc: swap-stx-to-sbtc,
          swap-sbtc-to-pbtc: swap-sbtc-to-pbtc,
          bridge-btc-out: bridge-btc-out
        }
      })
      (ok true)
    )
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

;; Enable or disable this bridge type
(define-public (set-bridge-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set bridge-status to status
      (var-set bridge-status status)

      ;; Print function data and return true
      (print {action: "set-bridge-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Set percent fee taken by this bridge type
(define-public (set-bridge-fee (fee uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee is less than maximum BPS
      (asserts! (< fee BPS) ERR_INVALID_FEE)

      ;; Set bridge-fee to fee
      (var-set bridge-fee fee)

      ;; Print function data and return true
      (print {action: "set-bridge-fee", caller: caller, data: {fee: fee}})
      (ok true)
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Bridge out pBTC to Bitcoin using Pontis bridge
(define-private (pontis-bridge-btc-out
    (amount uint)
    (btc-address (buff 64)) (btc-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Calculate percent fee required by Pontis based on amount
    (pontis-ft-fee (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager-3 calculate-btc-percent-fee amount))
    
    ;; Assert amount is sufficient to cover the fee
    (amount-check (asserts! (> amount pontis-ft-fee) ERR_AMOUNT_LESS_THAN_FEE))
    
    ;; Bridge out pBTC to the specified Bitcoin address
    (bridge-out-result (try! (contract-call?
                             'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-v5 bridge-out-btc
                             btc-contract 
                             amount btc-address
                             0x425443)))
  )
    ;; Return amount bridged out after subtracting the fee
    (ok (- amount pontis-ft-fee))
  )
)
```
