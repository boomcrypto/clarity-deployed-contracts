
;; xyk-pool-stx-duke-v-1-1

;; Implement XYK pool trait and use SIP 010 trait
(impl-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Define fungible pool token
(define-fungible-token pool-token)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED_SIP_010 (err u4))
(define-constant ERR_INVALID_PRINCIPAL_SIP_010 (err u5))
(define-constant ERR_NOT_AUTHORIZED (err u3001))
(define-constant ERR_INVALID_AMOUNT (err u3002))
(define-constant ERR_INVALID_PRINCIPAL (err u3003))
(define-constant ERR_POOL_NOT_CREATED (err u3004))
(define-constant ERR_POOL_DISABLED (err u3005))
(define-constant ERR_NOT_POOL_CONTRACT_DEPLOYER (err u3006))

;; XYK Core address and contract deployer address
(define-constant CORE_ADDRESS 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2)
(define-constant CONTRACT_DEPLOYER 'SPVXNRDM0BF03DD70WZ285925S3A20NC86VYFB9A.duke-stxcity-dex)

;; Define all pool data vars
(define-data-var pool-id uint u0)
(define-data-var pool-name (string-ascii 32) "")
(define-data-var pool-symbol (string-ascii 32) "")
(define-data-var pool-uri (string-utf8 256) u"")

(define-data-var pool-created bool false)
(define-data-var creation-height uint u0)

(define-data-var pool-status bool false)

(define-data-var fee-address principal tx-sender)

(define-data-var x-token principal tx-sender)
(define-data-var y-token principal tx-sender)

(define-data-var x-balance uint u0)
(define-data-var y-balance uint u0)

(define-data-var x-protocol-fee uint u0)
(define-data-var x-provider-fee uint u0)

(define-data-var y-protocol-fee uint u0)
(define-data-var y-provider-fee uint u0)

;; SIP 010 function to get token name
(define-read-only (get-name)
  (ok (var-get pool-name))
)

;; SIP 010 function to get token symbol
(define-read-only (get-symbol)
  (ok (var-get pool-symbol))
)

;; SIP 010 function to get token decimals
(define-read-only (get-decimals)
  (ok u6)
)

;; SIP 010 function to get token uri
(define-read-only (get-token-uri)
  (ok (some (var-get pool-uri)))
)

;; SIP 010 function to get total token supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply pool-token))
)

;; SIP 010 function to get token balance for an address
(define-read-only (get-balance (address principal))
  (ok (ft-get-balance pool-token address))
)

;; Get all pool data
(define-read-only (get-pool)
  (ok {
    pool-id: (var-get pool-id),
    pool-name: (var-get pool-name),
    pool-symbol: (var-get pool-symbol),
    pool-uri: (var-get pool-uri),
    pool-created: (var-get pool-created),
    creation-height: (var-get creation-height),
    pool-status: (var-get pool-status),
    core-address: CORE_ADDRESS,
    fee-address: (var-get fee-address),
    x-token: (var-get x-token),
    y-token: (var-get y-token),
    pool-token: (as-contract tx-sender),
    x-balance: (var-get x-balance),
    y-balance: (var-get y-balance),
    total-shares: (ft-get-supply pool-token),
    x-protocol-fee: (var-get x-protocol-fee),
    x-provider-fee: (var-get x-provider-fee),
    y-protocol-fee: (var-get y-protocol-fee),
    y-provider-fee: (var-get y-provider-fee)
  })
)

;; Set pool uri via XYK Core
(define-public (set-pool-uri (uri (string-utf8 256)))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set pool-uri uri)
      (ok true)
    )
  )
)

;; Set pool status via XYK Core
(define-public (set-pool-status (status bool))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set pool-status status)
      (ok true)
    )
  )
)

;; Set fee address via XYK Core
(define-public (set-fee-address (address principal))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set fee-address address)
      (ok true)
    )
  )
)

