;; aggregator-core-v-1-1

;; Use SIP 010 trait
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u1004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u1005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u1006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u1007))
(define-constant ERR_INVALID_FEE (err u1008))
(define-constant ERR_AGGREGATOR_DISABLED (err u1010))
(define-constant ERR_CONTRACT_DISABLED (err u1011))
(define-constant ERR_NO_CONTRACT_DATA (err u1012))
(define-constant ERR_NO_PROVIDER_DATA (err u1012))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; Data vars used for default contract data
(define-data-var default-contract-fee-address principal tx-sender)
(define-data-var default-contract-fee uint u0)
(define-data-var default-contract-bps uint u10000)
(define-data-var default-contract-status bool true)

;; Data vars used for default provider data
(define-data-var default-provider-fee uint u0)
(define-data-var default-provider-bps uint u10000)
(define-data-var default-provider-status bool true)

;; Data var used to enable or disable all aggregator contracts
(define-data-var aggregator-status bool true)

;; Define contracts map
(define-map contracts principal {
  fee-address: principal,
  fee: uint,
  bps: uint,
  status: bool
})

;; Define providers map
(define-map providers principal {
  fee: uint,
  bps: uint,
  status: bool
})

;; Define is-fee-exempt map
(define-map is-fee-exempt principal bool)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get default contract data
(define-read-only (get-default-contract)
  (ok {
    fee-address: (var-get default-contract-fee-address),
    fee: (var-get default-contract-fee),
    bps: (var-get default-contract-bps),
    status: (var-get default-contract-status)
  })
)

;; Get default provider data
(define-read-only (get-default-provider)
  (ok {
    fee: (var-get default-provider-fee),
    bps: (var-get default-provider-bps),
    status: (var-get default-provider-status)
  })
)

;; Get aggregator status
(define-read-only (get-aggregator-status)
  (ok (var-get aggregator-status))
)

;; Get contract data or default contract data
(define-read-only (get-contract (contract principal))
  (ok (default-to
    {fee-address: (var-get default-contract-fee-address), fee: (var-get default-contract-fee), bps: (var-get default-contract-bps), status: (var-get default-contract-status)}
    (map-get? contracts contract)
  ))
)

;; Get provider data or default provider data
(define-read-only (get-provider (provider principal))
  (ok (default-to
    {fee: (var-get default-provider-fee), bps: (var-get default-provider-bps), status: (var-get default-provider-status)}
    (map-get? providers provider)
  ))
)

;; Get fee exemption for address
(define-read-only (get-is-fee-exempt (address principal))
  (ok (default-to false (map-get? is-fee-exempt address)))
)

;; Calculate aggregator fees
(define-read-only (get-aggregator-fees (contract principal) (provider (optional principal)) (amount uint))
  (let (
    ;; Check if caller is exempt from fees
    (is-caller-fee-exempt (default-to false (map-get? is-fee-exempt tx-sender)))

    ;; Gather all contract data
    (contract-data (unwrap! (get-contract contract) ERR_NO_CONTRACT_DATA))
    (contract-fee (get fee contract-data))
    (contract-bps (get bps contract-data))

    ;; Gather all provider data
    (provider-data (unwrap! (get-provider (default-to (as-contract tx-sender) provider)) ERR_NO_PROVIDER_DATA))
    (provider-fee (get fee provider-data))
    (provider-bps (get bps provider-data))

    ;; Calculate fees
    (amount-fees-total (if (not is-caller-fee-exempt) (/ (* amount contract-fee) contract-bps) u0))
    (amount-fees-provider (if (get status provider-data) (/ (* amount-fees-total provider-fee) provider-bps) u0))
    (amount-fees-contract (- amount-fees-total amount-fees-provider))
  )
    (begin
      ;; Assert aggregator and contract statuses are true
      (asserts! (var-get aggregator-status) ERR_AGGREGATOR_DISABLED)
      (asserts! (get status contract-data) ERR_CONTRACT_DISABLED)

      ;; Assert contract and provider addresses are standard principals
      (asserts! (is-standard contract) ERR_INVALID_PRINCIPAL)
      (asserts! (or (is-none provider) (is-standard (unwrap-panic provider))) ERR_INVALID_PRINCIPAL)

      ;; Return function data
      (ok {
        is-caller-fee-exempt: is-caller-fee-exempt,
        contract-fee: contract-fee,
        contract-bps: contract-bps,
        provider-fee: provider-fee,
        provider-bps: provider-bps,
        amount-fees-contract: amount-fees-contract,
        amount-fees-provider: amount-fees-provider,
        amount-fees-total: amount-fees-total
      })
    )
  )
)

