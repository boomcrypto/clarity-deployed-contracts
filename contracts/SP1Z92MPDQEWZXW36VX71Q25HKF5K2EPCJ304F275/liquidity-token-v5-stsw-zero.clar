(impl-trait .liquidity-token-trait-v4c.liquidity-token-trait)
(impl-trait .initializable-trait-v1b.initializable-liquidity-token-trait)
(use-trait sip-010-token .sip-010-v1a.sip-010-trait)

(define-fungible-token liquidity-token)

(define-constant ERR_UNAUTHORIZED u4201)
(define-constant ERR_TOKEN_TRANSFER u4202)
(define-constant ERR_ALREADY_INITIALIZED u4203)
(define-constant ERR_NOT_INITIALIZED u4204)
(define-constant ERR_INVALID_LP_TOKEN u4205)
(define-constant ERR_INVALID_TOKEN u4206)
(define-constant ERR_ALREADY_IN_SWAP u4207)
(define-constant ERR_DAO_ACCESS u4208)


(define-constant NULL_PRINCIPAL tx-sender)

(define-data-var is-initialized bool true)
(define-data-var is-in-swap bool true)

(ok (tuple (shares-total u0)))

(define-data-var token-name (string-ascii 32) "STSW-ZERO")
(define-data-var token-symbol (string-ascii 32) "STSW-ZERO")
(define-data-var token-decimals uint u6)


(define-data-var token-x principal 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a)
(define-data-var token-y principal 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9)

(define-data-var shares-total uint u0)
(define-data-var balance-x uint u0)
(define-data-var balance-y uint u0)
(define-data-var fee-balance-x uint u0)
(define-data-var fee-balance-y uint u0)
(define-data-var fee-to-address principal 'SP3QSWXQQJ5BKCVZBY1BH3BPGVX4MZPRKKG8CBDGR)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_UNAUTHORIZED))
    (try! (ft-transfer? liquidity-token amount from to))
	(match memo to-print (print to-print) 0x)
	(ok true)
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (ft-mint? liquidity-token amount recipient)
  )
)

(define-public (burn (recipient principal) (amount uint))
  (begin
    (print "token-liquidity.burn")
    (print contract-caller)
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (ft-burn? liquidity-token amount recipient)
  )
)

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "one-step-mint"))) (err ERR_DAO_ACCESS))
    (asserts! (not (var-get is-initialized)) (err ERR_ALREADY_INITIALIZED))
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (unwrap! (as-contract (contract-call? token transfer amount tx-sender to none)) (err ERR_TOKEN_TRANSFER))
    (ok true)
  )
)

(define-public (initialize-swap (token-x-input principal) (token-y-input principal))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (asserts!  (var-get is-initialized) (err ERR_NOT_INITIALIZED))
    (asserts! (not (var-get is-in-swap)) (err ERR_ALREADY_IN_SWAP))
    (var-set is-in-swap true) ;; Set to true so that this can't be called again
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (asserts! (is-eq (as-contract tx-sender) (get liquidity-token data)) (err ERR_INVALID_LP_TOKEN))
    (asserts! (is-eq token-x-input (var-get token-x)) (err ERR_INVALID_TOKEN))
    (asserts! (is-eq token-y-input (var-get token-y)) (err ERR_INVALID_TOKEN))
    (var-set shares-total (get shares-total data))
    (var-set balance-x (get balance-x data))
    (var-set balance-y (get balance-y data))
    (var-set fee-balance-x (get fee-balance-x data))
    (var-set fee-balance-y (get fee-balance-y data))
    (var-set fee-to-address (get fee-to-address data))
    (ok true)
  )
)

(define-public (set-fee-to-address (fee-to-address-in principal))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "swap"))) (err ERR_DAO_ACCESS))
    (var-set fee-to-address fee-to-address-in)
    (ok true)
  )
)

(define-read-only (get-lp-data)
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

(define-read-only (get-tokens)
  (ok {token-x: (var-get token-x), token-y: (var-get token-y)}))