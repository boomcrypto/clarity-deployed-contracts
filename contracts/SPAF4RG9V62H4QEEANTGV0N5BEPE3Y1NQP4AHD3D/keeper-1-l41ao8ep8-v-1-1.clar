;; keeper-1-l41ao8ep8-v-1-1

;; Use all required traits
(use-trait keeper-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u8001))
(define-constant ERR_INVALID_HELPER_DATA (err u8002))
(define-constant ERR_KEEPER_STATUS (err u8003))
(define-constant ERR_INVALID_AMOUNT (err u8004))
(define-constant ERR_INVALID_PRINCIPAL (err u8005))
(define-constant ERR_MINIMUM_RECEIVED (err u8006))

;; Owner address authorized to interact with this contract
(define-data-var owner-address principal 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570)

;; Keeper address authorized to interact with this contract
(define-data-var keeper-address principal 'SPAF4RG9V62H4QEEANTGV0N5BEPE3Y1NQP4AHD3D)

;; Data var used to enable or disable keeper authorization
(define-data-var keeper-authorized bool true)

;; Get owner address
(define-read-only (get-owner-address)
  (ok (var-get owner-address))
)

;; Get keeper address
(define-read-only (get-keeper-address)
  (ok (var-get keeper-address))
)

;; Get keeper authorization status
(define-read-only (get-keeper-authorized)
  (ok (var-get keeper-authorized))
)

;; Swap pBTC to STX and then transfer STX tokens to owner address
(define-public (execute-action-a
    (amount uint) (min-received uint)
    (fee-recipient principal)
  )
  (let (
    ;; Assert tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert keeper type is enabled
    (keeper-check (asserts! (unwrap! (contract-call? .keeper-1-helper-v-1-2 get-keeper-status) ERR_INVALID_HELPER_DATA) ERR_KEEPER_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Assert fee-recipient is standard principal
    (fee-recipient-check (asserts! (is-standard fee-recipient) ERR_INVALID_PRINCIPAL))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? .keeper-1-helper-v-1-2 get-keeper-fee-amount amount) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee
      (if (> keeper-fee-amount u0)
        (try! (as-contract (contract-call? 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC transfer keeper-fee-amount tx-sender fee-recipient none)))
        false
      )
    )

    ;; Perform pBTC to STX swap via XYK Core
    (swap-pbtc-to-stx (try! (as-contract (contract-call?
                                        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                                        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-pbtc-stx-v-1-1
                                        'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC
                                        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                                        amount-after-keeper-fee u1))))
    (caller tx-sender)
  )
    (begin
      ;; Assert swap-pbtc-to-stx is greater than or equal to min-received
      (asserts! (>= swap-pbtc-to-stx min-received) ERR_MINIMUM_RECEIVED)

      ;; Transfer STX tokens from the contract to owner-address
      (try! (as-contract (stx-transfer? swap-pbtc-to-stx tx-sender (var-get owner-address))))

      ;; Print action data and return true
      (print {
        action: "execute-action-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          fee-recipient: fee-recipient,
          keeper-fee-amount: keeper-fee-amount,
          swap-pbtc-to-stx: swap-pbtc-to-stx
        }
      })
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