;; keeper-4-44reo7til-v-1-1

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
(define-constant ERR_NOT_AUTHORIZED (err u8001))
(define-constant ERR_INVALID_HELPER_DATA (err u8002))
(define-constant ERR_KEEPER_STATUS (err u8003))
(define-constant ERR_ACTION_NOT_APPROVED (err u8004))
(define-constant ERR_INVALID_ACTION_APPROVED_DATA (err u8005))
(define-constant ERR_INVALID_AMOUNT (err u8006))
(define-constant ERR_INVALID_PRINCIPAL (err u8007))
(define-constant ERR_MINIMUM_RECEIVED (err u8008))

;; Owner address authorized to interact with this contract
(define-data-var owner-address principal 'SP2JEQDC5QKR473A7V1BC8MSTK841NHR9YNATGQ31)

;; Bitcoin address authorized to receive bridged rune tokens and bitcoin
(define-data-var bitcoin-address (buff 64) 0x)

;; Keeper address authorized to interact with this contract
(define-data-var keeper-address principal 'SP3R9DNHRSBPT42JX98J92ZJHASWSBXT5ZW8X4XCK)

;; Data var used to enable or disable keeper authorization
(define-data-var keeper-authorized bool true)

;; Data var used to enable or disable approval for all keeper action traits
(define-data-var all-actions-approved bool true)

;; Define approved keeper action traits map
(define-map approved-actions principal bool)

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

;; Get approval status for all keeper action traits
(define-read-only (get-all-actions-approved)
  (ok (var-get all-actions-approved))
)

;; Get approval status for keeper action trait
(define-read-only (get-action-approved (action-trait <keeper-action-trait>))
  (ok (or (default-to false (map-get? approved-actions (contract-of action-trait))) (var-get all-actions-approved)))
)

;; Execute action using provided action-trait
(define-public (execute-action-a
    (action-trait <keeper-action-trait>)
    (amount uint) (min-received uint)
    (fee-recipient principal)
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
    ;; Get owner, bitcoin, and keeper addresses
    (owner-addr (var-get owner-address))
    (bitcoin-addr (var-get bitcoin-address))
    (keeper-addr (var-get keeper-address))

    ;; Assert tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert keeper type is enabled
    (keeper-check (asserts! (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-status) ERR_INVALID_HELPER_DATA) ERR_KEEPER_STATUS))

    ;; Assert keeper action trait is approved by helper contract and owner
    (action-check-a (asserts! (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-action-approved action-trait) ERR_INVALID_HELPER_DATA) ERR_ACTION_NOT_APPROVED))
    (action-check-b (asserts! (unwrap! (get-action-approved action-trait) ERR_INVALID_ACTION_APPROVED_DATA) ERR_ACTION_NOT_APPROVED))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Assert fee-recipient is standard principal
    (fee-recipient-check (asserts! (is-standard fee-recipient) ERR_INVALID_PRINCIPAL))

    ;; Execute action from keeper action trait
    (execute-keeper-action (try! (as-contract (contract-call? action-trait execute-action
                                              amount min-received
                                              fee-recipient owner-addr bitcoin-addr keeper-addr
                                              token-list
                                              xyk-pool-list xyk-staking-list xyk-emissions-list
                                              stableswap-pool-list stableswap-staking-list stableswap-emissions-list
                                              uint-list bool-list principal-list))))
    (caller tx-sender)
  )
    (begin
      ;; Print action data and return true
      (print {
        action: "execute-action-a",
        contract: (as-contract tx-sender),
        caller: caller,
        data: {
          action-contract: (contract-of action-trait),
          amount: amount,
          min-received: min-received,
          fee-recipient: fee-recipient,
          owner-address: owner-addr,
          bitcoin-address: bitcoin-addr,
          keeper-address: keeper-addr,
          token-list: token-list,
          xyk-pool-list: xyk-pool-list,
          xyk-staking-list: xyk-staking-list,
          xyk-emissions-list: xyk-emissions-list,
          stableswap-pool-list: stableswap-pool-list,
          stableswap-staking-list: stableswap-staking-list,
          stableswap-emissions-list: stableswap-emissions-list,
          uint-list: uint-list,
          bool-list: bool-list,
          principal-list: principal-list,
          execute-keeper-action: execute-keeper-action
        }
      })
      (ok true)
    )
  )
)

;; Withdraw tokens from this keeper contract
(define-public (withdraw-tokens (token-trait <ft-trait>) (amount uint) (recipient principal))
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

;; Enable or disable approval for all keeper action traits
(define-public (set-all-actions-approved (approved bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Set all-actions-approved to approved
      (var-set all-actions-approved approved)

      ;; Print function data and return true
      (print {action: "set-all-actions-approved", caller: caller, data: {approved: approved}})
      (ok true)
    )
  )
)

;; Set approval status for keeper action trait
(define-public (set-action-approved (action-trait <keeper-action-trait>) (approved bool))
  (let (
    (action-contract (contract-of action-trait))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Assert action-contract is standard principal
      (asserts! (is-standard action-contract) ERR_INVALID_PRINCIPAL)

      ;; Set approval status for keeper action trait in approved-actions map
      (map-set approved-actions action-contract approved)

      ;; Print function data and return true
      (print {
        action: "set-action-approved",
        caller: caller,
        data: {
          action-contract: action-contract,
          approved: approved
        }
      })
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