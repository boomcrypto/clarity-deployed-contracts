;; working-amaranth-clownfish

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .consistent-harlequin-crane.dlmm-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u1004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u1005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u1006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u1007))
(define-constant ERR_NO_POOL_DATA (err u1008))
(define-constant ERR_POOL_NOT_CREATED (err u1009))
(define-constant ERR_POOL_DISABLED (err u1010))
(define-constant ERR_POOL_ALREADY_CREATED (err u1011))
(define-constant ERR_INVALID_POOL (err u1012))
(define-constant ERR_INVALID_POOL_URI (err u1013))
(define-constant ERR_INVALID_POOL_SYMBOL (err u1014))
(define-constant ERR_INVALID_POOL_NAME (err u1015))
(define-constant ERR_INVALID_TOKEN_DIRECTION (err u1016))
(define-constant ERR_MATCHING_TOKEN_CONTRACTS (err u1017))
(define-constant ERR_INVALID_X_TOKEN (err u1018))
(define-constant ERR_INVALID_Y_TOKEN (err u1019))
(define-constant ERR_INVALID_X_AMOUNT (err u1020))
(define-constant ERR_INVALID_Y_AMOUNT (err u1021))
(define-constant ERR_MINIMUM_X_AMOUNT (err u1022))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u1023))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u1024))
(define-constant ERR_MAXIMUM_X_AMOUNT (err u1025))
(define-constant ERR_MAXIMUM_Y_AMOUNT (err u1026))
(define-constant ERR_INVALID_MIN_DLP_AMOUNT (err u1027))
(define-constant ERR_INVALID_LIQUIDITY_VALUE (err u1028))
(define-constant ERR_INVALID_FEE (err u1029))
(define-constant ERR_NO_UNCLAIMED_PROTOCOL_FEES_DATA (err u1030))
(define-constant ERR_MINIMUM_BURN_AMOUNT (err u1031))
(define-constant ERR_INVALID_MIN_BURNT_SHARES (err u1032))
(define-constant ERR_INVALID_BIN_STEP (err u1033))
(define-constant ERR_ALREADY_BIN_STEP (err u1034))
(define-constant ERR_BIN_STEP_LIMIT_REACHED (err u1035))
(define-constant ERR_NO_BIN_FACTORS (err u1036))
(define-constant ERR_INVALID_BIN_FACTOR (err u1037))
(define-constant ERR_INVALID_BIN_FACTORS_LENGTH (err u1038))
(define-constant ERR_INVALID_INITIAL_PRICE (err u1039))
(define-constant ERR_INVALID_BIN_PRICE (err u1040))
(define-constant ERR_MATCHING_BIN_ID (err u1041))
(define-constant ERR_NOT_ACTIVE_BIN (err u1042))
(define-constant ERR_NO_BIN_SHARES (err u1043))
(define-constant ERR_INVALID_VERIFIED_POOL_CODE_HASH (err u1044))
(define-constant ERR_ALREADY_VERIFIED_POOL_CODE_HASH (err u1045))
(define-constant ERR_VERIFIED_POOL_CODE_HASH_LIMIT_REACHED (err u1046))
(define-constant ERR_VARIABLE_FEES_COOLDOWN (err u1047))
(define-constant ERR_VARIABLE_FEES_MANAGER_FROZEN (err u1048))
(define-constant ERR_INVALID_DYNAMIC_CONFIG (err u1049))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Number of bins per pool and center bin ID as unsigned ints
(define-constant NUM_OF_BINS u1001)
(define-constant CENTER_BIN_ID (/ NUM_OF_BINS u2))

;; Minimum and maximum bin IDs as signed ints
(define-constant MIN_BIN_ID -500)
(define-constant MAX_BIN_ID 500)

;; Maximum BPS
(define-constant FEE_SCALE_BPS u10000)
(define-constant PRICE_SCALE_BPS u100000000)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; ID of last created pool
(define-data-var last-pool-id uint u0)

;; Allowed bin steps and factors
(define-data-var bin-steps (list 1000 uint) (list u1 u5 u10 u20 u25))
(define-map bin-factors uint (list 1001 uint))

;; Minimum shares required to mint into the active bin when creating a pool
(define-data-var minimum-bin-shares uint u10000)

;; Minimum shares required to burn from the active bin when creating a pool
(define-data-var minimum-burnt-shares uint u1000)

;; Data var used to enable or disable pool creation by anyone
(define-data-var public-pool-creation bool false)

;; List of verified pool code hashes
(define-data-var verified-pool-code-hashes (list 10000 (buff 32)) (list 0x))

;; Define pools map
(define-map pools uint {
  id: uint,
  name: (string-ascii 32),
  symbol: (string-ascii 32),
  pool-contract: principal,
  verified: bool,
  status: bool
})

;; Define allowed-token-direction map
(define-map allowed-token-direction {x-token: principal, y-token: principal} bool)

;; Define unclaimed-protocol-fees map
(define-map unclaimed-protocol-fees uint {x-fee: uint, y-fee: uint})

;; Define swap-fee-exemptions map
(define-map swap-fee-exemptions {address: principal, id: uint} bool)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get ID of last created pool
(define-read-only (get-last-pool-id)
  (ok (var-get last-pool-id))
)

;; Get a pool by pool ID
(define-read-only (get-pool-by-id (id uint))
  (ok (map-get? pools id))
)

;; Get allowed-token-direction for pool creation
(define-read-only (get-allowed-token-direction (x-token principal) (y-token principal))
  (ok (map-get? allowed-token-direction {x-token: x-token, y-token: y-token}))
)

;; Get unclaimed-protocol-fees for a pool
(define-read-only (get-unclaimed-protocol-fees-by-id (id uint))
  (ok (map-get? unclaimed-protocol-fees id))
)

;; Get swap-fee-exemptions for an address for a pool
(define-read-only (get-swap-fee-exemption-by-id (address principal) (id uint))
  (ok (default-to false (map-get? swap-fee-exemptions {address: address, id: id})))
)

;; Get allowed bin steps
(define-read-only (get-bin-steps)
  (ok (var-get bin-steps))
)

;; Get bin factors by bin step
(define-read-only (get-bin-factors-by-step (step uint))
  (ok (map-get? bin-factors step))
)

;; Get minimum shares required to mint for the active bin when creating a pool
(define-read-only (get-minimum-bin-shares)
  (ok (var-get minimum-bin-shares))
)

;; Get minimum shares required to burn for the active bin when creating a pool
(define-read-only (get-minimum-burnt-shares)
  (ok (var-get minimum-burnt-shares))
)

;; Get public pool creation status
(define-read-only (get-public-pool-creation)
  (ok (var-get public-pool-creation))
)

;; Get verified pool code hashes list
(define-read-only (get-verified-pool-code-hashes)
  (ok (var-get verified-pool-code-hashes))
)

;; Get bin ID as unsigned int
(define-read-only (get-unsigned-bin-id (bin-id int))
  (ok (to-uint (+ bin-id (to-int CENTER_BIN_ID))))
)

;; Get bin ID as signed int
(define-read-only (get-signed-bin-id (bin-id uint))
  (ok (- (to-int bin-id) (to-int CENTER_BIN_ID)))
)

;; Get price for a specific bin
(define-read-only (get-bin-price (initial-price uint) (bin-step uint) (bin-id int))
  (let (
    (unsigned-bin-id (to-uint (+ bin-id (to-int CENTER_BIN_ID))))
    (bin-factors-list (unwrap! (map-get? bin-factors bin-step) ERR_NO_BIN_FACTORS))
    (bin-factor (unwrap! (element-at? bin-factors-list unsigned-bin-id) ERR_INVALID_BIN_FACTOR))
  )
    (ok (/ (* initial-price bin-factor) PRICE_SCALE_BPS))
  )
)

;; Get liquidity value when adding liquidity to a bin by rebasing x-amount to y-units
(define-read-only (get-liquidity-value (x-amount uint) (y-amount uint) (bin-price uint))
  (ok (+ (* bin-price x-amount) y-amount))
)

;; Add a new bin step and its factors
(define-public (add-bin-step (step uint) (factors (list 1001 uint)))
  (let (
    (bin-steps-list (var-get bin-steps))
    (caller tx-sender)
  )
    ;; Assert caller is an admin and step is greater than 0
    (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
    (asserts! (> step u0) ERR_INVALID_AMOUNT)

    ;; Assert step is not in bin-steps-list
    (asserts! (is-none (index-of bin-steps-list step)) ERR_ALREADY_BIN_STEP)

    ;; Assert factors list length is 1001
    (asserts! (is-eq (len factors) u1001) ERR_INVALID_BIN_FACTORS_LENGTH)

    ;; Add bin step to list with max length of 1000
    (var-set bin-steps (unwrap! (as-max-len? (append bin-steps-list step) u1000) ERR_BIN_STEP_LIMIT_REACHED))

    ;; Add bin factors to bin-factors mapping
    (map-set bin-factors step factors)

    ;; Print function data and return true
    (print {action: "add-bin-step", caller: caller, data: {step: step, factors: factors}})
    (ok true)
  )
)

;; Set minimum shares required to mint and burn for the active bin when creating a pool
(define-public (set-minimum-shares (min-bin uint) (min-burnt uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and amounts are greater than 0
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (and (> min-bin u0) (> min-burnt u0)) ERR_INVALID_AMOUNT)

      ;; Assert that min-bin is greater than min-burnt
      (asserts! (> min-bin min-burnt) ERR_INVALID_MIN_BURNT_SHARES)

      ;; Update minimum-bin-shares and minimum-burnt-shares
      (var-set minimum-bin-shares min-bin)
      (var-set minimum-burnt-shares min-burnt)

      ;; Print function data and return true
      (print {
        action: "set-minimum-shares",
        caller: caller,
        data: {
          min-bin: min-bin,
          min-burnt: min-burnt
        }
      })
      (ok true)
    )
  )
)

