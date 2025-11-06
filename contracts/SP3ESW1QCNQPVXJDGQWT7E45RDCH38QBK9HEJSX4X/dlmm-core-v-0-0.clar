;; dlmm-core-v-0-0

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .dlmm-pool-trait-v-0-0.dlmm-pool-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-0-0.sip-010-trait)

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
(define-constant ERR_MAXIMUM_X_LIQUIDITY_FEE (err u1030))
(define-constant ERR_MAXIMUM_Y_LIQUIDITY_FEE (err u1031))
(define-constant ERR_NO_UNCLAIMED_PROTOCOL_FEES_DATA (err u1032))
(define-constant ERR_MINIMUM_BURN_AMOUNT (err u1033))
(define-constant ERR_INVALID_MIN_BURNT_SHARES (err u1034))
(define-constant ERR_INVALID_BIN_STEP (err u1035))
(define-constant ERR_ALREADY_BIN_STEP (err u1036))
(define-constant ERR_BIN_STEP_LIMIT_REACHED (err u1037))
(define-constant ERR_NO_BIN_FACTORS (err u1038))
(define-constant ERR_INVALID_BIN_FACTOR (err u1039))
(define-constant ERR_INVALID_FIRST_BIN_FACTOR (err u1040))
(define-constant ERR_INVALID_CENTER_BIN_FACTOR (err u1041))
(define-constant ERR_UNSORTED_BIN_FACTORS_LIST (err u1042))
(define-constant ERR_INVALID_BIN_FACTORS_LENGTH (err u1043))
(define-constant ERR_INVALID_INITIAL_PRICE (err u1044))
(define-constant ERR_INVALID_BIN_PRICE (err u1045))
(define-constant ERR_MATCHING_BIN_ID (err u1046))
(define-constant ERR_NOT_ACTIVE_BIN (err u1047))
(define-constant ERR_NO_BIN_SHARES (err u1048))
(define-constant ERR_INVALID_POOL_CODE_HASH (err u1049))
(define-constant ERR_INVALID_VERIFIED_POOL_CODE_HASH (err u1050))
(define-constant ERR_ALREADY_VERIFIED_POOL_CODE_HASH (err u1051))
(define-constant ERR_VERIFIED_POOL_CODE_HASH_LIMIT_REACHED (err u1052))
(define-constant ERR_VERIFIED_POOL_CODE_HASH_NOT_IN_LIST (err u1053))
(define-constant ERR_VARIABLE_FEES_COOLDOWN (err u1054))
(define-constant ERR_VARIABLE_FEES_MANAGER_FROZEN (err u1055))
(define-constant ERR_INVALID_DYNAMIC_CONFIG (err u1056))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Address used when burning LP tokens
(define-constant BURN_ADDRESS (unwrap-panic (principal-construct? (if is-in-mainnet 0x16 0x1a) 0x0000000000000000000000000000000000000000)))

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
(define-data-var bin-steps (list 1000 uint) (list ))
(define-map bin-factors uint (list 1001 uint))

;; Minimum shares required to mint into the active bin when creating a pool
(define-data-var minimum-bin-shares uint u10000)

;; Minimum shares required to burn from the active bin when creating a pool
(define-data-var minimum-burnt-shares uint u1000)

;; Data var used to enable or disable pool creation by anyone
(define-data-var public-pool-creation bool false)

;; List of verified pool code hashes and helper var used to remove hashes
(define-data-var verified-pool-code-hashes (list 10000 (buff 32)) (list ))
(define-data-var verified-pool-code-hashes-helper (buff 32) 0x)

;; Define pools map
(define-map pools uint {
  id: uint,
  name: (string-ascii 32),
  symbol: (string-ascii 32),
  pool-contract: principal,
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

;; Get verified pool code hashes helper var
(define-read-only (get-verified-pool-code-hashes-helper)
  (ok (var-get verified-pool-code-hashes-helper))
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
    (bin-price (/ (* initial-price bin-factor) PRICE_SCALE_BPS))
  )
    (asserts! (> bin-price u0) ERR_INVALID_BIN_PRICE)
    (ok bin-price)
  )
)

