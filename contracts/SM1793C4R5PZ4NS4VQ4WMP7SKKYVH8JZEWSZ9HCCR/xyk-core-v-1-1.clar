
;; xyk-core-v-1-1

(use-trait xyk-pool-trait .xyk-pool-trait-v-1-1.xyk-pool-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_NO_POOL_DATA (err u3001))
(define-constant ERR_POOL_NOT_CREATED (err u3002))
(define-constant ERR_POOL_DISABLED (err u3003))
(define-constant ERR_POOL_ALREADY_CREATED (err u3004))
(define-constant ERR_INVALID_POOL (err u3005))
(define-constant ERR_INVALID_POOL_URI (err u3006))
(define-constant ERR_INVALID_POOL_SYMBOL (err u3007))
(define-constant ERR_INVALID_TOKEN_SYMBOL (err u3009))
(define-constant ERR_MATCHING_TOKEN_CONTRACTS (err u3010))
(define-constant ERR_INVALID_X_TOKEN (err u3011))
(define-constant ERR_INVALID_Y_TOKEN (err u3012))
(define-constant ERR_MINIMUM_X_AMOUNT (err u3013))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u3014))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u3015))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant BPS u10000)
(define-constant MINIMUM_SHARES u1000000)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var last-pool-id uint u0)

(define-data-var public-pool-creation bool false)

(define-map pools uint {
  id: uint,
  name: (string-ascii 256),
  symbol: (string-ascii 256),
  pool-contract: principal
})

(define-read-only (get-admins)
  (ok (var-get admins))
)

