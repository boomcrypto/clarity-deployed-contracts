---
title: "Trait stableswap-pool-aeusdc-usdh-v-1-1"
draft: true
---
```

;; stableswap-pool-aeusdc-usdh-v-1-1

(impl-trait .stableswap-pool-trait-v-1-1.stableswap-pool-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-fungible-token pool-token)

(define-constant ERR_NOT_AUTHORIZED_SIP_010 (err u4))
(define-constant ERR_INVALID_PRINCIPAL_SIP_010 (err u5))
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_POOL_NOT_CREATED (err u3002))
(define-constant ERR_POOL_DISABLED (err u3003))

(define-constant CORE_ADDRESS .stableswap-core-v-1-1)

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

(define-data-var d uint u0)

(define-data-var x-protocol-fee uint u0)
(define-data-var x-provider-fee uint u0)

(define-data-var y-protocol-fee uint u0)
(define-data-var y-provider-fee uint u0)

(define-data-var liquidity-fee uint u0)

(define-data-var amplification-coefficient uint u0)
(define-data-var convergence-threshold uint u2)

(define-read-only (get-name)
    (ok (var-get pool-name))
)

(define-read-only (get-symbol)
    (ok (var-get pool-symbol))
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-token-uri)
    (ok (some (var-get pool-uri)))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply pool-token))
)

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance pool-token address))
)

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
    d: (var-get d),
    total-shares: (ft-get-supply pool-token),
    x-protocol-fee: (var-get x-protocol-fee),
    x-provider-fee: (var-get x-provider-fee),
    y-protocol-fee: (var-get y-protocol-fee),
    y-provider-fee: (var-get y-provider-fee),
    liquidity-fee: (var-get liquidity-fee),
    amplification-coefficient: (var-get amplification-coefficient),
    convergence-threshold: (var-get convergence-threshold)
    })
)

(define-public (set-pool-uri (uri (string-utf8 256)))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set pool-uri uri)
        (ok true)
    )
    )
)

(define-public (set-pool-status (status bool))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set pool-status status)
        (ok true)
    )
    )
)

(define-public (set-fee-address (address principal))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set fee-address address)
        (ok true)
    )
    )
)

(define-public (set-x-fees (protocol-fee uint) (provider-fee uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set x-protocol-fee protocol-fee)
        (var-set x-provider-fee provider-fee)
        (ok true)
    )
    )
)

(define-public (set-y-fees (protocol-fee uint) (provider-fee uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set y-protocol-fee protocol-fee)
        (var-set y-provider-fee provider-fee)
        (ok true)
    )
    )
)

(define-public (set-liquidity-fee (fee uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set liquidity-fee fee)
        (ok true)
    )
    )
)

(define-public (set-amplification-coefficient (coefficient uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set amplification-coefficient coefficient)
        (ok true)
    )
    )
)

(define-public (set-convergence-threshold (threshold uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set convergence-threshold threshold)
        (ok true)
    )
    )
)

(define-public (update-pool-balances (x-bal uint) (y-bal uint) (d-val uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (var-set x-balance x-bal)
        (var-set y-balance y-bal)
        (var-set d d-val)
        (print {action: "update-pool-balances", data: {x-balance: x-bal, y-balance: y-bal, d: d-val}})
        (ok true)
    )
    )
)

(define-public (transfer
    (amount uint)
    (sender principal) (recipient principal)
    (memo (optional (buff 34)))
    )
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller sender) ERR_NOT_AUTHORIZED_SIP_010)
        (asserts! (is-standard sender) ERR_INVALID_PRINCIPAL_SIP_010)
        (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL_SIP_010)
        (try! (ft-transfer? pool-token amount sender recipient))
        (match memo to-print (print to-print) 0x)
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

(define-public (pool-transfer (token-trait <sip-010-trait>) (amount uint) (recipient principal))
    (let (
    (token-contract (contract-of token-trait))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (asserts! (is-standard token-contract) ERR_INVALID_PRINCIPAL)
        (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (as-contract (contract-call? token-trait transfer amount tx-sender recipient none)))
        (print {action: "pool-transfer", data: {token: token-contract, amount: amount, recipient: recipient}})
        (ok true)
    )
    )
)

(define-public (pool-mint (amount uint) (address principal))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (ft-mint? pool-token amount address))
        (print {action: "pool-mint", data: {amount: amount, address: address}})
        (ok true)
    )
    )
)

(define-public (pool-burn (amount uint) (address principal))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
        (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (ft-burn? pool-token amount address))
        (print {action: "pool-burn", data: {amount: amount, address: address}})
        (ok true)
    )
    )
)

(define-public (create-pool
    (x-token-contract principal) (y-token-contract principal)
    (fee-addr principal)
    (coefficient uint)
    (threshold uint)
    (id uint)
    (name (string-ascii 32)) (symbol (string-ascii 32))
    (uri (string-utf8 256))
    (status bool)
    )
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq caller CORE_ADDRESS) ERR_NOT_AUTHORIZED)
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
        (var-set amplification-coefficient coefficient)
        (var-set convergence-threshold threshold)
        (ok true)
    )
    )
)
```