;; Enable or disable public pool creation
(define-public (set-public-pool-creation (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set public-pool-creation to status
      (var-set public-pool-creation status)

      ;; Print function data and return true
      (print {action: "set-public-pool-creation", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Add a new verified pool code hash
(define-public (add-verified-pool-code-hash (hash (buff 32)))
  (let (
    (verified-pool-code-hashes-list (var-get verified-pool-code-hashes))
    (caller tx-sender)
  )
    ;; Assert caller is an admin and new code hash is not already in list
    (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of verified-pool-code-hashes-list hash)) ERR_ALREADY_VERIFIED_POOL_CODE_HASH)

    ;; Assert that hash is greater than zero
    (asserts! (> (len hash) u0) ERR_INVALID_VERIFIED_POOL_CODE_HASH)

    ;; Add code hash to verified pool code hashes list with max length of 10000
    (var-set verified-pool-code-hashes (unwrap! (as-max-len? (append verified-pool-code-hashes-list hash) u10000) ERR_VERIFIED_POOL_CODE_HASH_LIMIT_REACHED))

    ;; Print function data and return true
    (print {action: "add-verified-pool-code-hash", caller: caller, data: {hash: hash}})
    (ok true)
  )
)

;; Set swap fee exemption for an address for a pool
(define-public (set-swap-fee-exemption (pool-trait <dlmm-pool-trait>) (address principal) (exempt bool))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-id (get pool-id pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool pool-id (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL) 

      ;; Update swap-fee-exemptions mapping
      (map-set swap-fee-exemptions {address: address, id: pool-id} exempt)

      ;; Print function data and return true
      (print {
        action: "set-swap-fee-exemption",
        caller: caller,
        data: {
          pool-id: pool-id,
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          address: address,
          exempt: exempt
        }
      })
      (ok true)
    )
  )
)

;; Claim protocol fees for a pool
(define-public (claim-protocol-fees
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
  )
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-id (get pool-id pool-data))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    
    ;; Get current unclaimed protocol fees for pool
    (current-unclaimed-protocol-fees (unwrap! (map-get? unclaimed-protocol-fees pool-id) ERR_NO_UNCLAIMED_PROTOCOL_FEES_DATA))
    (unclaimed-x-fees (get x-fee current-unclaimed-protocol-fees))
    (unclaimed-y-fees (get y-fee current-unclaimed-protocol-fees))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool is created and valid
      (asserts! (is-valid-pool pool-id (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that correct token traits are used
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Transfer unclaimed-x-fees x tokens from pool-contract to fee-address
      (if (> unclaimed-x-fees u0)
        (try! (contract-call? pool-trait pool-transfer x-token-trait unclaimed-x-fees fee-address))
        false)

      ;; Transfer unclaimed-y-fees y tokens from pool-contract to fee-address
      (if (> unclaimed-y-fees u0)
        (try! (contract-call? pool-trait pool-transfer y-token-trait unclaimed-y-fees fee-address))
        false)

      ;; Update unclaimed-protocol-fees for pool
      (map-set unclaimed-protocol-fees pool-id {x-fee: u0, y-fee: u0})

      ;; Print function data and return true
      (print {
        action: "claim-protocol-fees",
        caller: caller,
        data: {
          pool-id: pool-id,
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          unclaimed-x-fees: unclaimed-x-fees,
          unclaimed-y-fees: unclaimed-y-fees
        }
      })
      (ok true)
    )
  )
)

;; Set pool uri for a pool
(define-public (set-pool-uri (pool-trait <dlmm-pool-trait>) (uri (string-ascii 256)))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that uri length is greater than 0
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)

      ;; Set pool uri for pool
      (try! (contract-call? pool-trait set-pool-uri uri))

      ;; Print function data and return true
      (print {
        action: "set-pool-uri",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          uri: uri
        }
      })
      (ok true)
    )
  )
)

;; Set pool status for a pool
(define-public (set-pool-status (pool-trait <dlmm-pool-trait>) (status bool))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-map-data (unwrap! (map-get? pools (get pool-id pool-data)) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Set pool status for pool
      (map-set pools (get pool-id pool-data) (merge pool-map-data {status: status}))

      ;; Print function data and return true
      (print {
        action: "set-pool-status",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          status: status
        }
      })
      (ok true)
    )
  )
)

;; Set variable fees manager for a pool
(define-public (set-variable-fees-manager (pool-trait <dlmm-pool-trait>) (manager principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (freeze-variable-fees-manager (get freeze-variable-fees-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that variable fees manager is not frozen
      (asserts! (not freeze-variable-fees-manager) ERR_VARIABLE_FEES_MANAGER_FROZEN)

      ;; Assert that address is standard principal
      (asserts! (is-standard manager) ERR_INVALID_PRINCIPAL) 

      ;; Set variable fees manager for pool
      (try! (contract-call? pool-trait set-variable-fees-manager manager))

      ;; Print function data and return true
      (print {
        action: "set-variable-fees-manager",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          manager: manager
        }
      })
      (ok true)
    )
  )
)

;; Set fee address for a pool
(define-public (set-fee-address (pool-trait <dlmm-pool-trait>) (address principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

      ;; Set fee address for pool
      (try! (contract-call? pool-trait set-fee-address address))

      ;; Print function data and return true
      (print {
        action: "set-fee-address",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          address: address
        }
      })
      (ok true)
    )
  )
)

