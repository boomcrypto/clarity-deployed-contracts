;; keeper-2-fz02pwvz0-v-1-1

;; Use all required traits
(use-trait keeper-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait pontis-bridge-ft-trait 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.bridge-ft-trait.bridge-ft-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u9001))
(define-constant ERR_INVALID_AMOUNT (err u9002))
(define-constant ERR_INVALID_PRINCIPAL (err u9003))
(define-constant ERR_MINIMUM_RECEIVED (err u9004))
(define-constant ERR_CANNOT_GET_PSBTC_SWAP_AMOUNT (err u9005))
(define-constant ERR_CANNOT_GET_PSBTC_BALANCE (err u9006))
(define-constant ERR_INSUFFICIENT_PSBTC_BALANCE (err u9007))
(define-constant ERR_NO_PONTIS_FEE_DATA (err u9008))
(define-constant ERR_NO_POOL_DATA (err u9009))

;; Maximum BPS
(define-constant BPS u10000)

;; Buffer fee to cover rounding errors
(define-constant BUFFER_FEE u4)

;; Address of the owner authorized to interact with contract
(define-data-var owner-address principal 'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY)

;; Bitcoin address authorized to receive bridged rune tokens
(define-data-var runes-address (buff 64) 0x6263317033706a3279747a783739377a6833717233306833786432386c326e6c6a356479676e353478657a737733753674796b7165367273756177667933)

;; Address of the keeper authorized to interact with contract
(define-data-var keeper-address principal 'SP16BPKS1DN5AYQ5MDHFEYXTSP352QG6JS2E0N8YP)

;; Data var used to enable or disable keeper authorization
(define-data-var keeper-authorized bool true)

;; Get owner address
(define-read-only (get-owner-address)
  (ok (var-get owner-address))
)

;; Get runes address
(define-read-only (get-runes-address)
  (ok (var-get runes-address))
)

;; Get keeper address
(define-read-only (get-keeper-address)
  (ok (var-get keeper-address))
)

;; Get keeper authorization status
(define-read-only (get-keeper-authorized)
  (ok (var-get keeper-authorized))
)

;; Performs swaps and bridges out rune tokens
(define-public (keeper-action-a
    (amount uint) (min-received uint)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
    (pontis-rune (buff 26)) (pontis-rune-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Assert that tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert that amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Swap first rune token to psBTC
    (swap-rune-to-psbtc (try! (as-contract (xyk-swap amount (get a xyk-tokens) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get a xyk-pools)))))

    ;; Calculate amount of psBTC needed to swap for Pontis bridge STX fee
    (psbtc-swap-amount (unwrap! (get-psbtc-swap-amount) ERR_CANNOT_GET_PSBTC_SWAP_AMOUNT))

    ;; Get contract's psBTC balance and assert contract has sufficient amount for swap
    (psbtc-balance (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC get-balance (as-contract tx-sender)) ERR_CANNOT_GET_PSBTC_BALANCE))
    (psbtc-balance-check (asserts! (> psbtc-balance psbtc-swap-amount) ERR_INSUFFICIENT_PSBTC_BALANCE))

    ;; Swap psBTC to STX to cover Pontis bridge STX fee
    (swap-psbtc-to-stx (try! (as-contract (xyk-swap
                                          psbtc-swap-amount
                                          'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1))))

    ;; Swap remaining psBTC to second rune token
    (swap-psbtc-to-rune (try! (as-contract (xyk-swap (- psbtc-balance psbtc-swap-amount) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get b xyk-tokens) (get b xyk-pools)))))

    ;; Bridge out second rune token to Bitcoin using Pontis bridge
    (bridge-rune-out (try! (as-contract (pontis-bridge-rune-out swap-psbtc-to-rune pontis-rune pontis-rune-contract))))

    ;; Get contract's STX balance and transfer remaining STX to owner
    (stx-balance (stx-get-balance (as-contract tx-sender)))
    (transfer-remaining-stx (try! (as-contract (stx-transfer? stx-balance tx-sender (var-get owner-address)))))
    (caller tx-sender)
  )
    (begin
      ;; Assert that swap-psbtc-to-rune is greater than or equal to min-received
      (asserts! (>= swap-psbtc-to-rune min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return true
      (print {
        action: "keeper-action-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          swap-rune-to-psbtc: swap-rune-to-psbtc,
          psbtc-swap-amount: psbtc-swap-amount,
          swap-psbtc-to-stx: swap-psbtc-to-stx,
          swap-psbtc-to-rune: swap-psbtc-to-rune,
          transfer-remaining-stx: transfer-remaining-stx
      }})
      (ok true)
    )
  )
)

;; Withdraw tokens from the keeper contract
(define-public (withdraw-tokens (token-trait <keeper-ft-trait>) (amount uint) (recipient principal))
  (let (
    (token-contract (contract-of token-trait))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that addresses are standard principals
      (asserts! (is-standard token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)

      ;; Transfer tokens from the contract to the recipient
      (try! (as-contract (contract-call? token-trait transfer amount tx-sender recipient none)))

      ;; Print withdraw data and return true
      (print {
        action: "withdraw-tokens",
        caller: caller,
        data: {
          token-contract: token-contract,
          amount: amount,
          recipient: recipient
        }
      })
      (ok true)
    )
  )
)

;; Set owner address authorized to interact with contract
(define-public (set-owner-address (address principal))
  (let (
    (caller tx-sender)
  )
    ;; Assert caller is owner
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

    ;; Assert that address is standard principal
    (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

    ;; Set owner-address to address
    (var-set owner-address address)

    ;; Print function data and return true
    (print {action: "set-owner-address", caller: caller, data: {address: address}})
    (ok true)
  )
)

;; Set runes address authorized to receive bridged rune tokens
(define-public (set-runes-address (address (buff 64)))
  (let (
    (caller tx-sender)
  )
    ;; Assert caller is owner
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

    ;; Set runes-address to address
    (var-set runes-address address)

    ;; Print function data and return true
    (print {action: "set-runes-address", caller: caller, data: {address: address}})
    (ok true)
  )
)

;; Set keeper address authorized to interact with contract
(define-public (set-keeper-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner or keeper
      (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED)

      ;; Assert that address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

      ;; Set keeper-address to address
      (var-set keeper-address address)

      ;; Print function data and return true
      (print {action: "set-keeper-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

;; Enable or disable keeper authorization
(define-public (set-keeper-authorized (authorized bool))
  (let (
    (caller tx-sender)
  )
    ;; Assert caller is owner
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

    ;; Update keeper authorization status
    (var-set keeper-authorized authorized)

    ;; Print function data and return true
    (print {action: "set-keeper-authorized", caller: caller, data: {authorized: authorized}})
    (ok true)
  )
)

;; Check if tx-sender is owner or keeper and if keeper is authorized
(define-private (is-owner-or-keeper)
  (or
    (is-eq tx-sender (var-get owner-address))
    (and (is-eq tx-sender (var-get keeper-address)) (var-get keeper-authorized))
  )
)

;; Check if token path is reversed relative to the pool's x and y tokens
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

;; Perform XYK swap using appropriate function based on token path
(define-private (xyk-swap
    (amount uint)
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool-contract))

    ;; Perform swap based on path direction
    (swap-result (if (is-eq is-reversed false)
                    (try! (contract-call?
                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                          pool-contract
                          token-in token-out
                          amount u1))
                    (try! (contract-call?
                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
                          pool-contract
                          token-out token-in
                          amount u1))))
  )
    (ok swap-result)
  )
)

;; Calculate the amount of psBTC needed to swap for Pontis bridge STX fee
(define-private (get-psbtc-swap-amount)
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
    (buffer-fee-amount (/ (* pontis-stx-fee BUFFER_FEE) BPS))
    (total-fee-amount (+ protocol-fee-amount provider-fee-amount buffer-fee-amount))
    (total-stx-amount (+ pontis-stx-fee total-fee-amount))

    ;; Calculate amount of psBTC needed for the swap
    (psbtc-swap-amount (/ (* psbtc-balance total-stx-amount) (- stx-balance total-stx-amount)))
  )
    (ok psbtc-swap-amount)
  )
)

;; Bridge out rune tokens to Bitcoin using Pontis bridge
(define-private (pontis-bridge-rune-out
    (amount uint)
    (rune (buff 26)) (rune-contract <pontis-bridge-ft-trait>)
  )
  (let (
    (bridge-out-result (try! (contract-call?
                             'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-v1 bridge-out-runes
                             rune rune-contract
                             amount (var-get runes-address)
                             0x425443)))
  )
    (ok bridge-out-result)
  )
)