;; Get liquidity value when adding liquidity to a bin by rebasing x-amount to y-units
(define-read-only (get-liquidity-value (x-amount uint) (y-amount uint) (bin-price uint))
  (ok (+ (* bin-price x-amount) y-amount))
)

;; Get pool verification status
(define-read-only (get-is-pool-verified (pool-trait <dlmm-pool-trait>))
  (let (
    (pool-code-hash 0x)
  )
    (ok (is-some (index-of (var-get verified-pool-code-hashes) pool-code-hash)))
  )
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

    ;; Assert first factor is greater than 0
    (asserts! (> (unwrap! (element-at? factors u0) ERR_INVALID_BIN_FACTORS_LENGTH) u0) ERR_INVALID_FIRST_BIN_FACTOR)

    ;; Assert center factor is equal to PRICE_SCALE_BPS
    (asserts! (is-eq (unwrap! (element-at? factors CENTER_BIN_ID) ERR_INVALID_BIN_FACTORS_LENGTH) PRICE_SCALE_BPS) ERR_INVALID_CENTER_BIN_FACTOR)

    ;; Assert factors list is in ascending order
    (try! (fold fold-are-bin-factors-ascending factors (ok u0)))

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
    ;; Assert caller is an admin and new code hash is not already in the list
    (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of verified-pool-code-hashes-list hash)) ERR_ALREADY_VERIFIED_POOL_CODE_HASH)

    ;; Assert that hash length is 32
    (asserts! (is-eq (len hash) u32) ERR_INVALID_VERIFIED_POOL_CODE_HASH)

    ;; Add code hash to verified pool code hashes list with max length of 10000
    (var-set verified-pool-code-hashes (unwrap! (as-max-len? (append verified-pool-code-hashes-list hash) u10000) ERR_VERIFIED_POOL_CODE_HASH_LIMIT_REACHED))

    ;; Print function data and return true
    (print {action: "add-verified-pool-code-hash", caller: caller, data: {hash: hash}})
    (ok true)
  )
)