;; Set x fees via XYK Core
(define-public (set-x-fees (protocol-fee uint) (provider-fee uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set x-protocol-fee protocol-fee)
      (var-set x-provider-fee provider-fee)
      (ok true)
    )
  )
)

;; Set y fees via XYK Core
(define-public (set-y-fees (protocol-fee uint) (provider-fee uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set y-protocol-fee protocol-fee)
      (var-set y-provider-fee provider-fee)
      (ok true)
    )
  )
)

;; Update pool balances and d value via XYK Core
(define-public (update-pool-balances (x-bal uint) (y-bal uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set x-balance x-bal)
      (var-set y-balance y-bal)

      ;; Print function data and return true
      (print {action: "update-pool-balances", data: {x-balance: x-bal, y-balance: y-bal}})
      (ok true)
    )
  )
)

;; SIP 010 transfer function that transfers pool token
(define-public (transfer
    (amount uint)
    (sender principal) (recipient principal)
    (memo (optional (buff 34)))
  )
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert that caller is sender and addresses are standard principals
      (asserts! (is-eq caller sender) ERR_NOT_AUTHORIZED_SIP_010)
      (asserts! (is-standard sender) ERR_INVALID_PRINCIPAL_SIP_010)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL_SIP_010)
      
      ;; Try performing a pool token transfer and print memo
      (try! (ft-transfer? pool-token amount sender recipient))
      (match memo to-print (print to-print) 0x)
      
      ;; Print function data and return true
      (print {
        action: "transfer",
        caller: caller,
        data: {
          sender: sender,
          recipient: recipient,
          amount: amount,
          memo: memo
        }
      })
      (ok true)
    )
  )
)

;; Transfer tokens from this pool contract via XYK Core
(define-public (pool-transfer (token-trait <sip-010-trait>) (amount uint) (recipient principal))
  (let (
    (token-contract (contract-of token-trait))
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before transferring tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that token and recipient addresses are standard principals
      (asserts! (is-standard token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Try to transfer amount of token from pool contract to recipient
      (try! (as-contract (contract-call? token-trait transfer amount tx-sender recipient none)))
      
      ;; Print function data and return true
      (print {action: "pool-transfer", data: {token: token-contract, amount: amount, recipient: recipient}})
      (ok true)
    )
  )
)

;; Mint pool token to an address via XYK Core
(define-public (pool-mint (amount uint) (address principal))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before minting tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that address is standard principal and amount is greater than 0
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Try to mint amount pool tokens to address
      (try! (ft-mint? pool-token amount address))
      
      ;; Print function data and return true
      (print {action: "pool-mint", data: {amount: amount, address: address}})
      (ok true)
    )
  )
)

;; Burn pool token from an address via XYK Core
(define-public (pool-burn (amount uint) (address principal))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before burning tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that address is standard principal and amount is greater than 0
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Try to burn amount pool tokens from address
      (try! (ft-burn? pool-token amount address))
      
      ;; Print function data and return true
      (print {action: "pool-burn", data: {amount: amount, address: address}})
      (ok true)
    )
  )
)

;; Create pool using this pool contract via XYK Core
(define-public (create-pool
    (x-token-contract principal) (y-token-contract principal)
    (fee-addr principal) (core-caller principal)
    (id uint)
    (name (string-ascii 32)) (symbol (string-ascii 32))
    (uri (string-utf8 256))
    (status bool)
  )
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address and core caller is contract deployer before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq core-caller CONTRACT_DEPLOYER) ERR_NOT_POOL_CONTRACT_DEPLOYER)
      (var-set pool-id id)
      (var-set pool-name name)
      (var-set pool-symbol symbol)
      (var-set pool-uri uri)
      (var-set pool-created true)
      (var-set creation-height burn-block-height)
      (var-set pool-status status)
      (var-set x-token x-token-contract)
      (var-set y-token y-token-contract)
      (var-set fee-address fee-addr)
      (ok true)
    )
  )
)
