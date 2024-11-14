;; keeper-3-7qcjiajg4-v-1-1

;; Use all required traits
(use-trait keeper-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait pontis-bridge-ft-trait 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.bridge-ft-trait.bridge-ft-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u9001))
(define-constant ERR_INVALID_HELPER_DATA (err u9002))
(define-constant ERR_KEEPER_STATUS (err u9003))
(define-constant ERR_INVALID_AMOUNT (err u9004))
(define-constant ERR_INVALID_PRINCIPAL (err u9005))
(define-constant ERR_MINIMUM_RECEIVED (err u9006))
(define-constant ERR_AMOUNT_LESS_THAN_FEE (err u9007))
(define-constant ERR_CANNOT_GET_PSBTC_BALANCE (err u9008))
(define-constant ERR_INSUFFICIENT_PSBTC_BALANCE (err u9009))

;; Owner address authorized to interact with this contract
(define-data-var owner-address principal 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M)

;; Bitcoin address authorized to receive bridged rune tokens and bitcoin
(define-data-var bitcoin-address (buff 64) 0x33326151684142516870344a384d544d3847747a45394279505644627947476e4e59)

;; Keeper address authorized to interact with this contract
(define-data-var keeper-address principal 'SPAF4RG9V62H4QEEANTGV0N5BEPE3Y1NQP4AHD3D)

;; Data var used to enable or disable keeper authorization
(define-data-var keeper-authorized bool true)

;; Get owner address
(define-read-only (get-owner-address)
  (ok (var-get owner-address))
)

;; Get Bitcoin address
(define-read-only (get-bitcoin-address)
  (ok (var-get bitcoin-address))
)

;; Get keeper address
(define-read-only (get-keeper-address)
  (ok (var-get keeper-address))
)

;; Get keeper authorization status
(define-read-only (get-keeper-authorized)
  (ok (var-get keeper-authorized))
)

;; Swaps psBTC to rune token and bridges to Bitcoin using Pontis bridge
(define-public (execute-action-a
    (amount uint) (min-received uint) (fee-recipient principal)
    (xyk-tokens (tuple (a <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (pontis-rune (buff 26)) (pontis-rune-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Assert tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert keeper type is enabled
    (keeper-check (asserts! (unwrap! (contract-call? .keeper-3-helper-v-1-1 get-keeper-status) ERR_INVALID_HELPER_DATA) ERR_KEEPER_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Assert fee-recipient is standard principal
    (fee-recipient-check (asserts! (is-standard fee-recipient) ERR_INVALID_PRINCIPAL))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-3-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee
      (if (> keeper-fee-amount u0)
        (try! (as-contract (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC transfer keeper-fee-amount tx-sender fee-recipient none)))
        false
      )
    )

    ;; Get the amount of psBTC to swap for STX to cover Pontis bridge STX fee
    (psbtc-swap-amount (try! (contract-call? .keeper-3-helper-v-1-1 get-psbtc-swap-amount)))

    ;; Get contract's psBTC balance and assert contract has sufficient amount for swap
    (psbtc-balance (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC get-balance (as-contract tx-sender)) ERR_CANNOT_GET_PSBTC_BALANCE))
    (psbtc-balance-check (asserts! (> psbtc-balance psbtc-swap-amount) ERR_INSUFFICIENT_PSBTC_BALANCE))

    ;; Perform psBTC to STX swap via XYK Core to cover Pontis bridge STX fee
    (swap-psbtc-to-stx (try! (as-contract (xyk-swap
                                          psbtc-swap-amount
                                          'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1))))

    ;; Swap remaining psBTC to rune token via XYK Core
    (swap-psbtc-to-rune (try! (as-contract (xyk-swap (- psbtc-balance psbtc-swap-amount) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get a xyk-tokens) (get a xyk-pools)))))

    ;; Bridge out rune token to Bitcoin using Pontis bridge
    (bridge-rune-out (try! (as-contract (pontis-bridge-rune-out swap-psbtc-to-rune pontis-rune pontis-rune-contract))))

    ;; Get contract's STX balance and transfer remaining STX to owner-address
    (stx-balance (stx-get-balance (as-contract tx-sender)))
    (transfer-remaining-stx (try! (as-contract (stx-transfer? stx-balance tx-sender (var-get owner-address)))))
    (caller tx-sender)
  )
    (begin
      ;; Assert bridge-rune-out is greater than or equal to min-received
      (asserts! (>= bridge-rune-out min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return true
      (print {
        action: "execute-action-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          fee-recipient: fee-recipient,
          keeper-fee-amount: keeper-fee-amount,
          psbtc-swap-amount: psbtc-swap-amount,
          swap-psbtc-to-stx: swap-psbtc-to-stx,
          swap-psbtc-to-rune: swap-psbtc-to-rune,
          bridge-rune-out: bridge-rune-out,
          stx-balance: stx-balance
      }})
      (ok true)
    )
  )
)

;; Swaps rune token to psBTC and bridges to Bitcoin using Pontis bridge
(define-public (execute-action-b
    (amount uint) (min-received uint) (fee-recipient principal)
    (xyk-tokens (tuple (a <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (pontis-btc-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Assert tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert keeper type is enabled
    (keeper-check (asserts! (unwrap! (contract-call? .keeper-3-helper-v-1-1 get-keeper-status) ERR_INVALID_HELPER_DATA) ERR_KEEPER_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Assert fee-recipient is standard principal
    (fee-recipient-check (asserts! (is-standard fee-recipient) ERR_INVALID_PRINCIPAL))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-3-helper-v-1-1 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (token-for-keeper-fee (get a xyk-tokens))
    (transfer-keeper-fee
      (if (> keeper-fee-amount u0)
        (try! (as-contract (contract-call? token-for-keeper-fee transfer keeper-fee-amount tx-sender fee-recipient none)))
        false
      )
    )

    ;; Swap rune token to psBTC via XYK Core
    (swap-rune-to-psbtc (try! (as-contract (xyk-swap amount-after-keeper-fee (get a xyk-tokens) 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC (get a xyk-pools)))))

    ;; Get the amount of psBTC to swap for STX to cover Pontis bridge STX fee
    (psbtc-swap-amount (try! (contract-call? .keeper-3-helper-v-1-1 get-psbtc-swap-amount)))

    ;; Get contract's psBTC balance and assert contract has sufficient amount for swap
    (psbtc-balance (unwrap! (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC get-balance (as-contract tx-sender)) ERR_CANNOT_GET_PSBTC_BALANCE))
    (psbtc-balance-check (asserts! (> psbtc-balance psbtc-swap-amount) ERR_INSUFFICIENT_PSBTC_BALANCE))

    ;; Perform psBTC to STX swap via XYK Core to cover Pontis bridge STX fee
    (swap-psbtc-to-stx (try! (as-contract (xyk-swap
                                          psbtc-swap-amount
                                          'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1))))

    ;; Bridge out psBTC to Bitcoin using Pontis bridge
    (bridge-btc-out (try! (as-contract (pontis-bridge-btc-out (- psbtc-balance psbtc-swap-amount) pontis-btc-contract))))

    ;; Get contract's STX balance and transfer remaining STX to owner-address
    (stx-balance (stx-get-balance (as-contract tx-sender)))
    (transfer-remaining-stx (try! (as-contract (stx-transfer? stx-balance tx-sender (var-get owner-address)))))
    (caller tx-sender)
  )
    (begin
      ;; Assert bridge-btc-out is greater than or equal to min-received
      (asserts! (>= bridge-btc-out min-received) ERR_MINIMUM_RECEIVED)

      ;; Print action data and return true
      (print {
        action: "execute-action-b",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          fee-recipient: fee-recipient,
          keeper-fee-amount: keeper-fee-amount,
          swap-rune-to-psbtc: swap-rune-to-psbtc,
          psbtc-swap-amount: psbtc-swap-amount,
          swap-psbtc-to-stx: swap-psbtc-to-stx,
          bridge-btc-out: bridge-btc-out,
          stx-balance: stx-balance
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

      ;; Assert amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert addresses are standard principals
      (asserts! (is-standard token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)

      ;; Transfer tokens from the contract to recipient
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

;; Set owner address authorized to interact with this contract
(define-public (set-owner-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Assert address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

      ;; Set owner-address to address
      (var-set owner-address address)

      ;; Print function data and return true
      (print {action: "set-owner-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

;; Set Bitcoin address authorized to receive bridged rune tokens and bitcoin
(define-public (set-bitcoin-address (address (buff 64)))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Set bitcoin-address to address
      (var-set bitcoin-address address)

      ;; Print function data and return true
      (print {action: "set-bitcoin-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

;; Set keeper address authorized to interact with this contract
(define-public (set-keeper-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert tx-sender is owner or keeper and keeper is authorized
      (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED)

      ;; Assert address is standard principal
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
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Set keeper-authorized to authorized
      (var-set keeper-authorized authorized)

      ;; Print function data and return true
      (print {action: "set-keeper-authorized", caller: caller, data: {authorized: authorized}})
      (ok true)
    )
  )
)

;; Check if tx-sender is owner or keeper and if keeper is authorized
(define-private (is-owner-or-keeper)
  (or
    (is-eq tx-sender (var-get owner-address))
    (and (is-eq tx-sender (var-get keeper-address)) (var-get keeper-authorized))
  )
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

;; Perform swap via XYK Core using appropriate function based on token path
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

;; Bridge out rune tokens to Bitcoin using Pontis bridge
(define-private (pontis-bridge-rune-out
    (amount uint)
    (rune (buff 26)) (rune-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Calculate percent fee required by Pontis based on amount
    (pontis-ft-fee (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager calculate-runes-percent-fee amount))

    ;; Assert amount is sufficient to cover the fee
    (amount-check (asserts! (> amount pontis-ft-fee) ERR_AMOUNT_LESS_THAN_FEE))

    ;; Bridge out rune tokens to the specified Bitcoin address
    (bridge-out-result (try! (contract-call?
                             'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-v2 bridge-out-runes
                             rune rune-contract
                             amount (var-get bitcoin-address)
                             0x425443)))
  )
    ;; Return amount bridged out after subtracting the fee
    (ok (- amount pontis-ft-fee))
  )
)

;; Bridge out psBTC to Bitcoin using Pontis bridge
(define-private (pontis-bridge-btc-out
    (amount uint) (btc-contract <pontis-bridge-ft-trait>)
  )
  (let (
    ;; Calculate percent fee required by Pontis based on amount
    (pontis-ft-fee (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-fee-manager calculate-btc-percent-fee amount))

    ;; Assert amount is sufficient to cover the fee
    (amount-check (asserts! (> amount pontis-ft-fee) ERR_AMOUNT_LESS_THAN_FEE))

    ;; Bridge out psBTC to the specified Bitcoin address
    (bridge-out-result (try! (contract-call?
                             'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-v2 bridge-out-btc
                             btc-contract
                             amount (var-get bitcoin-address)
                             0x425443)))
  )
    ;; Return amount bridged out after subtracting the fee
    (ok (- amount pontis-ft-fee))
  )
)