(impl-trait 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)
(impl-trait 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.initializable-trait.initializable-liquidity-token-trait)
(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token liquidity-token)

(define-constant no-acccess-err u4204)

(define-constant ERR_UNAUTHORIZED u4205)
(define-constant PERMISSION_DENIED_ERROR u4206)
(define-constant TOKEN_TRANSFER_ERR u4207)
(define-constant ALREADY_INITIALIZED u4208)
(define-constant NOT_INITIALIZED u4209)
(define-constant INVALID_LP_TOKEN_ERR u4210)
(define-constant INVALID_TOKEN_ERR u4211)
(define-constant ALREADY_IN_SWAP u4211)


(define-constant NULL_PRINCIPAL tx-sender)

(define-data-var deployer-principal principal tx-sender)

(define-data-var is-initialized bool false)
(define-data-var is-in-swap bool false)


(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)


(define-data-var token-x principal NULL_PRINCIPAL)
(define-data-var token-y principal NULL_PRINCIPAL)

(define-data-var shares-total uint u0)
(define-data-var balance-x uint u0)
(define-data-var balance-y uint u0)
(define-data-var fee-balance-x uint u0)
(define-data-var fee-balance-y uint u0)
(define-data-var fee-to-address principal tx-sender)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_UNAUTHORIZED))
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? liquidity-token amount from to)
  )
)

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance liquidity-token owner))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply liquidity-token))
)

(define-data-var uri (string-utf8 256) u"")

(define-read-only (get-token-uri)
  (ok (some (var-get uri))))


(define-read-only (get-data (owner principal))
  (ok {
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (get-total-supply)),
    balance: (unwrap-panic (get-balance owner))
  })
)

(define-public (mint (recipient principal) (amount uint))
  (begin
    (print "token-liquidity.mint")
    (print (some contract-caller))
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (ft-mint? liquidity-token amount recipient)
  )
)

(define-public (burn (recipient principal) (amount uint))
  (begin
    (print "token-liquidity.burn")
    (print contract-caller)
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (ft-burn? liquidity-token amount recipient)
  )
)

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "one-step-mint"))) (err no-acccess-err))
    (asserts! (not (var-get is-initialized)) (err ALREADY_INITIALIZED))
    (var-set is-initialized true) 
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (ok u0)
  )
)


(define-public (transfer-token (amount uint) (token <sip-010-token>) (to principal) )
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (unwrap! (as-contract (contract-call? token transfer amount tx-sender to none)) (err TOKEN_TRANSFER_ERR))
    (ok true)
  )
)

(define-public (initialize-swap (token-x-input principal) (token-y-input principal))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (asserts!  (var-get is-initialized) (err NOT_INITIALIZED))
    (asserts! (not (var-get is-in-swap)) (err ALREADY_IN_SWAP))
    (var-set is-in-swap true) 
    (var-set token-x token-x-input)
    (var-set token-y token-y-input)
    (ok true)
  )
)

(define-public (set-lp-data ( data {
    shares-total: uint,
    balance-x: uint,
    balance-y: uint,
    fee-balance-x: uint,
    fee-balance-y: uint,
    fee-to-address: principal,
    liquidity-token: principal,
    name: (string-ascii 32),
  }) (token-x-input principal) (token-y-input principal))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (asserts! (is-eq (as-contract tx-sender) (get liquidity-token data)) (err INVALID_LP_TOKEN_ERR))
    (asserts! (is-eq token-x-input (var-get token-x)) (err INVALID_TOKEN_ERR))
    (asserts! (is-eq token-y-input (var-get token-y)) (err INVALID_TOKEN_ERR))
    (var-set shares-total (get shares-total data))
    (var-set balance-x (get balance-x data))
    (var-set balance-y (get balance-y data))
    (var-set fee-balance-x (get fee-balance-x data))
    (var-set fee-balance-y (get fee-balance-y data))
    (var-set fee-to-address (get fee-to-address data))
    (ok true)
  )
)

(define-read-only (get-lp-data)
  (begin
    (ok {
    shares-total: (var-get shares-total),
    balance-x: (var-get balance-x),
    balance-y: (var-get balance-y),
    fee-balance-x: (var-get fee-balance-x),
    fee-balance-y: (var-get fee-balance-y),
    fee-to-address: (var-get fee-to-address),
    liquidity-token: (as-contract tx-sender),
    name: (var-get token-name),
    })
  )
)


(define-read-only (get-token-x)
  (ok (var-get token-x)))
  
(define-read-only (get-token-y)
  (ok (var-get token-y)))

(contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-one-step-mint add-liquidity-token (as-contract tx-sender))