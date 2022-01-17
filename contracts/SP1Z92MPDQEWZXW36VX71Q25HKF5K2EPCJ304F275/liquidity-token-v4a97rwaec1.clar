;; ;; we implement the sip-010 + a mint function liquidity-token-soft-trait
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v2a.liquidity-token-trait)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-liquidity-token-trait)
(use-trait sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;; ;; we can use an ft-token here, so use it!
(define-fungible-token liquidity-token)

(define-constant no-acccess-err u4204)

;; Error returned for permission denied - stolen from http 403
(define-constant ERR_UNAUTHORIZED u4205)
(define-constant PERMISSION_DENIED_ERROR u4206)
(define-constant TOKEN_TRANSFER_ERR u4207)
(define-constant ALREADY_INITIALIZED u4208)
(define-constant NOT_INITIALIZED u4209)
(define-constant INVALID_LP_TOKEN_ERR u4210)
(define-constant INVALID_TOKEN_ERR u4211)
(define-constant ALREADY_IN_SWAP u4211)


(define-constant NULL_PRINCIPAL tx-sender)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal tx-sender)

(define-data-var is-initialized bool false)
(define-data-var is-in-swap bool false)


(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)


;; DATA for LP
(define-data-var token-x principal NULL_PRINCIPAL)
(define-data-var token-y principal NULL_PRINCIPAL)

(define-data-var shares-total uint u0)
(define-data-var balance-x uint u0)
(define-data-var balance-y uint u0)
(define-data-var fee-balance-x uint u0)
(define-data-var fee-balance-y uint u0)
(define-data-var fee-to-address principal tx-sender)


;; implement all functions required by sip-010

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

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance liquidity-token owner))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply liquidity-token))
)

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))


;; one stop function to gather all the data relevant to the liquidity token in one call
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

;; the extra mint method used by stackswap when adding liquidity
;; can only be used by STACKSWAP main contract
(define-public (mint (recipient principal) (amount uint))
  (begin
    (print "token-liquidity.mint")
    (print (some contract-caller))
    ;; (print (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (ft-mint? liquidity-token amount recipient)
  )
)

;; the extra burn method used by STACKSWAP when removing liquidity
;; can only be used by STACKSWAP main contract
(define-public (burn (recipient principal) (amount uint))
  (begin
    (print "token-liquidity.burn")
    (print contract-caller)
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (ft-burn? liquidity-token amount recipient)
  )
)

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "one-step-mint"))) (err no-acccess-err))
    (asserts! (not (var-get is-initialized)) (err ALREADY_INITIALIZED))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    ;; (map-set roles { role: MINTER_ROLE, account: initial-owner } { allowed: true })
    (ok u0)
  )
)


(define-public (transfer-token (amount uint) (token <sip-010-token>) (to principal) )
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (unwrap! (as-contract (contract-call? token transfer amount tx-sender to none)) (err TOKEN_TRANSFER_ERR))
    (ok true)
  )
)

(define-public (initialize-swap (token-x-input principal) (token-y-input principal))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (asserts!  (var-get is-initialized) (err NOT_INITIALIZED))
    (asserts! (not (var-get is-in-swap)) (err ALREADY_IN_SWAP))
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "swap"))) (err no-acccess-err))
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


;; Returns the token name
(define-read-only (get-token-x)
  (ok (var-get token-x)))
  
;; Returns the token name
(define-read-only (get-token-y)
  (ok (var-get token-y)))

 (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v4a add-liquidity-token (as-contract tx-sender))