;; Remove a verified pool code hash
(define-public (remove-verified-pool-code-hash (hash (buff 32)))
  (let (
    (verified-pool-code-hashes-list (var-get verified-pool-code-hashes))
    (caller tx-sender)
  )
    ;; Assert caller is an admin and code hash to remove is in the list
    (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (index-of verified-pool-code-hashes-list hash)) ERR_VERIFIED_POOL_CODE_HASH_NOT_IN_LIST)

    ;; Set verified-pool-code-hashes-helper to hash to remove and filter verified-pool-code-hashes to remove hash
    (var-set verified-pool-code-hashes-helper hash)
    (var-set verified-pool-code-hashes (filter verified-pool-code-hashes-not-removable verified-pool-code-hashes-list))

    ;; Print function data and return true
    (print {action: "remove-verified-pool-code-hash", caller: caller, data: {hash: hash}})
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

      ;; Assert that config is greater than 0
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
    (dynamic-config (optional (buff 4096))) (fee-address principal)
    (uri (string-ascii 256)) (status bool)
  )
  (let (
    ;; Gather all pool data and pool contract
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (x-variable-fee (get x-variable-fee pool-data))
    (y-variable-fee (get y-variable-fee pool-data))

    ;; Get pool ID and create pool symbol and name
    (new-pool-id (+ (var-get last-pool-id) u1))
    (symbol (unwrap! (create-symbol x-token-trait y-token-trait) ERR_INVALID_POOL_SYMBOL))
    (name (concat symbol "-LP"))

    ;; Check if pool code hash is verified
    (pool-code-hash 0x)
    (pool-verified-check (is-some (index-of (var-get verified-pool-code-hashes) pool-code-hash)))

    ;; Get token contracts
    (x-token-contract (contract-of x-token-trait))
    (y-token-contract (contract-of y-token-trait))

    ;; Get dynamic config if provided
    (unwrapped-dynamic-config (if (is-some dynamic-config) (unwrap-panic dynamic-config) 0x))

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

      ;; Assert that fee-address is standard principal
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

      ;; Assert that initial price is greater than 0
      (asserts! (> initial-price u0) ERR_INVALID_INITIAL_PRICE)

      ;; Assert that length of pool uri, symbol, and name is greater than 0
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      (asserts! (> (len symbol) u0) ERR_INVALID_POOL_SYMBOL)
      (asserts! (> (len name) u0) ERR_INVALID_POOL_NAME)

      ;; Assert that fees are less than maximum BPS
      (asserts! (< (+ x-protocol-fee x-provider-fee x-variable-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)
      (asserts! (< (+ y-protocol-fee y-provider-fee y-variable-fee) FEE_SCALE_BPS) ERR_INVALID_FEE)

      ;; Assert that bin step is valid
      (asserts! (is-some (index-of (var-get bin-steps) bin-step)) ERR_INVALID_BIN_STEP)

      ;; Assert that bin price is valid at extremes
      (try! (get-bin-price initial-price bin-step MIN_BIN_ID))

      ;; Create pool, set fees, and set variable fees cooldown
      (try! (contract-call? pool-trait create-pool x-token-contract y-token-contract CONTRACT_DEPLOYER fee-address caller 0 bin-step initial-price new-pool-id name symbol uri))
      (try! (contract-call? pool-trait set-x-fees x-protocol-fee x-provider-fee))
      (try! (contract-call? pool-trait set-y-fees y-protocol-fee y-provider-fee))
      (try! (contract-call? pool-trait set-variable-fees-cooldown variable-fees-cooldown))

      ;; Freeze variable fees manager if freeze-variable-fees-manager is true
      (if freeze-variable-fees-manager (try! (contract-call? pool-trait set-freeze-variable-fees-manager)) false)

      ;; Set dynamic config if unwrapped-dynamic-config is greater than 0
      (if (> (len unwrapped-dynamic-config) u0) (try! (contract-call? pool-trait set-dynamic-config unwrapped-dynamic-config)) false)

      ;; Update ID of last created pool, add pool to pools map, and add pool to unclaimed-protocol-fees map
      (var-set last-pool-id new-pool-id)
      (map-set pools new-pool-id {id: new-pool-id, name: name, symbol: symbol, pool-contract: pool-contract, status: status})
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

      ;; Mint burn amount LP tokens to BURN_ADDRESS
      (try! (contract-call? pool-trait pool-mint CENTER_BIN_ID burn-amount-active-bin BURN_ADDRESS))

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
          x-variable-fee: x-variable-fee,
          y-protocol-fee: y-protocol-fee,
          y-provider-fee: y-provider-fee,
          y-variable-fee: y-variable-fee,
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
          freeze-variable-fees-manager: freeze-variable-fees-manager,
          dynamic-config: dynamic-config
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

    ;; Check if both initial bin balances are equal to 0
    (initial-bin-balances-empty (and (is-eq x-balance u0) (is-eq y-balance u0)))

    ;; Get price at bin
    (bin-price (unwrap! (get-bin-price initial-price bin-step bin-id) ERR_INVALID_BIN_PRICE))

    ;; Calculate maximum x-amount with fees
    (swap-fee-total (+ protocol-fee provider-fee variable-fee))
    (max-x-amount (/ (+ (* y-balance PRICE_SCALE_BPS) (- bin-price u1)) bin-price))
    (updated-max-x-amount (if (> swap-fee-total u0) (/ (* max-x-amount FEE_SCALE_BPS) (- FEE_SCALE_BPS swap-fee-total)) max-x-amount))

    ;; Calculate x-amount to use for the swap
    (updated-x-amount (if (>= x-amount updated-max-x-amount) updated-max-x-amount x-amount))

    ;; Calculate fees and dx
    (x-amount-fees-total (/ (* updated-x-amount swap-fee-total) FEE_SCALE_BPS))
    (x-amount-fees-protocol (/ (* updated-x-amount protocol-fee) FEE_SCALE_BPS))
    (x-amount-fees-variable (/ (* updated-x-amount variable-fee) FEE_SCALE_BPS))
    (x-amount-fees-provider (- x-amount-fees-total x-amount-fees-protocol x-amount-fees-variable))
    (dx (- updated-x-amount x-amount-fees-total))

    ;; Calculate dy
    (dy-before-cap (/ (* dx bin-price) PRICE_SCALE_BPS))
    (dy (if (> dy-before-cap y-balance) y-balance dy-before-cap))

    ;; Calculate updated bin balances
    (updated-x-balance (+ x-balance dx x-amount-fees-provider x-amount-fees-variable))
    (updated-y-balance (- y-balance dy))

    ;; Calculate new active bin ID (default to bin-id if at the edge of the bin range)
    (updated-active-bin-id (if (and (or (is-eq updated-y-balance u0) initial-bin-balances-empty) (> bin-id MIN_BIN_ID))
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

      ;; Transfer updated-x-amount x tokens from caller to pool-contract
      (if (not initial-bin-balances-empty)
          (try! (contract-call? x-token-trait transfer updated-x-amount caller pool-contract none))
          false)

      ;; Transfer dy y tokens from pool-contract to caller
      (if (not initial-bin-balances-empty)
          (try! (contract-call? pool-trait pool-transfer y-token-trait dy caller))
          false)

      ;; Update unclaimed-protocol-fees for pool
      (if (> x-amount-fees-protocol u0)
          (map-set unclaimed-protocol-fees pool-id (merge current-unclaimed-protocol-fees {
            x-fee: (+ (get x-fee current-unclaimed-protocol-fees) x-amount-fees-protocol)
          }))
          false)

      ;; Update bin balances
      (if (not initial-bin-balances-empty)
          (try! (contract-call? pool-trait update-bin-balances unsigned-bin-id updated-x-balance updated-y-balance))
          false)

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
          updated-x-amount: updated-x-amount,
          updated-max-x-amount: updated-max-x-amount,
          x-amount-fees-protocol: x-amount-fees-protocol,
          x-amount-fees-provider: x-amount-fees-provider,
          x-amount-fees-variable: x-amount-fees-variable,
          swap-fee-exemption: swap-fee-exemption,
          dx: dx,
          dy: dy,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance,
          initial-bin-balances-empty: initial-bin-balances-empty
        }
      })
      (ok {in: updated-x-amount, out: dy})
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

    ;; Check if both initial bin balances are equal to 0
    (initial-bin-balances-empty (and (is-eq x-balance u0) (is-eq y-balance u0)))

    ;; Get price at bin
    (bin-price (unwrap! (get-bin-price initial-price bin-step bin-id) ERR_INVALID_BIN_PRICE))

    ;; Calculate maximum y-amount with fees
    (swap-fee-total (+ protocol-fee provider-fee variable-fee))
    (max-y-amount (/ (+ (* x-balance bin-price) (- PRICE_SCALE_BPS u1)) PRICE_SCALE_BPS))
    (updated-max-y-amount (if (> swap-fee-total u0) (/ (* max-y-amount FEE_SCALE_BPS) (- FEE_SCALE_BPS swap-fee-total)) max-y-amount))

    ;; Calculate y-amount to use for the swap
    (updated-y-amount (if (>= y-amount updated-max-y-amount) updated-max-y-amount y-amount))

    ;; Calculate fees and dy
    (y-amount-fees-total (/ (* updated-y-amount swap-fee-total) FEE_SCALE_BPS))
    (y-amount-fees-protocol (/ (* updated-y-amount protocol-fee) FEE_SCALE_BPS))
    (y-amount-fees-variable (/ (* updated-y-amount variable-fee) FEE_SCALE_BPS))
    (y-amount-fees-provider (- y-amount-fees-total y-amount-fees-protocol y-amount-fees-variable))
    (dy (- updated-y-amount y-amount-fees-total))

    ;; Calculate dx
    (dx-before-cap (/ (* dy PRICE_SCALE_BPS) bin-price))
    (dx (if (> dx-before-cap x-balance) x-balance dx-before-cap))

    ;; Calculate updated bin balances
    (updated-x-balance (- x-balance dx))
    (updated-y-balance (+ y-balance dy y-amount-fees-provider y-amount-fees-variable))

    ;; Calculate new active bin ID (default to bin-id if at the edge of the bin range)
    (updated-active-bin-id (if (and (or (is-eq updated-x-balance u0) initial-bin-balances-empty) (< bin-id MAX_BIN_ID))
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

      ;; Transfer updated-y-amount y tokens from caller to pool-contract
      (if (not initial-bin-balances-empty)
          (try! (contract-call? y-token-trait transfer updated-y-amount caller pool-contract none))
          false)

      ;; Transfer dx x tokens from pool-contract to caller
      (if (not initial-bin-balances-empty)
          (try! (contract-call? pool-trait pool-transfer x-token-trait dx caller))
          false)

      ;; Update unclaimed-protocol-fees for pool
      (if (> y-amount-fees-protocol u0)
          (map-set unclaimed-protocol-fees pool-id (merge current-unclaimed-protocol-fees {
            y-fee: (+ (get y-fee current-unclaimed-protocol-fees) y-amount-fees-protocol)
          }))
          false)

      ;; Update bin balances
      (if (not initial-bin-balances-empty)
          (try! (contract-call? pool-trait update-bin-balances unsigned-bin-id updated-x-balance updated-y-balance))
          false)

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
          updated-y-amount: updated-y-amount,
          updated-max-y-amount: updated-max-y-amount,
          y-amount-fees-protocol: y-amount-fees-protocol,
          y-amount-fees-provider: y-amount-fees-provider,
          y-amount-fees-variable: y-amount-fees-variable,
          swap-fee-exemption: swap-fee-exemption,
          dy: dy,
          dx: dx,
          updated-x-balance: updated-x-balance,
          updated-y-balance: updated-y-balance,
          initial-bin-balances-empty: initial-bin-balances-empty
        }
      })
      (ok {in: updated-y-amount, out: dx})
    )
  )
)