;; Add an admin to the admins list
(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
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

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
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

;; Set default contract data
(define-public (set-default-contract (fee-address principal) (fee uint) (bps uint) (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee-address is standard principal
      (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)

      ;; Assert fee is less than bps
      (asserts! (< fee bps) ERR_INVALID_FEE)

      ;; Set default contract data
      (var-set default-contract-fee-address fee-address)
      (var-set default-contract-fee fee)
      (var-set default-contract-bps bps)
      (var-set default-contract-status status)

      ;; Print function data and return true
      (print {action: "set-default-contract", caller: caller, data: {fee-address: fee-address, fee: fee, bps: bps, status: status}})
      (ok true)
    )
  )
)

;; Set default provider data
(define-public (set-default-provider (fee uint) (bps uint) (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee is less than bps
      (asserts! (< fee bps) ERR_INVALID_FEE)

      ;; Set default provider data
      (var-set default-provider-fee fee)
      (var-set default-provider-bps bps)
      (var-set default-provider-status status)

      ;; Print function data and return true
      (print {action: "set-default-provider", caller: caller, data: {fee: fee, bps: bps, status: status}})
      (ok true)
    )
  )
)

;; Set aggregator status
(define-public (set-aggregator-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set aggregator-status to status
      (var-set aggregator-status status)

      ;; Print function data and return true
      (print {action: "set-aggregator-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Set data for contract
(define-public (set-contract (contract principal) (fee-address principal) (fee uint) (bps uint) (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert contract and fee-address are standard principals
      (asserts! (is-standard contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)

      ;; Assert fee is less than bps
      (asserts! (< fee bps) ERR_INVALID_FEE)

      ;; Set contract data in contracts map
      (map-set contracts contract {fee-address: fee-address, fee: fee, bps: bps, status: status})

      ;; Print function data and return true
      (print {action: "set-contract", caller: caller, data: {contract: contract, fee-address: fee-address, fee: fee, bps: bps, status: status}})
      (ok true)
    )
  )
)

;; Set data for provider
(define-public (set-provider (provider principal) (fee uint) (bps uint) (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert provider is standard principal
      (asserts! (is-standard provider) ERR_INVALID_PRINCIPAL)

      ;; Assert fee is less than bps
      (asserts! (< fee bps) ERR_INVALID_FEE)

      ;; Set provider data in providers map
      (map-set providers provider {fee: fee, bps: bps, status: status})

      ;; Print function data and return true
      (print {action: "set-provider", caller: caller, data: {provider: provider, fee: fee, bps: bps, status: status}})
      (ok true)
    )
  )
)

;; Set fee exemption for address
(define-public (set-is-fee-exempt (address principal) (exempt bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

      ;; Set fee exemption for address
      (map-set is-fee-exempt address exempt)

      ;; Print function data and return true
      (print {action: "set-is-fee-exempt", caller: caller, data: {address: address, exempt: exempt}})
      (ok true)
    )
  )
)

;; Calculate and transfer aggregator fees
(define-public (transfer-aggregator-fees (token <sip-010-trait>) (contract principal) (provider (optional principal)) (amount uint))
  (let (
    ;; Check if caller is exempt from fees
    (caller tx-sender)
    (is-caller-fee-exempt (default-to false (map-get? is-fee-exempt caller)))

    ;; Gather all contract data
    (contract-data (unwrap! (get-contract contract) ERR_NO_CONTRACT_DATA))
    (contract-fee-address (get fee-address contract-data))
    (contract-fee (get fee contract-data))
    (contract-bps (get bps contract-data))
    (contract-status (get status contract-data))

    ;; Gather all provider data
    (provider-data (unwrap! (get-provider (default-to (as-contract tx-sender) provider)) ERR_NO_PROVIDER_DATA))
    (provider-fee (get fee provider-data))
    (provider-bps (get bps provider-data))
    (provider-status (get status provider-data))
    
    ;; Calculate fees
    (amount-fees-total (if (not is-caller-fee-exempt) (/ (* amount contract-fee) contract-bps) u0))
    (amount-fees-provider (if provider-status (/ (* amount-fees-total provider-fee) provider-bps) u0))
    (amount-fees-contract (- amount-fees-total amount-fees-provider))
  )
    (begin
      ;; Assert aggregator and contract statuses are true
      (asserts! (var-get aggregator-status) ERR_AGGREGATOR_DISABLED)
      (asserts! contract-status ERR_CONTRACT_DISABLED)

      ;; Assert token, contract, and provider addresses are standard principals
      (asserts! (is-standard (contract-of token)) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard contract) ERR_INVALID_PRINCIPAL)
      (asserts! (or (is-none provider) (is-standard (unwrap-panic provider))) ERR_INVALID_PRINCIPAL)

      ;; Transfer amount-fees-contract tokens from caller to contract-fee-address
      (if (> amount-fees-contract u0)
        (try! (contract-call? token transfer amount-fees-contract caller contract-fee-address none))
        false
      )

      ;; Transfer amount-fees-provider tokens from caller to provider
      (if (and (> amount-fees-provider u0) (is-some provider))
        (try! (contract-call? token transfer amount-fees-provider caller (unwrap-panic provider) none))
        false
      )

      ;; Print and return function data
      (print {
        action: "transfer-aggregator-fees",
        caller: caller,
        data: {
          token: token,
          contract: contract,
          provider: provider,
          amount: amount,
          is-caller-fee-exempt: is-caller-fee-exempt,
          contract-fee-address: contract-fee-address,
          contract-fee: contract-fee,
          contract-bps: contract-bps,
          contract-status: contract-status,
          provider-fee: provider-fee,
          provider-bps: provider-bps,
          provider-status: provider-status,
          amount-fees-contract: amount-fees-contract,
          amount-fees-provider: amount-fees-provider,
          amount-fees-total: amount-fees-total
        }
      })
      (ok {
        is-caller-fee-exempt: is-caller-fee-exempt,
        contract-fee: contract-fee,
        contract-bps: contract-bps,
        provider-fee: provider-fee,
        provider-bps: provider-bps,
        amount-fees-contract: amount-fees-contract,
        amount-fees-provider: amount-fees-provider,
        amount-fees-total: amount-fees-total
      })
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)