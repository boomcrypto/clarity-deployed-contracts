
;; good-cyan-marten

;; Implement DLMM pool trait, SIP 013 traits, and use SIP 010 trait
(impl-trait .amused-teal-basilisk.dlmm-pool-trait)
(impl-trait 'SPDBEG5X8XD50SPM1JJH0E5CTXGDV5NJTKAKKR5V.sip013-semi-fungible-token-trait.sip013-semi-fungible-token-trait)
(impl-trait 'SPDBEG5X8XD50SPM1JJH0E5CTXGDV5NJTKAKKR5V.sip013-transfer-many-trait.sip013-transfer-many-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Define semi-fungible pool token
(define-fungible-token pool-token)
(define-non-fungible-token pool-token-id {token-id: uint, owner: principal})

;; Error constants
(define-constant ERR_NOT_AUTHORIZED_SIP_013 (err u4))
(define-constant ERR_INVALID_AMOUNT_SIP_013 (err u1))
(define-constant ERR_INVALID_PRINCIPAL_SIP_013 (err u5))
(define-constant ERR_NOT_AUTHORIZED (err u3001))
(define-constant ERR_INVALID_AMOUNT (err u3002))
(define-constant ERR_INVALID_PRINCIPAL (err u3003))
(define-constant ERR_NOT_POOL_CONTRACT_DEPLOYER (err u3004))
(define-constant ERR_MAX_NUMBER_OF_BINS (err u3005))

;; DLMM Core address and contract deployer address
(define-constant CORE_ADDRESS .statutory-apricot-mule)
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Define all pool data vars and maps
(define-data-var pool-id uint u0)
(define-data-var pool-name (string-ascii 32) "")
(define-data-var pool-symbol (string-ascii 32) "")
(define-data-var pool-uri (string-ascii 256) "")

(define-data-var pool-created bool false)
(define-data-var creation-height uint u0)

(define-data-var variable-fees-manager principal tx-sender)

(define-data-var fee-address principal tx-sender)

(define-data-var x-token principal tx-sender)
(define-data-var y-token principal tx-sender)

(define-data-var bin-step uint u0)

(define-data-var initial-price uint u0)

(define-data-var active-bin-id uint u0)

(define-data-var x-protocol-fee uint u0)
(define-data-var x-provider-fee uint u0)
(define-data-var x-variable-fee uint u0)

(define-data-var y-protocol-fee uint u0)
(define-data-var y-provider-fee uint u0)
(define-data-var y-variable-fee uint u0)

(define-data-var bin-change-count uint u0)

(define-data-var last-variable-fees-update uint u0)
(define-data-var variable-fees-cooldown uint u0)

(define-data-var freeze-variable-fees-manager bool false)

(define-map balances-at-bin uint {x-balance: uint, y-balance: uint, bin-shares: uint})

(define-map user-balance-at-bin {id: uint, user: principal} uint)

(define-map user-bins principal (list 1001 uint))

;; Get token name
(define-read-only (get-name)
  (ok (var-get pool-name))
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok (var-get pool-symbol))
)

;; Get token decimals
(define-read-only (get-decimals (token-id uint))
  (ok u6)
)

;; SIP 013 function to get token uri
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get pool-uri)))
)

;; SIP 013 function to get total token supply by ID
(define-read-only (get-total-supply (token-id uint))
  (ok (default-to u0 (get bin-shares (map-get? balances-at-bin token-id))))
)

;; SIP 013 function to get overall token supply
(define-read-only (get-overall-supply)
  (ok (ft-get-supply pool-token))
)

;; SIP 013 function to get token balance for an user by ID
(define-read-only (get-balance (token-id uint) (user principal))
  (ok (get-balance-or-default token-id user))
)

;; SIP 013 function to get overall token balance for an user
(define-read-only (get-overall-balance (user principal))
  (ok (ft-get-balance pool-token user))
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
    core-address: CORE_ADDRESS,
    variable-fees-manager: (var-get variable-fees-manager),
    fee-address: (var-get fee-address),
    x-token: (var-get x-token),
    y-token: (var-get y-token),
    pool-token: (as-contract tx-sender),
    bin-step: (var-get bin-step),
    initial-price: (var-get initial-price),
    active-bin-id: (var-get active-bin-id),
    x-protocol-fee: (var-get x-protocol-fee),
    x-provider-fee: (var-get x-provider-fee),
    x-variable-fee: (var-get x-variable-fee),
    y-protocol-fee: (var-get y-protocol-fee),
    y-provider-fee: (var-get y-provider-fee),
    y-variable-fee: (var-get y-variable-fee),
    bin-change-count: (var-get bin-change-count),
    last-variable-fees-update: (var-get last-variable-fees-update),
    variable-fees-cooldown: (var-get variable-fees-cooldown),
    freeze-variable-fees-manager: (var-get freeze-variable-fees-manager)
  })
)