(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

(define-read-only (get-last-pool-id)
  (ok (var-get last-pool-id))
)

(define-read-only (get-public-pool-creation)
  (ok (var-get public-pool-creation))
)

(define-read-only (get-pool-by-id (id uint))
  (ok (map-get? pools id))
)

(define-public (set-public-pool-creation (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (var-set public-pool-creation status)
      (print {action: "set-public-pool-creation", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-pool-uri (pool-trait <xyk-pool-trait>) (uri (string-utf8 256)))
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      (try! (as-contract (contract-call? pool-trait set-pool-uri uri)))
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

(define-public (set-pool-status (pool-trait <xyk-pool-trait>) (status bool))
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      (try! (as-contract (contract-call? pool-trait set-pool-status status)))
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

(define-public (set-fee-address (pool-trait <xyk-pool-trait>) (address principal))
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      (try! (as-contract (contract-call? pool-trait set-fee-address address)))
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

(define-public (set-x-fees (pool-trait <xyk-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      (try! (as-contract (contract-call? pool-trait set-x-fees protocol-fee provider-fee)))
      (print {
        action: "set-x-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          protocol-fee: protocol-fee,
          provider-fee: provider-fee
        }
      })
      (ok true)
    )
  )
)

(define-public (set-y-fees (pool-trait <xyk-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      (try! (as-contract (contract-call? pool-trait set-y-fees protocol-fee provider-fee)))
      (print {
        action: "set-y-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          protocol-fee: protocol-fee,
          provider-fee: provider-fee
        }
      })
      (ok true)
    )
  )
)

(define-public (create-pool 
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint)
    (x-protocol-fee uint) (x-provider-fee uint)
    (y-protocol-fee uint) (y-provider-fee uint)
    (fee-address principal) (uri (string-utf8 256)) (status bool)
  )
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (new-pool-id (+ (var-get last-pool-id) u1))
    (symbol (unwrap! (create-symbol x-token-trait y-token-trait) ERR_INVALID_POOL_SYMBOL))
    (name (concat symbol "-LP"))
    (x-token-contract (contract-of x-token-trait))
    (y-token-contract (contract-of y-token-trait))
    (total-shares (sqrti (* x-amount y-amount)))
    (caller tx-sender)
  )
    (begin
      (asserts! (or (is-some (index-of (var-get admins) caller)) (var-get public-pool-creation)) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get pool-created pool-data) false) ERR_POOL_ALREADY_CREATED)
      (asserts! (not (is-eq x-token-contract y-token-contract)) ERR_MATCHING_TOKEN_CONTRACTS)
      (asserts! (is-standard x-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard y-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)
      (asserts! (> x-amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> y-amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> total-shares MINIMUM_SHARES) ERR_MINIMUM_LP_AMOUNT)
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      (try! (as-contract (contract-call? pool-trait create-pool x-token-contract y-token-contract fee-address new-pool-id name symbol uri status)))
      (try! (as-contract (contract-call? pool-trait set-x-fees x-protocol-fee x-provider-fee)))
      (try! (as-contract (contract-call? pool-trait set-y-fees y-protocol-fee y-provider-fee)))
      (var-set last-pool-id new-pool-id)
      (map-set pools new-pool-id {id: new-pool-id, name: name, symbol: symbol, pool-contract: pool-contract})
      (try! (contract-call? x-token-trait transfer x-amount caller pool-contract none))
      (try! (contract-call? y-token-trait transfer y-amount caller pool-contract none))
      (try! (as-contract (contract-call? pool-trait update-pool-balances x-amount y-amount)))
      (try! (as-contract (contract-call? pool-trait pool-mint (- total-shares MINIMUM_SHARES) caller)))
      (try! (as-contract (contract-call? pool-trait pool-mint MINIMUM_SHARES pool-contract)))
      (print {
        action: "create-pool",
        caller: caller,
        data: {
          pool-id: new-pool-id,
          pool-name: name,
          pool-contract: pool-contract,
          x-token: x-token-contract,
          y-token: y-token-contract,
          x-protocol-fee: x-protocol-fee,
          x-provider-fee: x-provider-fee,
          y-protocol-fee: y-protocol-fee,
          y-provider-fee: y-provider-fee,
          x-amount: x-amount,
          y-amount: y-amount,
          total-shares: total-shares,
          pool-symbol: symbol,
          pool-uri: uri,
          pool-status: status,
          creation-height: burn-block-height,
          fee-address: fee-address
        }
      })
      (ok true)
    )
  )
)

(define-public (swap-x-for-y
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (min-dy uint)
  )
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))
    (x-amount-fees-protocol (/ (* x-amount protocol-fee) BPS))
    (x-amount-fees-provider (/ (* x-amount provider-fee) BPS))
    (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider))
    (dx (- x-amount x-amount-fees-total))
    (updated-x-balance (+ x-balance dx))
    (dy (/ ( * y-balance dx) (+ updated-x-balance)))
    (updated-y-balance ( - y-balance dy))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
      (asserts! (> x-amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> min-dy u0) ERR_INVALID_AMOUNT)
      (asserts! (>= dy min-dy) ERR_MINIMUM_Y_AMOUNT)
      (try! (contract-call? x-token-trait transfer (+ dx x-amount-fees-provider) caller pool-contract none))
      (try! (as-contract (contract-call? pool-trait pool-transfer y-token-trait dy caller)))
      (if (> x-amount-fees-protocol u0)
        (try! (contract-call? x-token-trait transfer x-amount-fees-protocol caller fee-address none))
        false
      )
      (try! (as-contract (contract-call? pool-trait update-pool-balances (+ updated-x-balance x-amount-fees-provider) updated-y-balance)))
      (print {
        action: "swap-x-for-y",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          x-amount: x-amount,
          x-amount-fees-protocol: x-amount-fees-protocol,
          x-amount-fees-provider: x-amount-fees-provider,
          dy: dy,
          min-dy: min-dy
        }
      })
      (ok dy)
    )
  )
)

(define-public (swap-y-for-x
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint) (min-dx uint)
  )
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get y-protocol-fee pool-data))
    (provider-fee (get y-provider-fee pool-data))
    (y-amount-fees-protocol (/ (* y-amount protocol-fee) BPS))
    (y-amount-fees-provider (/ (* y-amount provider-fee) BPS))
    (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider))
    (dy (- y-amount y-amount-fees-total))
    (updated-y-balance (+ y-balance dy))
    (dx (/ ( * x-balance dy) (+ updated-y-balance)))
    (updated-x-balance ( - x-balance dx))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
      (asserts! (> y-amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> min-dx u0) ERR_INVALID_AMOUNT)
      (asserts! (>= dx min-dx) ERR_MINIMUM_X_AMOUNT)
      (try! (contract-call? y-token-trait transfer (+ dy y-amount-fees-provider) caller pool-contract none))
      (try! (as-contract (contract-call? pool-trait pool-transfer x-token-trait dx caller)))
      (if (> y-amount-fees-protocol u0)
        (try! (contract-call? y-token-trait transfer y-amount-fees-protocol caller fee-address none))
        false
      )
      (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance (+ updated-y-balance y-amount-fees-provider))))
      (print {
        action: "swap-y-for-x",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          y-amount: y-amount,
          y-amount-fees-protocol: y-amount-fees-protocol,
          y-amount-fees-provider: y-amount-fees-provider,
          dx: dx,
          min-dx: min-dx
        }
      })
      (ok dx)
    )
  )
)