;; Set variable fees for a pool
(define-public (set-variable-fees (pool-trait <dlmm-pool-trait>) (x-fee uint) (y-fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (variable-fees-manager (get variable-fees-manager pool-data))
    (freeze-variable-fees-manager (get freeze-variable-fees-manager pool-data))
    (x-protocol-fee (get x-protocol-fee pool-data))
    (x-provider-fee (get x-provider-fee pool-data))
    (y-protocol-fee (get y-protocol-fee pool-data))
    (y-provider-fee (get y-provider-fee pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin or variable fees manager and pool is created and valid
      (asserts! (or (is-some (index-of (var-get admins) caller)) (is-eq variable-fees-manager caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that caller is variable fees manager if variable fees manager is frozen
      (asserts! (or (is-eq variable-fees-manager caller) (not freeze-variable-fees-manager)) ERR_NOT_AUTHORIZED)

      ;; Assert x-fee + x-protocol-fee + x-provider-fee is less than maximum FEE_SCALE_BPS
      (asserts! (< (+ x-fee x-protocol-fee x-provider-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Assert y-fee + y-protocol-fee + y-provider-fee is less than maximum FEE_SCALE_BPS
      (asserts! (< (+ y-fee y-protocol-fee y-provider-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Set variable fees for pool
      (try! (contract-call? pool-trait set-variable-fees x-fee y-fee))

      ;; Print function data and return true
      (print {
        action: "set-variable-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          x-protocol-fee: x-protocol-fee,
          x-provider-fee: x-provider-fee,
          x-variable-fee: x-fee,
          y-protocol-fee: y-protocol-fee,
          y-provider-fee: y-provider-fee,
          y-variable-fee: y-fee
        }
      })
      (ok true)
    )
  )
)

;; Set x fees for a pool
(define-public (set-x-fees (pool-trait <dlmm-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (x-variable-fee (get x-variable-fee pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert protocol-fee + provider-fee + x-variable-fee is less than maximum FEE_SCALE_BPS
      (asserts! (< (+ protocol-fee provider-fee x-variable-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Set x fees for pool
      (try! (contract-call? pool-trait set-x-fees protocol-fee provider-fee))

      ;; Print function data and return true
      (print {
        action: "set-x-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          x-protocol-fee: protocol-fee,
          x-provider-fee: provider-fee,
          x-variable-fee: x-variable-fee
        }
      })
      (ok true)
    )
  )
)

;; Set y fees for a pool
(define-public (set-y-fees (pool-trait <dlmm-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (y-variable-fee (get y-variable-fee pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert protocol-fee + provider-fee + y-variable-fee is less than maximum FEE_SCALE_BPS
      (asserts! (< (+ protocol-fee provider-fee y-variable-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Set y fees for pool
      (try! (contract-call? pool-trait set-y-fees protocol-fee provider-fee))

      ;; Print function data and return true
      (print {
        action: "set-y-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          y-protocol-fee: protocol-fee,
          y-provider-fee: provider-fee,
          y-variable-fee: y-variable-fee
        }
      })
      (ok true)
    )
  )
)

;; Set variable fees cooldown for a pool
(define-public (set-variable-fees-cooldown (pool-trait <dlmm-pool-trait>) (cooldown uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Set variable fees cooldown for pool
      (try! (contract-call? pool-trait set-variable-fees-cooldown cooldown))

      ;; Print function data and return true
      (print {
        action: "set-variable-fees-cooldown",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          cooldown: cooldown
        }
      })
      (ok true)
    )
  )
)

;; Make variable fees manager immutable for a pool
(define-public (set-freeze-variable-fees-manager (pool-trait <dlmm-pool-trait>))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (freeze-variable-fees-manager (get freeze-variable-fees-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that variable fees manager is not frozen
      (asserts! (not freeze-variable-fees-manager) ERR_VARIABLE_FEES_MANAGER_FROZEN)

      ;; Set freeze variable fees manager for pool
      (try! (contract-call? pool-trait set-freeze-variable-fees-manager))

      ;; Print function data and return true
      (print {
        action: "set-freeze-variable-fees-manager",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait)
        }
      })
      (ok true)
    )
  )
)

;; Set dynamic config for a pool
(define-public (set-dynamic-config (pool-trait <dlmm-pool-trait>) (config (buff 4096)))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (variable-fees-manager (get variable-fees-manager pool-data))
    (freeze-variable-fees-manager (get freeze-variable-fees-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin or variable fees manager and pool is created and valid
      (asserts! (or (is-some (index-of (var-get admins) caller)) (is-eq variable-fees-manager caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that caller is variable fees manager if variable fees manager is frozen
      (asserts! (or (is-eq variable-fees-manager caller) (not freeze-variable-fees-manager)) ERR_NOT_AUTHORIZED)

      ;; Assert that config is greater than zero
      (asserts! (> (len config) u0) ERR_INVALID_DYNAMIC_CONFIG)

      ;; Set dynamic config for pool
      (try! (contract-call? pool-trait set-dynamic-config config))

      ;; Print function data and return true
      (print {
        action: "set-dynamic-config",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          config: config
        }
      })
      (ok true)
    )
  )
)

;; Reset variable fees for a pool
(define-public (reset-variable-fees (pool-trait <dlmm-pool-trait>))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (last-variable-fees-update (get last-variable-fees-update pool-data))
    (variable-fees-cooldown (get variable-fees-cooldown pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool is created and valid
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (get pool-created pool-data) ERR_POOL_NOT_CREATED)

      ;; Assert that variable fees cooldown period has passed
      (asserts! (>= stacks-block-height (+ last-variable-fees-update variable-fees-cooldown)) ERR_VARIABLE_FEES_COOLDOWN)

      ;; Reset variable fees for pool
      (try! (contract-call? pool-trait set-variable-fees u0 u0))

      ;; Print function data and return true
      (print {
        action: "reset-variable-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait)
        }
      })
      (ok true)
    )
  )
)

;; Create a new pool
(define-public (create-pool 
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount-active-bin uint) (y-amount-active-bin uint) (burn-amount-active-bin uint)
    (x-protocol-fee uint) (x-provider-fee uint)
    (y-protocol-fee uint) (y-provider-fee uint)
    (bin-step uint) (variable-fees-cooldown uint) (freeze-variable-fees-manager bool)
    (fee-address principal)
    (uri (string-ascii 256)) (status bool)
  )
  (let (
    ;; Gather all pool data and pool contract
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))

    ;; Get pool ID and create pool symbol and name
    (new-pool-id (+ (var-get last-pool-id) u1))
    (symbol (unwrap! (create-symbol x-token-trait y-token-trait) ERR_INVALID_POOL_SYMBOL))
    (name (concat symbol "-LP"))

    ;; Check if pool code hash is verified @NOTE use contract-hash?
    (pool-verified-check (is-some (index-of (var-get verified-pool-code-hashes) 0x)))

    ;; Get token contracts
    (x-token-contract (contract-of x-token-trait))
    (y-token-contract (contract-of y-token-trait))

    ;; Get initial price at active bin
    (initial-price (/ (* y-amount-active-bin PRICE_SCALE_BPS) x-amount-active-bin))

    ;; Scale up y-amount-active-bin
    (y-amount-active-bin-scaled (* y-amount-active-bin PRICE_SCALE_BPS))

    ;; Get liquidity value and calculate dlp
    (add-liquidity-value (unwrap! (get-liquidity-value x-amount-active-bin y-amount-active-bin-scaled initial-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp (sqrti add-liquidity-value))
    (caller tx-sender)
  )
    (begin
      ;; Assert that caller is an admin or public-pool-creation is true
      (asserts! (or (is-some (index-of (var-get admins) caller)) (var-get public-pool-creation)) ERR_NOT_AUTHORIZED)

      ;; Assert that pool is not created
      (asserts! (not (get pool-created pool-data)) ERR_POOL_ALREADY_CREATED)

      ;; Assert that x-token-contract and y-token-contract are not matching
      (asserts! (not (is-eq x-token-contract y-token-contract)) ERR_MATCHING_TOKEN_CONTRACTS)

      ;; Assert that addresses are standard principals
      (asserts! (is-standard x-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard y-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)

      ;; Assert that reverse token direction is not registered
      (asserts! (is-none (map-get? allowed-token-direction {x-token: y-token-contract, y-token: x-token-contract})) ERR_INVALID_TOKEN_DIRECTION)

      ;; Assert that x-amount-active-bin and y-amount-active-bin are greater than 0
      (asserts! (and (> x-amount-active-bin u0) (> y-amount-active-bin u0)) ERR_INVALID_AMOUNT)

      ;; Assert that dlp minted meets minimum bin shares required
      (asserts! (>= dlp (var-get minimum-bin-shares)) ERR_MINIMUM_LP_AMOUNT)

      ;; Assert that burn-amount-active-bin meets minimum shares required to burn
      (asserts! (>= burn-amount-active-bin (var-get minimum-burnt-shares)) ERR_MINIMUM_BURN_AMOUNT)

      ;; Assert that dlp is greater than or equal to 0 after subtracting burn amount
      (asserts! (>= (- dlp burn-amount-active-bin) u0) ERR_MINIMUM_LP_AMOUNT)

      ;; Assert that length of pool uri, symbol, and name is greater than 0
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      (asserts! (> (len symbol) u0) ERR_INVALID_POOL_SYMBOL)
      (asserts! (> (len name) u0) ERR_INVALID_POOL_NAME)

      ;; Assert that fees are less than maximum BPS
      (asserts! (< (+ x-protocol-fee x-provider-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)
      (asserts! (< (+ y-protocol-fee y-provider-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Assert that bin step is valid
      (asserts! (is-some (index-of (var-get bin-steps) bin-step)) ERR_INVALID_BIN_STEP)

      ;; Create pool, set fees, and set variable fees cooldown
      (try! (contract-call? pool-trait create-pool x-token-contract y-token-contract CONTRACT_DEPLOYER fee-address caller 0 bin-step initial-price new-pool-id name symbol uri))
      (try! (contract-call? pool-trait set-x-fees x-protocol-fee x-provider-fee))
      (try! (contract-call? pool-trait set-y-fees y-protocol-fee y-provider-fee))
      (try! (contract-call? pool-trait set-variable-fees-cooldown variable-fees-cooldown))

      ;; Freeze variable fees manager if freeze-variable-fees-manager is true
      (if freeze-variable-fees-manager (try! (contract-call? pool-trait set-freeze-variable-fees-manager)) false)

      ;; Update ID of last created pool, add pool to pools map, and add pool to unclaimed-protocol-fees map
      (var-set last-pool-id new-pool-id)
      (map-set pools new-pool-id {id: new-pool-id, name: name, symbol: symbol, pool-contract: pool-contract, verified: pool-verified-check, status: status})
      (map-set unclaimed-protocol-fees new-pool-id {x-fee: u0, y-fee: u0})

      ;; Update allowed-token-direction map if needed
      (if (is-none (map-get? allowed-token-direction {x-token: x-token-contract, y-token: y-token-contract}))
          (map-set allowed-token-direction {x-token: x-token-contract, y-token: y-token-contract} true)
          false)

      ;; Transfer x-amount-active-bin x tokens and y-amount-active-bin y tokens from caller to pool-contract
      (try! (contract-call? x-token-trait transfer x-amount-active-bin caller pool-contract none))
      (try! (contract-call? y-token-trait transfer y-amount-active-bin caller pool-contract none))

      ;; Update bin balances
      (try! (contract-call? pool-trait update-bin-balances CENTER_BIN_ID x-amount-active-bin y-amount-active-bin))

      ;; Mint LP tokens to caller
      (try! (contract-call? pool-trait pool-mint CENTER_BIN_ID (- dlp burn-amount-active-bin) caller))

      ;; Mint burn amount LP tokens to pool-contract
      (try! (contract-call? pool-trait pool-mint CENTER_BIN_ID burn-amount-active-bin pool-contract))

      ;; Print create pool data and return true
      (print {
        action: "create-pool",
        caller: caller,
        data: {
          pool-id: new-pool-id,
          pool-name: name,
          pool-contract: pool-contract,
          pool-verified: pool-verified-check,
          x-token: x-token-contract,
          y-token: y-token-contract,
          x-protocol-fee: x-protocol-fee,
          x-provider-fee: x-provider-fee,
          x-variable-fee: u0,
          y-protocol-fee: y-protocol-fee,
          y-provider-fee: y-provider-fee,
          y-variable-fee: u0,
          x-amount-active-bin: x-amount-active-bin,
          y-amount-active-bin: y-amount-active-bin,
          burn-amount-active-bin: burn-amount-active-bin,
          dlp: dlp,
          add-liquidity-value: add-liquidity-value,
          pool-symbol: symbol,
          pool-uri: uri,
          pool-status: status,
          creation-height: burn-block-height,
          active-bin-id: 0,
          bin-step: bin-step,
          initial-price: initial-price,
          variable-fees-manager: CONTRACT_DEPLOYER,
          fee-address: fee-address,
          variable-fees-cooldown: variable-fees-cooldown,
          freeze-variable-fees-manager: freeze-variable-fees-manager
        }
      })
      (ok true)
    )
  )
)

;; Swap x token for y token via a bin in a pool
(define-public (swap-x-for-y
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (bin-id int) (x-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (caller tx-sender)
    (pool-data (unwrap! (contract-call? pool-trait get-pool-for-swap true) ERR_NO_POOL_DATA))
    (pool-id (get pool-id pool-data))
    (pool-contract (contract-of pool-trait))
    (pool-validity-check (asserts! (is-valid-pool pool-id pool-contract) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (bin-step (get bin-step pool-data))
    (initial-price (get initial-price pool-data))
    (active-bin-id (get active-bin-id pool-data))

    ;; Check if caller is fee exempt and calculate swap fees
    (swap-fee-exemption (default-to false (map-get? swap-fee-exemptions {address: caller, id: pool-id})))
    (protocol-fee (if swap-fee-exemption u0 (get protocol-fee pool-data)))
    (provider-fee (if swap-fee-exemption u0 (get provider-fee pool-data)))
    (variable-fee (if swap-fee-exemption u0 (get variable-fee pool-data)))

    ;; Convert bin-id to an unsigned bin-id
    (unsigned-bin-id (to-uint (+ bin-id (to-int CENTER_BIN_ID))))

    ;; Get balances at bin
    (bin-balances (try! (contract-call? pool-trait get-bin-balances unsigned-bin-id)))
    (x-balance (get x-balance bin-balances))
    (y-balance (get y-balance bin-balances))

    ;; Get price at bin
    (bin-price (unwrap! (get-bin-price initial-price bin-step bin-id) ERR_INVALID_BIN_PRICE))

    ;; Calculate maximum x-amount with fees
    (max-x-amount (/ (* y-balance PRICE_SCALE_BPS) bin-price))
    (max-x-amount-fees-total (/ (* max-x-amount (+ protocol-fee provider-fee variable-fee)) FEE_SCALE_BPS))
    (updated-max-x-amount (+ max-x-amount max-x-amount-fees-total))

    ;; Assert that x-amount is less than or equal to updated-max-x-amount
    (x-amount-check (asserts! (<= x-amount updated-max-x-amount) ERR_MAXIMUM_X_AMOUNT))

    ;; Calculate fees and dx
    (x-amount-fees-protocol (/ (* x-amount protocol-fee) FEE_SCALE_BPS))
    (x-amount-fees-provider (/ (* x-amount provider-fee) FEE_SCALE_BPS))
    (x-amount-fees-variable (/ (* x-amount variable-fee) FEE_SCALE_BPS))
    (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider x-amount-fees-variable))
    (dx (- x-amount x-amount-fees-total))

    ;; Calculate dy
    (dy (/ (* dx bin-price) PRICE_SCALE_BPS))

    ;; Calculate updated bin balances
    (updated-x-balance (+ x-balance dx x-amount-fees-provider x-amount-fees-variable))
    (updated-y-balance (- y-balance dy))

    ;; Calculate new active bin ID (default to bin-id if at the edge of the bin range)
    (updated-active-bin-id (if (and (is-eq updated-y-balance u0) (> bin-id MIN_BIN_ID))
                               (- bin-id 1)
                               bin-id))

    ;; Get current unclaimed protocol fees for pool
    (current-unclaimed-protocol-fees (unwrap! (map-get? unclaimed-protocol-fees pool-id) ERR_NO_UNCLAIMED_PROTOCOL_FEES_DATA))
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-enabled-pool pool-id) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that x-amount is greater than 0
      (asserts! (> x-amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that bin-id is equal to active-bin-id
      (asserts! (is-eq bin-id active-bin-id) ERR_NOT_ACTIVE_BIN)

      ;; Transfer dx + x-amount-fees-total x tokens from caller to pool-contract
      (try! (contract-call? x-token-trait transfer (+ dx x-amount-fees-total) caller pool-contract none))

      ;; Transfer dy y tokens from pool-contract to caller
      (try! (contract-call? pool-trait pool-transfer y-token-trait dy caller))

      ;; Update unclaimed-protocol-fees for pool
      (if (> x-amount-fees-protocol u0)
          (map-set unclaimed-protocol-fees pool-id (merge current-unclaimed-protocol-fees {
            x-fee: (+ (get x-fee current-unclaimed-protocol-fees) x-amount-fees-protocol)
          }))
          false)

      ;; Update bin balances
      (try! (contract-call? pool-trait update-bin-balances unsigned-bin-id updated-x-balance updated-y-balance))

      ;; Set active bin ID
      (if (not (is-eq updated-active-bin-id active-bin-id))
          (try! (contract-call? pool-trait set-active-bin-id updated-active-bin-id))
          false)

      ;; Print swap data and return number of y tokens the caller received
      (print {
        action: "swap-x-for-y",
        caller: caller,
        data: {
          pool-id: pool-id,
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          bin-step: bin-step,
          initial-price: initial-price,
          bin-price: bin-price,
          active-bin-id: active-bin-id,
          updated-active-bin-id: updated-active-bin-id,
          bin-id: bin-id,
          unsigned-bin-id: unsigned-bin-id,
          x-amount: x-amount,
          max-x-amount: updated-max-x-amount,
          x-amount-fees-protocol: x-amount-fees-protocol,
          x-amount-fees-provider: x-amount-fees-provider,
          x-amount-fees-variable: x-amount-fees-variable,
          swap-fee-exemption: swap-fee-exemption,
          dx: dx,
          dy: dy,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance
        }
      })
      (ok dy)
    )
  )
)

;; Swap y token for x token via a bin in a pool
(define-public (swap-y-for-x
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (bin-id int) (y-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (caller tx-sender)
    (pool-data (unwrap! (contract-call? pool-trait get-pool-for-swap false) ERR_NO_POOL_DATA))
    (pool-id (get pool-id pool-data))
    (pool-contract (contract-of pool-trait))
    (pool-validity-check (asserts! (is-valid-pool pool-id pool-contract) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (bin-step (get bin-step pool-data))
    (initial-price (get initial-price pool-data))
    (active-bin-id (get active-bin-id pool-data))

    ;; Check if caller is fee exempt and calculate swap fees
    (swap-fee-exemption (default-to false (map-get? swap-fee-exemptions {address: caller, id: pool-id})))
    (protocol-fee (if swap-fee-exemption u0 (get protocol-fee pool-data)))
    (provider-fee (if swap-fee-exemption u0 (get provider-fee pool-data)))
    (variable-fee (if swap-fee-exemption u0 (get variable-fee pool-data)))

    ;; Convert bin-id to an unsigned bin-id
    (unsigned-bin-id (to-uint (+ bin-id (to-int CENTER_BIN_ID))))

    ;; Get balances at bin
    (bin-balances (try! (contract-call? pool-trait get-bin-balances unsigned-bin-id)))
    (x-balance (get x-balance bin-balances))
    (y-balance (get y-balance bin-balances))

    ;; Get price at bin
    (bin-price (unwrap! (get-bin-price initial-price bin-step bin-id) ERR_INVALID_BIN_PRICE))

    ;; Calculate maximum y-amount with fees
    (max-y-amount (/ (* x-balance bin-price) PRICE_SCALE_BPS))
    (max-y-amount-fees-total (/ (* max-y-amount (+ protocol-fee provider-fee variable-fee)) FEE_SCALE_BPS))
    (updated-max-y-amount (+ max-y-amount max-y-amount-fees-total))

    ;; Assert that y-amount is less than or equal to updated-max-y-amount
    (y-amount-check (asserts! (<= y-amount updated-max-y-amount) ERR_MAXIMUM_Y_AMOUNT))

    ;; Calculate fees and dy
    (y-amount-fees-protocol (/ (* y-amount protocol-fee) FEE_SCALE_BPS))
    (y-amount-fees-provider (/ (* y-amount provider-fee) FEE_SCALE_BPS))
    (y-amount-fees-variable (/ (* y-amount variable-fee) FEE_SCALE_BPS))
    (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider y-amount-fees-variable))
    (dy (- y-amount y-amount-fees-total))

    ;; Calculate dx
    (dx (/ (* dy PRICE_SCALE_BPS) bin-price))

    ;; Calculate updated bin balances
    (updated-x-balance (- x-balance dx))
    (updated-y-balance (+ y-balance dy y-amount-fees-provider y-amount-fees-variable))

    ;; Calculate new active bin ID (default to bin-id if at the edge of the bin range)
    (updated-active-bin-id (if (and (is-eq updated-x-balance u0) (< bin-id MAX_BIN_ID))
                               (+ bin-id 1)
                               bin-id))

    ;; Get current unclaimed protocol fees for pool
    (current-unclaimed-protocol-fees (unwrap! (map-get? unclaimed-protocol-fees pool-id) ERR_NO_UNCLAIMED_PROTOCOL_FEES_DATA))
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-enabled-pool pool-id) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that y-amount is greater than 0
      (asserts! (> y-amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that bin-id is equal to active-bin-id
      (asserts! (is-eq bin-id active-bin-id) ERR_NOT_ACTIVE_BIN)

      ;; Transfer dy + y-amount-fees-total y tokens from caller to pool-contract
      (try! (contract-call? y-token-trait transfer (+ dy y-amount-fees-total) caller pool-contract none))

      ;; Transfer dx x tokens from pool-contract to caller
      (try! (contract-call? pool-trait pool-transfer x-token-trait dx caller))

      ;; Update unclaimed-protocol-fees for pool
      (if (> y-amount-fees-protocol u0)
          (map-set unclaimed-protocol-fees pool-id (merge current-unclaimed-protocol-fees {
            y-fee: (+ (get y-fee current-unclaimed-protocol-fees) y-amount-fees-protocol)
          }))
          false)

      ;; Update bin balances
      (try! (contract-call? pool-trait update-bin-balances unsigned-bin-id updated-x-balance updated-y-balance))

      ;; Set active bin ID
      (if (not (is-eq updated-active-bin-id active-bin-id))
          (try! (contract-call? pool-trait set-active-bin-id updated-active-bin-id))
          false)

      ;; Print swap data and return number of x tokens the caller received
      (print {
        action: "swap-y-for-x",
        caller: caller,
        data: {
          pool-id: pool-id,
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          bin-step: bin-step,
          initial-price: initial-price,
          bin-price: bin-price,
          active-bin-id: active-bin-id,
          updated-active-bin-id: updated-active-bin-id,
          bin-id: bin-id,
          unsigned-bin-id: unsigned-bin-id,
          y-amount: y-amount,
          max-y-amount: updated-max-y-amount,
          y-amount-fees-protocol: y-amount-fees-protocol,
          y-amount-fees-provider: y-amount-fees-provider,
          y-amount-fees-variable: y-amount-fees-variable,
          swap-fee-exemption: swap-fee-exemption,
          dy: dy,
          dx: dx,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance
        }
      })
      (ok dx)
    )
  )
)

;; Add liquidity to a bin in a pool
(define-public (add-liquidity
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (bin-id int) (x-amount uint) (y-amount uint) (min-dlp uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool-for-add) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) pool-contract) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (bin-step (get bin-step pool-data))
    (initial-price (get initial-price pool-data))
    (active-bin-id (get active-bin-id pool-data))

    ;; Convert bin-id to an unsigned bin-id
    (unsigned-bin-id (to-uint (+ bin-id (to-int CENTER_BIN_ID))))

    ;; Get balances at bin
    (bin-balances (try! (contract-call? pool-trait get-bin-balances unsigned-bin-id)))
    (x-balance (get x-balance bin-balances))
    (y-balance (get y-balance bin-balances))
    (bin-shares (get bin-shares bin-balances))

    ;; Get price at bin
    (bin-price (unwrap! (get-bin-price initial-price bin-step bin-id) ERR_INVALID_BIN_PRICE))

    ;; Scale up y-amount and y-balance
    (y-amount-scaled (* y-amount PRICE_SCALE_BPS))
    (y-balance-scaled (* y-balance PRICE_SCALE_BPS))

    ;; Get current liquidity values and calculate dlp without fees
    (add-liquidity-value (unwrap! (get-liquidity-value x-amount y-amount-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (bin-liquidity-value (unwrap! (get-liquidity-value x-balance y-balance-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp (if (or (is-eq bin-shares u0) (is-eq bin-liquidity-value u0))
             (sqrti add-liquidity-value)
             (/ (* add-liquidity-value bin-shares) bin-liquidity-value)))

    ;; Calculate liquidity fees if adding liquidity to active bin based on ratio of bin balances
    (x-amount-fees-liquidity (if (is-eq bin-id active-bin-id)
      (let (
        (x-liquidity-fee (+ (get x-protocol-fee pool-data) (get x-provider-fee pool-data) (get x-variable-fee pool-data)))

        ;; Calculate withdrawable x-amount without fees
        (x-amount-withdrawable (/ (* dlp (+ x-balance x-amount)) (+ bin-shares dlp)))

        ;; Calculate max liquidity fee for x-amount
        (max-x-amount-fees-liquidity (if (> x-amount-withdrawable x-amount)
                                           (/ (* (- x-amount-withdrawable x-amount) x-liquidity-fee) FEE_SCALE_BPS)
                                           u0))
      )
        ;; Calculate final liquidity fee for x-amount
        (if (> x-amount max-x-amount-fees-liquidity) max-x-amount-fees-liquidity x-amount)
      )
      u0
    ))
    (y-amount-fees-liquidity (if (is-eq bin-id active-bin-id)
      (let (
        (y-liquidity-fee (+ (get y-protocol-fee pool-data) (get y-provider-fee pool-data) (get y-variable-fee pool-data)))

        ;; Calculate withdrawable y-amount without fees
        (y-amount-withdrawable (/ (* dlp (+ y-balance y-amount)) (+ bin-shares dlp)))

        ;; Calculate max liquidity fee for y-amount
        (max-y-amount-fees-liquidity (if (> y-amount-withdrawable y-amount)
                                           (/ (* (- y-amount-withdrawable y-amount) y-liquidity-fee) FEE_SCALE_BPS)
                                           u0))
      )
        ;; Calculate final liquidity fee for y-amount
        (if (> y-amount max-y-amount-fees-liquidity) max-y-amount-fees-liquidity y-amount)
      )
      u0
    ))

    ;; Calculate final x and y amounts post fees
    (x-amount-post-fees (- x-amount x-amount-fees-liquidity))
    (y-amount-post-fees (- y-amount y-amount-fees-liquidity))
    (y-amount-post-fees-scaled (* y-amount-post-fees PRICE_SCALE_BPS))

    ;; Get final liquidity value and calculate dlp post fees
    (add-liquidity-value-post-fees (unwrap! (get-liquidity-value x-amount-post-fees y-amount-post-fees-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp-post-fees (if (or (is-eq bin-shares u0) (is-eq bin-liquidity-value u0))
                       (sqrti add-liquidity-value-post-fees)
                       (/ (* add-liquidity-value-post-fees bin-shares) bin-liquidity-value)))

    ;; Calculate updated bin balances
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-enabled-pool (get pool-id pool-data)) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that correct token amounts are being added based on bin-id and active-bin-id
      (asserts! (or (>= bin-id active-bin-id) (is-eq x-amount u0)) ERR_INVALID_X_AMOUNT)
      (asserts! (or (<= bin-id active-bin-id) (is-eq y-amount u0)) ERR_INVALID_Y_AMOUNT)

      ;; Assert that min-dlp is greater than 0 and dlp-post-fees is greater than or equal to min-dlp
      (asserts! (> min-dlp u0) ERR_INVALID_MIN_DLP_AMOUNT)
      (asserts! (>= dlp-post-fees min-dlp) ERR_MINIMUM_LP_AMOUNT)

      ;; Transfer x-amount x tokens from caller to pool-contract (includes x-amount-fees-liquidity)
      (if (> x-amount u0)
          (try! (contract-call? x-token-trait transfer x-amount caller pool-contract none))
          false)

      ;; Transfer y-amount y tokens from caller to pool-contract (includes y-amount-fees-liquidity)
      (if (> y-amount u0)
          (try! (contract-call? y-token-trait transfer y-amount caller pool-contract none))
          false)

      ;; Update bin balances
      (try! (contract-call? pool-trait update-bin-balances unsigned-bin-id updated-x-balance updated-y-balance))

      ;; Mint LP tokens to caller
      (try! (contract-call? pool-trait pool-mint unsigned-bin-id dlp-post-fees caller))

      ;; Print add liquidity data and return number of LP tokens the caller received
      (print {
        action: "add-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          bin-step: bin-step,
          initial-price: initial-price,
          bin-price: bin-price,
          active-bin-id: active-bin-id,
          bin-id: bin-id,
          unsigned-bin-id: unsigned-bin-id,
          x-amount: x-amount-post-fees,
          y-amount: y-amount-post-fees,
          x-amount-fees-liquidity: x-amount-fees-liquidity,
          y-amount-fees-liquidity: y-amount-fees-liquidity,
          dlp: dlp-post-fees,
          min-dlp: min-dlp,
          add-liquidity-value: add-liquidity-value-post-fees,
          bin-liquidity-value: bin-liquidity-value,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance,
          updated-bin-shares: (+ bin-shares dlp-post-fees)
        }
      })
      (ok dlp-post-fees)
    )
  )
)

;; Withdraw liquidity from a bin in a pool
(define-public (withdraw-liquidity
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (bin-id int) (amount uint) (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool-for-withdraw) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) pool-contract) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))

    ;; Convert bin-id to an unsigned bin-id
    (unsigned-bin-id (to-uint (+ bin-id (to-int CENTER_BIN_ID))))

    ;; Get balances at bin
    (bin-balances (try! (contract-call? pool-trait get-bin-balances unsigned-bin-id)))
    (x-balance (get x-balance bin-balances))
    (y-balance (get y-balance bin-balances))
    (bin-shares (get bin-shares bin-balances))

    ;; Assert that bin shares is greater than 0
    (bin-shares-check (asserts! (> bin-shares u0) ERR_NO_BIN_SHARES))

    ;; Calculate x-amount and y-amount to transfer
    (x-amount (/ (* amount x-balance) bin-shares))
    (y-amount (/ (* amount y-balance) bin-shares))

    ;; Calculate updated bin balances
    (updated-x-balance (- x-balance x-amount))
    (updated-y-balance (- y-balance y-amount))
    (caller tx-sender)
  )
    (begin
      ;; Assert that correct token traits are used
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that min-x-amount + min-y-amount is greater than 0
      (asserts! (> (+ min-x-amount min-y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount is greater than or equal to min-x-amount
      (asserts! (>= x-amount min-x-amount) ERR_MINIMUM_X_AMOUNT)

      ;; Assert that y-amount is greater than or equal to min-y-amount
      (asserts! (>= y-amount min-y-amount) ERR_MINIMUM_Y_AMOUNT)

      ;; Transfer x-amount x tokens from pool-contract to caller
      (if (> x-amount u0)
          (try! (contract-call? pool-trait pool-transfer x-token-trait x-amount caller))
          false)

      ;; Transfer y-amount y tokens from pool-contract to caller
      (if (> y-amount u0)
          (try! (contract-call? pool-trait pool-transfer y-token-trait y-amount caller))
          false)

      ;; Update bin balances
      (try! (contract-call? pool-trait update-bin-balances-on-withdraw unsigned-bin-id updated-x-balance updated-y-balance bin-shares))

      ;; Burn LP tokens from caller
      (try! (contract-call? pool-trait pool-burn unsigned-bin-id amount caller))

      ;; Print withdraw liquidity data and return number of x and y tokens the caller received
      (print {
        action: "withdraw-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          bin-id: bin-id,
          unsigned-bin-id: unsigned-bin-id,
          amount: amount,
          x-amount: x-amount,
          y-amount: y-amount,
          min-x-amount: min-x-amount,
          min-y-amount: min-y-amount,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance,
          updated-bin-shares: (- bin-shares amount)
        }
      })
      (ok {x-amount: x-amount, y-amount: y-amount})
    )
  )
)

;; Move liquidity from one bin to another in a pool
(define-public (move-liquidity
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (from-bin-id int) (to-bin-id int) (amount uint) (min-dlp uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool-for-add) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) pool-contract) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (bin-step (get bin-step pool-data))
    (initial-price (get initial-price pool-data))
    (active-bin-id (get active-bin-id pool-data))

    ;; Convert bin IDs to unsigned bin IDs
    (unsigned-from-bin-id (to-uint (+ from-bin-id (to-int CENTER_BIN_ID))))
    (unsigned-to-bin-id (to-uint (+ to-bin-id (to-int CENTER_BIN_ID))))

    ;; Get balances at from-bin-id
    (bin-balances-a (try! (contract-call? pool-trait get-bin-balances unsigned-from-bin-id)))
    (x-balance-a (get x-balance bin-balances-a))
    (y-balance-a (get y-balance bin-balances-a))
    (bin-shares-a (get bin-shares bin-balances-a))

    ;; Assert that bin shares for from-bin-id is greater than 0
    (bin-shares-check (asserts! (> bin-shares-a u0) ERR_NO_BIN_SHARES))

    ;; Calculate x-amount and y-amount to withdraw from from-bin-id
    (x-amount (/ (* amount x-balance-a) bin-shares-a))
    (y-amount (/ (* amount y-balance-a) bin-shares-a))

    ;; Calculate updated bin balances for from-bin-id
    (updated-x-balance-a (- x-balance-a x-amount))
    (updated-y-balance-a (- y-balance-a y-amount))

    ;; Get balances at to-bin-id
    (bin-balances-b (try! (contract-call? pool-trait get-bin-balances unsigned-to-bin-id)))
    (x-balance-b (get x-balance bin-balances-b))
    (y-balance-b (get y-balance bin-balances-b))
    (bin-shares-b (get bin-shares bin-balances-b))

    ;; Get price at to-bin-id
    (bin-price (unwrap! (get-bin-price initial-price bin-step to-bin-id) ERR_INVALID_BIN_PRICE))

    ;; Scale up y-amount and y-balance-b
    (y-amount-scaled (* y-amount PRICE_SCALE_BPS))
    (y-balance-b-scaled (* y-balance-b PRICE_SCALE_BPS))

    ;; Get current liquidity values for to-bin-id and calculate dlp without fees
    (add-liquidity-value (unwrap! (get-liquidity-value x-amount y-amount-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (bin-liquidity-value (unwrap! (get-liquidity-value x-balance-b y-balance-b-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp (if (or (is-eq bin-shares-b u0) (is-eq bin-liquidity-value u0))
             (sqrti add-liquidity-value)
             (/ (* add-liquidity-value bin-shares-b) bin-liquidity-value)))

    ;; Calculate liquidity fees if adding liquidity to active bin based on ratio of bin balances
    (x-amount-fees-liquidity (if (is-eq to-bin-id active-bin-id)
      (let (
        (x-liquidity-fee (+ (get x-protocol-fee pool-data) (get x-provider-fee pool-data) (get x-variable-fee pool-data)))

        ;; Calculate withdrawable x-amount without fees
        (x-amount-withdrawable (/ (* dlp (+ x-balance-b x-amount)) (+ bin-shares-b dlp)))

        ;; Calculate max liquidity fee for x-amount
        (max-x-amount-fees-liquidity (if (> x-amount-withdrawable x-amount)
                                           (/ (* (- x-amount-withdrawable x-amount) x-liquidity-fee) FEE_SCALE_BPS)
                                           u0))
      )
        ;; Calculate final liquidity fee for x-amount
        (if (> x-amount max-x-amount-fees-liquidity) max-x-amount-fees-liquidity x-amount)
      )
      u0
    ))
    (y-amount-fees-liquidity (if (is-eq to-bin-id active-bin-id)
      (let (
        (y-liquidity-fee (+ (get y-protocol-fee pool-data) (get y-provider-fee pool-data) (get y-variable-fee pool-data)))

        ;; Calculate withdrawable y-amount without fees
        (y-amount-withdrawable (/ (* dlp (+ y-balance-b y-amount)) (+ bin-shares-b dlp)))

        ;; Calculate max liquidity fee for y-amount
        (max-y-amount-fees-liquidity (if (> y-amount-withdrawable y-amount)
                                           (/ (* (- y-amount-withdrawable y-amount) y-liquidity-fee) FEE_SCALE_BPS)
                                           u0))
      )
        ;; Calculate final liquidity fee for y-amount
        (if (> y-amount max-y-amount-fees-liquidity) max-y-amount-fees-liquidity y-amount)
      )
      u0
    ))

    ;; Calculate final x and y amounts post fees for to-bin-id
    (x-amount-post-fees (- x-amount x-amount-fees-liquidity))
    (y-amount-post-fees (- y-amount y-amount-fees-liquidity))
    (y-amount-post-fees-scaled (* y-amount-post-fees PRICE_SCALE_BPS))

    ;; Get final liquidity value for to-bin-id and calculate dlp post fees
    (add-liquidity-value-post-fees (unwrap! (get-liquidity-value x-amount-post-fees y-amount-post-fees-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp-post-fees (if (or (is-eq bin-shares-b u0) (is-eq bin-liquidity-value u0))
                       (sqrti add-liquidity-value-post-fees)
                       (/ (* add-liquidity-value-post-fees bin-shares-b) bin-liquidity-value)))

    ;; Calculate updated bin balances for to-bin-id
    (updated-x-balance-b (+ x-balance-b x-amount))
    (updated-y-balance-b (+ y-balance-b y-amount))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-enabled-pool (get pool-id pool-data)) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that from-bin-id is not equal to to-bin-id
      (asserts! (not (is-eq from-bin-id to-bin-id)) ERR_MATCHING_BIN_ID)

      ;; Assert that correct token amounts are being added based on to-bin-id and active-bin-id
      (asserts! (or (>= to-bin-id active-bin-id) (is-eq x-amount u0)) ERR_INVALID_X_AMOUNT)
      (asserts! (or (<= to-bin-id active-bin-id) (is-eq y-amount u0)) ERR_INVALID_Y_AMOUNT)

      ;; Assert that min-dlp is greater than 0 and dlp-post-fees is greater than or equal to min-dlp
      (asserts! (> min-dlp u0) ERR_INVALID_MIN_DLP_AMOUNT)
      (asserts! (>= dlp-post-fees min-dlp) ERR_MINIMUM_LP_AMOUNT)

      ;; Update bin balances for from-bin-id
      (try! (contract-call? pool-trait update-bin-balances-on-withdraw unsigned-from-bin-id updated-x-balance-a updated-y-balance-a bin-shares-a))

      ;; Burn LP tokens from caller for from-bin-id
      (try! (contract-call? pool-trait pool-burn unsigned-from-bin-id amount caller))

      ;; Update bin balances for to-bin-id
      (try! (contract-call? pool-trait update-bin-balances unsigned-to-bin-id updated-x-balance-b updated-y-balance-b))

      ;; Mint LP tokens to caller for to-bin-id
      (try! (contract-call? pool-trait pool-mint unsigned-to-bin-id dlp-post-fees caller))

      ;; Print move liquidity data and return number of LP tokens the caller received
      (print {
        action: "move-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          bin-step: bin-step,
          initial-price: initial-price,
          bin-price: bin-price,
          active-bin-id: active-bin-id,
          from-bin-id: from-bin-id,
          to-bin-id: to-bin-id,
          unsigned-from-bin-id: unsigned-from-bin-id,
          unsigned-to-bin-id: unsigned-to-bin-id,
          amount: amount,
          x-amount: x-amount-post-fees,
          y-amount: y-amount-post-fees,
          x-amount-fees-liquidity: x-amount-fees-liquidity,
          y-amount-fees-liquidity: y-amount-fees-liquidity,
          dlp: dlp-post-fees,
          min-dlp: min-dlp,
          add-liquidity-value: add-liquidity-value-post-fees,
          bin-liquidity-value: bin-liquidity-value,
          updated-x-balance-a: updated-x-balance-a,
          updated-y-balance-a: updated-y-balance-a,
          updated-bin-shares-a: (- bin-shares-a amount),
          updated-x-balance-b: updated-x-balance-b,
          updated-y-balance-b: updated-y-balance-b,
          updated-bin-shares-b: (+ bin-shares-b dlp-post-fees)
        }
      })
      (ok dlp-post-fees)
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

;; Set swap fee exemption for multiple addresses across multiple pools
(define-public (set-swap-fee-exemption-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (addresses (list 120 principal))
    (exempts (list 120 bool))
  )
  (ok (map set-swap-fee-exemption pool-traits addresses exempts))
)

;; Claim protocol fees for multiple pools
(define-public (claim-protocol-fees-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (x-token-traits (list 120 <sip-010-trait>))
    (y-token-traits (list 120 <sip-010-trait>))
  )
  (ok (map claim-protocol-fees pool-traits x-token-traits y-token-traits))
)

;; Set pool uri for multiple pools
(define-public (set-pool-uri-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (uris (list 120 (string-ascii 256)))
  )
  (ok (map set-pool-uri pool-traits uris))
)

;; Set pool status for multiple pools
(define-public (set-pool-status-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (statuses (list 120 bool))
  )
  (ok (map set-pool-status pool-traits statuses))
)

;; Set variable fees manager for multiple pools
(define-public (set-variable-fees-manager-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (managers (list 120 principal))
  )
  (ok (map set-variable-fees-manager pool-traits managers))
)

;; Set fee address for multiple pools
(define-public (set-fee-address-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (addresses (list 120 principal))
  )
  (ok (map set-fee-address pool-traits addresses))
)

;; Set variable fees for multiple pools
(define-public (set-variable-fees-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (x-fees (list 120 uint))
    (y-fees (list 120 uint))
  )
  (ok (map set-variable-fees pool-traits x-fees y-fees))
)

;; Set x fees for multiple pools
(define-public (set-x-fees-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (protocol-fees (list 120 uint))
    (provider-fees (list 120 uint))
  )
  (ok (map set-x-fees pool-traits protocol-fees provider-fees))
)

;; Set y fees for multiple pools
(define-public (set-y-fees-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (protocol-fees (list 120 uint))
    (provider-fees (list 120 uint))
  )
  (ok (map set-y-fees pool-traits protocol-fees provider-fees))
)

;; Set variable fees cooldown for multiple pools
(define-public (set-variable-fees-cooldown-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (cooldowns (list 120 uint))
  )
  (ok (map set-variable-fees-cooldown pool-traits cooldowns))
)

;; Set freeze variable fees manager for multiple pools
(define-public (set-freeze-variable-fees-manager-multi (pool-traits (list 120 <dlmm-pool-trait>)))
  (ok (map set-freeze-variable-fees-manager pool-traits))
)

;; Reset variable fees for multiple pools
(define-public (reset-variable-fees-multi (pool-traits (list 120 <dlmm-pool-trait>)))
  (ok (map reset-variable-fees pool-traits))
)

;; Set dynamic config for multiple pools
(define-public (set-dynamic-config-multi
    (pool-traits (list 120 <dlmm-pool-trait>))
    (configs (list 120 (buff 4096)))
  )
  (ok (map set-dynamic-config pool-traits configs))
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Create pool symbol using x token and y token symbols
(define-private (create-symbol (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
  (let (
    ;; Get x token and y token symbols
    (x-symbol (unwrap-panic (contract-call? x-token-trait get-symbol)))
    (y-symbol (unwrap-panic (contract-call? y-token-trait get-symbol)))

    ;; Truncate symbols if length exceeds 14
    (x-truncated 
      (if (> (len x-symbol) u14)
          (unwrap-panic (slice? x-symbol u0 u14))
          x-symbol))
    (y-truncated
      (if (> (len y-symbol) u14)
          (unwrap-panic (slice? y-symbol u0 u14))
          y-symbol))
  )
    ;; Return pool symbol with max length of 29
    (as-max-len? (concat x-truncated (concat "-" y-truncated)) u29)
  )
)

;; Check if a pool is valid
(define-private (is-valid-pool (id uint) (contract principal))
  (let (
    (pool-data (unwrap! (map-get? pools id) false))
  )
    (is-eq contract (get pool-contract pool-data))
  )
)

;; Check if a pool is enabled
(define-private (is-enabled-pool (id uint))
  (let (
    (pool-data (unwrap! (map-get? pools id) false))
  )
    (is-eq (get status pool-data) true)
  )
)

;; Set initial bin factors at contract deployment
(map-set bin-factors u25 (list u28695206 u28766944 u28838862 u28910959 u28983236 u29055694 u29128334 u29201155 u29274157 u29347343 u29420711 u29494263 u29567999 u29641919 u29716023 u29790313 u29864789 u29939451 u30014300 u30089336 u30164559 u30239970 u30315570 u30391359 u30467338 u30543506 u30619865 u30696414 u30773155 u30850088 u30927214 u31004532 u31082043 u31159748 u31237647 u31315741 u31394031 u31472516 u31551197 u31630075 u31709150 u31788423 u31867894 u31947564 u32027433 u32107502 u32187770 u32268240 u32348910 u32429783 u32510857 u32592134 u32673615 u32755299 u32837187 u32919280 u33001578 u33084082 u33166792 u33249709 u33332833 u33416165 u33499706 u33583455 u33667414 u33751582 u33835961 u33920551 u34005353 u34090366 u34175592 u34261031 u34346683 u34432550 u34518631 u34604928 u34691440 u34778169 u34865114 u34952277 u35039658 u35127257 u35215075 u35303113 u35391371 u35479849 u35568549 u35657470 u35746614 u35835980 u35925570 u36015384 u36105423 u36195686 u36286175 u36376891 u36467833 u36559003 u36650400 u36742026 u36833881 u36925966 u37018281 u37110827 u37203604 u37296613 u37389854 u37483329 u37577037 u37670980 u37765157 u37859570 u37954219 u38049104 u38144227 u38239588 u38335187 u38431025 u38527102 u38623420 u38719979 u38816779 u38913821 u39011105 u39108633 u39206404 u39304420 u39402681 u39501188 u39599941 u39698941 u39798188 u39897684 u39997428 u40097422 u40197665 u40298159 u40398905 u40499902 u40601152 u40702655 u40804411 u40906422 u41008688 u41111210 u41213988 u41317023 u41420316 u41523866 u41627676 u41731745 u41836075 u41940665 u42045516 u42150630 u42256007 u42361647 u42467551 u42573720 u42680154 u42786855 u42893822 u43001056 u43108559 u43216330 u43324371 u43432682 u43541264 u43650117 u43759242 u43868640 u43978312 u44088258 u44198478 u44308975 u44419747 u44530796 u44642123 u44753729 u44865613 u44977777 u45090221 u45202947 u45315954 u45429244 u45542817 u45656674 u45770816 u45885243 u45999956 u46114956 u46230243 u46345819 u46461684 u46577838 u46694282 u46811018 u46928046 u47045366 u47162979 u47280887 u47399089 u47517587 u47636381 u47755472 u47874860 u47994547 u48114534 u48234820 u48355407 u48476296 u48597486 u48718980 u48840778 u48962879 u49085287 u49208000 u49331020 u49454347 u49577983 u49701928 u49826183 u49950749 u50075625 u50200814 u50326317 u50452132 u50578263 u50704708 u50831470 u50958549 u51085945 u51213660 u51341694 u51470048 u51598723 u51727720 u51857040 u51986682 u52116649 u52246941 u52377558 u52508502 u52639773 u52771372 u52903301 u53035559 u53168148 u53301068 u53434321 u53567907 u53701827 u53836081 u53970671 u54105598 u54240862 u54376464 u54512405 u54648686 u54785308 u54922271 u55059577 u55197226 u55335219 u55473557 u55612241 u55751272 u55890650 u56030376 u56170452 u56310879 u56451656 u56592785 u56734267 u56876102 u57018293 u57160838 u57303741 u57447000 u57590617 u57734594 u57878930 u58023628 u58168687 u58314109 u58459894 u58606044 u58752559 u58899440 u59046689 u59194305 u59342291 u59490647 u59639373 u59788472 u59937943 u60087788 u60238007 u60388602 u60539574 u60690923 u60842650 u60994757 u61147244 u61300112 u61453362 u61606996 u61761013 u61915416 u62070204 u62225380 u62380943 u62536895 u62693238 u62849971 u63007096 u63164613 u63322525 u63480831 u63639533 u63798632 u63958129 u64118024 u64278319 u64439015 u64600112 u64761613 u64923517 u65085826 u65248540 u65411661 u65575191 u65739129 u65903476 u66068235 u66233406 u66398989 u66564987 u66731399 u66898228 u67065473 u67233137 u67401220 u67569723 u67738647 u67907994 u68077764 u68247958 u68418578 u68589624 u68761098 u68933001 u69105334 u69278097 u69451292 u69624921 u69798983 u69973480 u70148414 u70323785 u70499595 u70675843 u70852533 u71029664 u71207239 u71385257 u71563720 u71742629 u71921986 u72101791 u72282045 u72462750 u72643907 u72825517 u73007581 u73190100 u73373075 u73556508 u73740399 u73924750 u74109562 u74294836 u74480573 u74666774 u74853441 u75040575 u75228176 u75416247 u75604787 u75793799 u75983284 u76173242 u76363675 u76554584 u76745971 u76937836 u77130180 u77323006 u77516313 u77710104 u77904379 u78099140 u78294388 u78490124 u78686349 u78883065 u79080273 u79277973 u79476168 u79674859 u79874046 u80073731 u80273915 u80474600 u80675787 u80877476 u81079670 u81282369 u81485575 u81689289 u81893512 u82098246 u82303491 u82509250 u82715523 u82922312 u83129618 u83337442 u83545786 u83754650 u83964037 u84173947 u84384382 u84595343 u84806831 u85018848 u85231395 u85444474 u85658085 u85872230 u86086911 u86302128 u86517883 u86734178 u86951013 u87168391 u87386312 u87604778 u87823790 u88043349 u88263457 u88484116 u88705326 u88927090 u89149407 u89372281 u89595712 u89819701 u90044250 u90269361 u90495034 u90721272 u90948075 u91175445 u91403384 u91631892 u91860972 u92090624 u92320851 u92551653 u92783032 u93014990 u93247527 u93480646 u93714348 u93948634 u94183505 u94418964 u94655011 u94891649 u95128878 u95366700 u95605117 u95844130 u96083740 u96323949 u96564759 u96806171 u97048187 u97290807 u97534034 u97777869 u98022314 u98267370 u98513038 u98759321 u99006219 u99253734 u99501869 u99750623 u100000000 u100250000 u100500625 u100751877 u101003756 u101256266 u101509406 u101763180 u102017588 u102272632 u102528313 u102784634 u103041596 u103299200 u103557448 u103816341 u104075882 u104336072 u104596912 u104858404 u105120550 u105383352 u105646810 u105910927 u106175704 u106441144 u106707247 u106974015 u107241450 u107509553 u107778327 u108047773 u108317892 u108588687 u108860159 u109132309 u109405140 u109678653 u109952850 u110227732 u110503301 u110779559 u111056508 u111334149 u111612485 u111891516 u112171245 u112451673 u112732802 u113014634 u113297171 u113580414 u113864365 u114149026 u114434398 u114720484 u115007285 u115294804 u115583041 u115871998 u116161678 u116452082 u116743213 u117035071 u117327658 u117620977 u117915030 u118209817 u118505342 u118801605 u119098609 u119396356 u119694847 u119994084 u120294069 u120594804 u120896291 u121198532 u121501528 u121805282 u122109795 u122415070 u122721108 u123027910 u123335480 u123643819 u123952928 u124262811 u124573468 u124884901 u125197114 u125510106 u125823882 u126138441 u126453787 u126769922 u127086847 u127404564 u127723075 u128042383 u128362489 u128683395 u129005104 u129327616 u129650935 u129975063 u130300000 u130625750 u130952315 u131279696 u131607895 u131936915 u132266757 u132597424 u132928917 u133261240 u133594393 u133928379 u134263200 u134598858 u134935355 u135272693 u135610875 u135949902 u136289777 u136630501 u136972077 u137314508 u137657794 u138001938 u138346943 u138692811 u139039543 u139387142 u139735609 u140084948 u140435161 u140786249 u141138214 u141491060 u141844787 u142199399 u142554898 u142911285 u143268563 u143626735 u143985802 u144345766 u144706631 u145068397 u145431068 u145794646 u146159132 u146524530 u146890842 u147258069 u147626214 u147995279 u148365268 u148736181 u149108021 u149480791 u149854493 u150229129 u150604702 u150981214 u151358667 u151737064 u152116406 u152496697 u152877939 u153260134 u153643284 u154027393 u154412461 u154798492 u155185488 u155573452 u155962386 u156352292 u156743172 u157135030 u157527868 u157921688 u158316492 u158712283 u159109064 u159506836 u159905604 u160305368 u160706131 u161107896 u161510666 u161914443 u162319229 u162725027 u163131839 u163539669 u163948518 u164358390 u164769285 u165181209 u165594162 u166008147 u166423168 u166839225 u167256323 u167674464 u168093650 u168513885 u168935169 u169357507 u169780901 u170205353 u170630867 u171057444 u171485087 u171913800 u172343585 u172774444 u173206380 u173639396 u174073494 u174508678 u174944950 u175382312 u175820768 u176260320 u176700970 u177142723 u177585580 u178029544 u178474617 u178920804 u179368106 u179816526 u180266068 u180716733 u181168525 u181621446 u182075500 u182530688 u182987015 u183444483 u183903094 u184362851 u184823759 u185285818 u185749033 u186213405 u186678939 u187145636 u187613500 u188082534 u188552740 u189024122 u189496682 u189970424 u190445350 u190921463 u191398767 u191877264 u192356957 u192837850 u193319944 u193803244 u194287752 u194773472 u195260405 u195748556 u196237928 u196728522 u197220344 u197713395 u198207678 u198703197 u199199955 u199697955 u200197200 u200697693 u201199437 u201702436 u202206692 u202712209 u203218989 u203727037 u204236354 u204746945 u205258813 u205771960 u206286389 u206802105 u207319111 u207837409 u208357002 u208877895 u209400089 u209923589 u210448398 u210974519 u211501956 u212030711 u212560787 u213092189 u213624920 u214158982 u214694380 u215231116 u215769193 u216308616 u216849388 u217391511 u217934990 u218479828 u219026027 u219573592 u220122526 u220672833 u221224515 u221777576 u222332020 u222887850 u223445070 u224003682 u224563691 u225125101 u225687913 u226252133 u226817764 u227384808 u227953270 u228523153 u229094461 u229667197 u230241365 u230816969 u231394011 u231972496 u232552427 u233133808 u233716643 u234300934 u234886687 u235473903 u236062588 u236652745 u237244377 u237837488 u238432081 u239028161 u239625732 u240224796 u240825358 u241427422 u242030990 u242636068 u243242658 u243850764 u244460391 u245071542 u245684221 u246298432 u246914178 u247531463 u248150292 u248770668 u249392594 u250016076 u250641116 u251267719 u251895888 u252525628 u253156942 u253789834 u254424309 u255060370 u255698020 u256337266 u256978109 u257620554 u258264605 u258910267 u259557543 u260206436 u260856952 u261509095 u262162868 u262818275 u263475320 u264134009 u264794344 u265456330 u266119970 u266785270 u267452234 u268120864 u268791166 u269463144 u270136802 u270812144 u271489174 u272167897 u272848317 u273530438 u274214264 u274899800 u275587049 u276276017 u276966707 u277659124 u278353271 u279049155 u279746777 u280446144 u281147260 u281850128 u282554753 u283261140 u283969293 u284679216 u285390914 u286104392 u286819653 u287536702 u288255543 u288976182 u289698623 u290422869 u291148926 u291876799 u292606491 u293338007 u294071352 u294806530 u295543547 u296282406 u297023112 u297765669 u298510084 u299256359 u300004500 u300754511 u301506397 u302260163 u303015814 u303773353 u304532786 u305294118 u306057354 u306822497 u307589553 u308358527 u309129424 u309902247 u310677003 u311453695 u312232330 u313012910 u313795443 u314579931 u315366381 u316154797 u316945184 u317737547 u318531891 u319328221 u320126541 u320926857 u321729175 u322533498 u323339831 u324148181 u324958551 u325770948 u326585375 u327401838 u328220343 u329040894 u329863496 u330688155 u331514875 u332343662 u333174522 u334007458 u334842477 u335679583 u336518782 u337360079 u338203479 u339048988 u339896610 u340746352 u341598217 u342452213 u343308344 u344166614 u345027031 u345889599 u346754323 u347621208 u348490261))