;; Get balance data at a bin
(define-read-only (get-bin-balances (id uint))
  (ok (default-to {x-balance: u0, y-balance: u0, bin-shares: u0} (map-get? balances-at-bin id)))
)

;; Get a list of bins a user has a position in
(define-read-only (get-user-bins (user principal))
  (ok (default-to (list ) (map-get? user-bins user)))
)

;; Set pool uri via DLMM Core
(define-public (set-pool-uri (uri (string-ascii 256)))
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

;; Set variable fees manager via DLMM Core
(define-public (set-variable-fees-manager (manager principal))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set variable-fees-manager manager)
      (ok true)
    )
  )
)

;; Set fee address via DLMM Core
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

;; Set active bin ID via DLMM Core
(define-public (set-active-bin-id (id uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set active-bin-id id)
      (var-set bin-change-count (+ (var-get bin-change-count) u1))
      (ok true)
    )
  )
)

;; Set x fees via DLMM Core
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

;; Set y fees via DLMM Core
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

;; Set variable fees via DLMM Core
(define-public (set-variable-fees (x-fee uint) (y-fee uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set x-variable-fee x-fee)
      (var-set y-variable-fee y-fee)
      (var-set bin-change-count u0)
      (var-set last-variable-fees-update stacks-block-height)
      (ok true)
    )
  )
)

;; Set variable fees cooldown via DLMM Core
(define-public (set-variable-fees-cooldown (cooldown uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set variable-fees-cooldown cooldown)
      (ok true)
    )
  )
)

;; Set freeze variable fees manager via DLMM Core
(define-public (set-freeze-variable-fees-manager)
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting var
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (var-set freeze-variable-fees-manager true)
      (ok true)
    )
  )
)

;; Update bin balances via DLMM Core
(define-public (update-bin-balances (bin-id uint) (x-balance uint) (y-balance uint))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before setting vars
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
      (map-set balances-at-bin bin-id (merge (unwrap-panic (get-bin-balances bin-id)) {x-balance: x-balance, y-balance: y-balance}))

      ;; Print function data and return true
      (print {action: "update-bin-balances", data: {bin-id: bin-id, x-balance: x-balance, y-balance: y-balance}})
      (ok true)
    )
  )
)

;; SIP 013 transfer function that transfers pool token
(define-public (transfer (token-id uint) (amount uint) (sender principal) (recipient principal))
	(let (
		(sender-balance (get-balance-or-default token-id sender))
    (caller tx-sender)
	)
    (begin
      ;; Assert that caller is sender and sender is not recipient
      (asserts! (is-eq caller sender) ERR_NOT_AUTHORIZED_SIP_013)
      (asserts! (not (is-eq sender recipient)) ERR_INVALID_PRINCIPAL_SIP_013)

      ;; Assert that addresses are standard principals and amount is valid
      (asserts! (is-standard sender) ERR_INVALID_PRINCIPAL_SIP_013)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL_SIP_013)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT_SIP_013)
      (asserts! (<= amount sender-balance) ERR_INVALID_AMOUNT_SIP_013)

      ;; Try to transfer pool token
      (try! (ft-transfer? pool-token amount sender recipient))

      ;; Try to tag pool token and update balances
      (try! (tag-pool-token-id {token-id: token-id, owner: sender}))
      (try! (tag-pool-token-id {token-id: token-id, owner: recipient}))
      (try! (update-user-balance token-id sender (- sender-balance amount)))
      (try! (update-user-balance token-id recipient (+ (get-balance-or-default token-id recipient) amount)))

      ;; Print SIP 013 data, function data, and return true
      (print {type: "sft_transfer", token-id: token-id, amount: amount, sender: sender, recipient: recipient})
      (print {action: "transfer", caller: caller, data: { id: token-id, sender: sender, recipient: recipient, amount: amount}})
      (ok true)
    )
  )
)

;; SIP 013 transfer function that transfers pool token with memo
(define-public (transfer-memo (token-id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
	(begin
		(try! (transfer token-id amount sender recipient))
		(print memo)
		(ok true)
  )
)

;; SIP 013 transfer function that transfers many pool token
(define-public (transfer-many (transfers (list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal})))
	(fold fold-transfer-many transfers (ok true))
)

;; SIP 013 transfer function that transfers many pool token with memo
(define-public (transfer-many-memo (transfers (list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)})))
	(fold fold-transfer-many-memo transfers (ok true))
)