(define-public (add-liquidity
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (min-dlp uint)
  )
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (total-shares (get total-shares pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (y-amount (/ (* x-amount y-balance) x-balance))
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))
    (dlp (/ (* x-amount total-shares) x-balance))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
      (asserts! (> x-amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> min-dlp u0) ERR_INVALID_AMOUNT)
      (asserts! (> y-amount u0) ERR_MINIMUM_Y_AMOUNT)
      (asserts! (>= dlp min-dlp) ERR_MINIMUM_LP_AMOUNT)
      (try! (contract-call? x-token-trait transfer x-amount caller pool-contract none))
      (try! (contract-call? y-token-trait transfer y-amount caller pool-contract none))
      (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance updated-y-balance)))
      (try! (as-contract (contract-call? pool-trait pool-mint dlp caller)))
      (print {
        action: "add-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          x-amount: x-amount,
          y-amount: y-amount,
          dlp: dlp,
          min-dlp: min-dlp
        }
      })
      (ok dlp)
    )
  )
)

(define-public (withdraw-liquidity
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (amount uint) (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))
    (x-amount (/ (* amount x-balance) total-shares))
    (y-amount (/ (* amount y-balance) total-shares))
    (updated-x-balance (- x-balance x-amount))
    (updated-y-balance (- y-balance y-amount))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)
      (asserts! (>= x-amount min-x-amount) ERR_MINIMUM_X_AMOUNT)
      (asserts! (>= y-amount min-y-amount) ERR_MINIMUM_Y_AMOUNT)
      (if (> x-amount u0)
        (try! (as-contract (contract-call? pool-trait pool-transfer x-token-trait x-amount caller)))
        false
      )
      (if (> y-amount u0)
        (try! (as-contract (contract-call? pool-trait pool-transfer y-token-trait y-amount caller)))
        false
      )
      (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance updated-y-balance)))
      (try! (as-contract (contract-call? pool-trait pool-burn amount caller)))
      (print {
        action: "withdraw-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          x-token: x-token,
          y-token: y-token,
          amount: amount,
          x-amount: x-amount,
          y-amount: y-amount,
          min-x-amount: min-x-amount,
          min-y-amount: min-y-amount
        }
      })
      (ok {x-amount: x-amount, y-amount: y-amount})
    )
  )
)

(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller-in-list (index-of admins-list tx-sender))
    (admin-to-remove-in-list (index-of admins-list admin))
    (caller tx-sender)
  )
    (asserts! (is-some caller-in-list) ERR_NOT_AUTHORIZED)
    (asserts! (is-some admin-to-remove-in-list) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removeable admins-list))
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (set-pool-uri-multi
    (pool-traits (list 120 <xyk-pool-trait>))
    (uris (list 120 (string-utf8 256)))
  )
  (ok (map set-pool-uri pool-traits uris))
)

(define-public (set-pool-status-multi
    (pool-traits (list 120 <xyk-pool-trait>))
    (statuses (list 120 bool))
  )
  (ok (map set-pool-status pool-traits statuses))
)

(define-public (set-fee-address-multi
    (pool-traits (list 120 <xyk-pool-trait>))
    (addresses (list 120 principal))
  )
  (ok (map set-fee-address pool-traits addresses))
)

(define-public (set-x-fees-multi
    (pool-traits (list 120 <xyk-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
  )
  (ok (map set-x-fees pool-traits protocol-fees provider-fees))
)

(define-public (set-y-fees-multi
    (pool-traits (list 120 <xyk-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
  )
  (ok (map set-y-fees pool-traits protocol-fees provider-fees))
)

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (create-symbol (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
  (let (
    (x-symbol (unwrap! (contract-call? x-token-trait get-symbol) ERR_INVALID_TOKEN_SYMBOL))
    (y-symbol (unwrap! (contract-call? y-token-trait get-symbol) ERR_INVALID_TOKEN_SYMBOL))
  )
    (ok (concat x-symbol (concat "-" y-symbol)))
  )
)

(define-private (is-valid-pool (id uint) (contract principal))
  (let (
    (pool-data (unwrap! (map-get? pools id) false))
  )
    (is-eq contract (get pool-contract pool-data))
  )
)