;; Add liquidity to a bin in a pool
(define-public (add-liquidity
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (bin-id int) (x-amount uint) (y-amount uint) (min-dlp uint)
    (max-x-liquidity-fee uint) (max-y-liquidity-fee uint)
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
    (add-liquidity-fees (if (and (is-eq bin-id active-bin-id) (> dlp u0))
      (let (
        (x-liquidity-fee (+ (get x-protocol-fee pool-data) (get x-provider-fee pool-data) (get x-variable-fee pool-data)))
        (y-liquidity-fee (+ (get y-protocol-fee pool-data) (get y-provider-fee pool-data) (get y-variable-fee pool-data)))

        ;; Calculate withdrawable x-amount without fees
        (x-amount-withdrawable (/ (* dlp (+ x-balance x-amount)) (+ bin-shares dlp)))

        ;; Calculate withdrawable y-amount without fees
        (y-amount-withdrawable (/ (* dlp (+ y-balance y-amount)) (+ bin-shares dlp)))

        ;; Calculate max liquidity fee for x-amount and y-amount
        (max-x-amount-fees-liquidity (if (and (> y-amount-withdrawable y-amount) (> x-amount x-amount-withdrawable))
                                         (/ (* (- x-amount x-amount-withdrawable) x-liquidity-fee) FEE_SCALE_BPS)
                                         u0))
        (max-y-amount-fees-liquidity (if (and (> x-amount-withdrawable x-amount) (> y-amount y-amount-withdrawable))
                                         (/ (* (- y-amount y-amount-withdrawable) y-liquidity-fee) FEE_SCALE_BPS)
                                         u0))
      )
        ;; Calculate final liquidity fee for x-amount and y-amount
        {
          x-amount-fees-liquidity: (if (> x-amount max-x-amount-fees-liquidity) max-x-amount-fees-liquidity x-amount),
          y-amount-fees-liquidity: (if (> y-amount max-y-amount-fees-liquidity) max-y-amount-fees-liquidity y-amount)
        }
      )
      {
        x-amount-fees-liquidity: u0,
        y-amount-fees-liquidity: u0
      })
    )

    ;; Get x-amount-fees-liquidity and y-amount-fees-liquidity
    (x-amount-fees-liquidity (get x-amount-fees-liquidity add-liquidity-fees))
    (y-amount-fees-liquidity (get y-amount-fees-liquidity add-liquidity-fees))

    ;; Calculate final x and y amounts post fees
    (x-amount-post-fees (- x-amount x-amount-fees-liquidity))
    (y-amount-post-fees (- y-amount y-amount-fees-liquidity))
    (y-amount-post-fees-scaled (* y-amount-post-fees PRICE_SCALE_BPS))

    ;; Get final liquidity value and calculate dlp post fees
    (add-liquidity-value-post-fees (unwrap! (get-liquidity-value x-amount-post-fees y-amount-post-fees-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp-post-fees (if (is-eq bin-shares u0)
      (let (
        (intended-dlp (sqrti add-liquidity-value-post-fees))
        (burn-amount (var-get minimum-burnt-shares))
      )
        (asserts! (>= intended-dlp (var-get minimum-bin-shares)) ERR_MINIMUM_LP_AMOUNT)
        (try! (contract-call? pool-trait pool-mint unsigned-bin-id burn-amount BURN_ADDRESS))
        (- intended-dlp burn-amount)
      )
      (if (is-eq bin-liquidity-value u0)
          (sqrti add-liquidity-value-post-fees)
          (/ (* add-liquidity-value-post-fees bin-shares) bin-liquidity-value))))

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

      ;; Assert that x-amount-fees-liquidity is less than or equal to max-x-liquidity-fee
      (asserts! (<= x-amount-fees-liquidity max-x-liquidity-fee) ERR_MAXIMUM_X_LIQUIDITY_FEE)

      ;; Assert that y-amount-fees-liquidity is less than or equal to max-y-liquidity-fee
      (asserts! (<= y-amount-fees-liquidity max-y-liquidity-fee) ERR_MAXIMUM_Y_LIQUIDITY_FEE)

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
          max-x-liquidity-fee: max-x-liquidity-fee,
          max-y-liquidity-fee: max-y-liquidity-fee,
          add-liquidity-value-post-fees: add-liquidity-value-post-fees,
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
    (max-x-liquidity-fee uint) (max-y-liquidity-fee uint)
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
    (add-liquidity-fees (if (and (is-eq to-bin-id active-bin-id) (> dlp u0))
      (let (
        (x-liquidity-fee (+ (get x-protocol-fee pool-data) (get x-provider-fee pool-data) (get x-variable-fee pool-data)))
        (y-liquidity-fee (+ (get y-protocol-fee pool-data) (get y-provider-fee pool-data) (get y-variable-fee pool-data)))

        ;; Calculate withdrawable x-amount without fees
        (x-amount-withdrawable (/ (* dlp (+ x-balance-b x-amount)) (+ bin-shares-b dlp)))

        ;; Calculate withdrawable y-amount without fees
        (y-amount-withdrawable (/ (* dlp (+ y-balance-b y-amount)) (+ bin-shares-b dlp)))

        ;; Calculate max liquidity fee for x-amount and y-amount
        (max-x-amount-fees-liquidity (if (and (> y-amount-withdrawable y-amount) (> x-amount x-amount-withdrawable))
                                         (/ (* (- x-amount x-amount-withdrawable) x-liquidity-fee) FEE_SCALE_BPS)
                                         u0))
        (max-y-amount-fees-liquidity (if (and (> x-amount-withdrawable x-amount) (> y-amount y-amount-withdrawable))
                                         (/ (* (- y-amount y-amount-withdrawable) y-liquidity-fee) FEE_SCALE_BPS)
                                         u0))
      )
        ;; Calculate final liquidity fee for x-amount and y-amount
        {
          x-amount-fees-liquidity: (if (> x-amount max-x-amount-fees-liquidity) max-x-amount-fees-liquidity x-amount),
          y-amount-fees-liquidity: (if (> y-amount max-y-amount-fees-liquidity) max-y-amount-fees-liquidity y-amount)
        }
      )
      {
        x-amount-fees-liquidity: u0,
        y-amount-fees-liquidity: u0
      })
    )

    ;; Get x-amount-fees-liquidity and y-amount-fees-liquidity
    (x-amount-fees-liquidity (get x-amount-fees-liquidity add-liquidity-fees))
    (y-amount-fees-liquidity (get y-amount-fees-liquidity add-liquidity-fees))

    ;; Calculate final x and y amounts post fees for to-bin-id
    (x-amount-post-fees (- x-amount x-amount-fees-liquidity))
    (y-amount-post-fees (- y-amount y-amount-fees-liquidity))
    (y-amount-post-fees-scaled (* y-amount-post-fees PRICE_SCALE_BPS))

    ;; Get final liquidity value for to-bin-id and calculate dlp post fees
    (add-liquidity-value-post-fees (unwrap! (get-liquidity-value x-amount-post-fees y-amount-post-fees-scaled bin-price) ERR_INVALID_LIQUIDITY_VALUE))
    (dlp-post-fees (if (is-eq bin-shares-b u0)
      (let (
        (intended-dlp (sqrti add-liquidity-value-post-fees))
        (burn-amount (var-get minimum-burnt-shares))
      )
        (asserts! (>= intended-dlp (var-get minimum-bin-shares)) ERR_MINIMUM_LP_AMOUNT)
        (try! (contract-call? pool-trait pool-mint unsigned-to-bin-id burn-amount BURN_ADDRESS))
        (- intended-dlp burn-amount)
      )
      (if (is-eq bin-liquidity-value u0)
          (sqrti add-liquidity-value-post-fees)
          (/ (* add-liquidity-value-post-fees bin-shares-b) bin-liquidity-value))))

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

      ;; Assert that x-amount-fees-liquidity is less than or equal to max-x-liquidity-fee
      (asserts! (<= x-amount-fees-liquidity max-x-liquidity-fee) ERR_MAXIMUM_X_LIQUIDITY_FEE)

      ;; Assert that y-amount-fees-liquidity is less than or equal to max-y-liquidity-fee
      (asserts! (<= y-amount-fees-liquidity max-y-liquidity-fee) ERR_MAXIMUM_Y_LIQUIDITY_FEE)

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
          max-x-liquidity-fee: max-x-liquidity-fee,
          max-y-liquidity-fee: max-y-liquidity-fee,
          add-liquidity-value-post-fees: add-liquidity-value-post-fees,
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

;; Helper function for removing a verified pool code hash
(define-private (verified-pool-code-hashes-not-removable (hash (buff 32)))
  (not (is-eq hash (var-get verified-pool-code-hashes-helper)))
)

;; Helper function to validate that bin-factors list is in ascending order
(define-private (fold-are-bin-factors-ascending (factor uint) (result (response uint uint)))
  (if (> factor (try! result))
      (ok factor)
      ERR_UNSORTED_BIN_FACTORS_LIST)
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