;; Transfer tokens from this pool contract via DLMM Core
(define-public (pool-transfer (token-trait <sip-010-trait>) (amount uint) (recipient principal))
  (let (
    (token-contract (contract-of token-trait))
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before transferring tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that recipient address is standard principal
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

;; Mint pool token to an user via DLMM Core
(define-public (pool-mint (id uint) (amount uint) (user principal))
  (let (
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before minting tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that user is standard principal and amount is greater than 0
      (asserts! (is-standard user) ERR_INVALID_PRINCIPAL)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Try to mint amount pool tokens to user
      (try! (ft-mint? pool-token amount user))

      ;; Try to tag pool token and update balances
      (try! (tag-pool-token-id {token-id: id, owner: user}))
      (try! (update-user-balance id user (+ (get-balance-or-default id user) amount)))
      (map-set balances-at-bin id (merge (unwrap-panic (get-bin-balances id)) {bin-shares: (+ (unwrap-panic (get-total-supply id)) amount)}))
      
      ;; Print SIP 013 data, function data, and return true
      (print {type: "sft_mint", token-id: id, amount: amount, recipient: user})
      (print {action: "pool-mint", data: {id: id, amount: amount, user: user}})
      (ok true)
    )
  )
)

;; Burn pool token from an user via DLMM Core
(define-public (pool-burn (id uint) (amount uint) (user principal))
  (let (
    (user-balance (get-balance-or-default id user))
    (caller contract-caller)
  )
    (begin
      ;; Assert that caller is core address before burning tokens
      (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)

      ;; Assert that user is standard principal and amount is valid
      (asserts! (is-standard user) ERR_INVALID_PRINCIPAL)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (<= amount user-balance) ERR_INVALID_AMOUNT)

      ;; Try to burn amount pool tokens from user
      (try! (ft-burn? pool-token amount user))

      ;; Try to tag pool token and update balances
      (try! (tag-pool-token-id {token-id: id, owner: user}))
      (try! (update-user-balance id user (- user-balance amount)))
      (map-set balances-at-bin id (merge (unwrap-panic (get-bin-balances id)) {bin-shares: (- (unwrap-panic (get-total-supply id)) amount)}))
      
      ;; Print SIP 013 data, function data, and return true
      (print {type: "sft_burn", token-id: id, amount: amount, sender: user})
      (print {action: "pool-burn", data: {id: id, amount: amount, user: user}})
      (ok true)
    )
  )
)

;; Create pool using this pool contract via DLMM Core
(define-public (create-pool
    (x-token-contract principal) (y-token-contract principal)
    (variable-fees-mgr principal) (fee-addr principal) (core-caller principal)
    (active-bin uint) (step uint) (price uint)
    (id uint) (name (string-ascii 32)) (symbol (string-ascii 32)) (uri (string-ascii 256))
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
      (var-set x-token x-token-contract)
      (var-set y-token y-token-contract)
      (var-set active-bin-id active-bin)
      (var-set bin-step step)
      (var-set initial-price price)
      (var-set variable-fees-manager variable-fees-mgr)
      (var-set fee-address fee-addr)
      (ok true)
    )
  )
)

;; Helper function to transfer many pool token
(define-private (fold-transfer-many (item {token-id: uint, amount: uint, sender: principal, recipient: principal}) (previous-response (response bool uint)))
	(match previous-response prev-ok (transfer-memo (get token-id item) (get amount item) (get sender item) (get recipient item) 0x) prev-err previous-response)
)

;; Helper function to transfer many pool token with memo
(define-private (fold-transfer-many-memo (item {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)}) (previous-response (response bool uint)))
	(match previous-response prev-ok (transfer-memo (get token-id item) (get amount item) (get sender item) (get recipient item) (get memo item)) prev-err previous-response)
)

;; Helper function to get token balance for an user by ID
(define-private (get-balance-or-default (id uint) (user principal))
	(default-to u0 (map-get? user-balance-at-bin {id: id, user: user}))
)

;; Update user balances via pool
(define-private (update-user-balance (id uint) (user principal) (balance uint))
  (let (
		(user-bins-data (unwrap-panic (get-user-bins user)))
	)
    (begin
      (match (index-of? user-bins-data id) id-index
        (and
          (is-eq balance u0)
          (map-set user-bins user (unwrap-panic (as-max-len? (concat (unwrap-panic (slice? user-bins-data u0 id-index)) (default-to (list) (slice? user-bins-data (+ id-index u1) (len user-bins-data)))) u1001)))
        )
        (and
          (> balance u0)
          (map-set user-bins user (unwrap! (as-max-len? (append user-bins-data id) u1001) ERR_MAX_NUMBER_OF_BINS))
        )
      )
      (map-set user-balance-at-bin {id: id, user: user} balance)
      (ok true)
    )
  )
)

;; Tag pool token
(define-private (tag-pool-token-id (id {token-id: uint, owner: principal}))
	(begin
		(and (is-some (nft-get-owner? pool-token-id id)) (try! (nft-burn? pool-token-id id (get owner id))))
		(nft-mint? pool-token-id id (get owner id))
  )
)