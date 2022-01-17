;; ;; we implement the sip-010 + a mint function liquidity-token-soft-trait
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v1a.liquidity-token-trait)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-liquidity-token-trait)

;; ;; we can use an ft-token here, so use it!
(define-fungible-token liquidity-token)

(define-constant no-acccess-err u4204)

;; Error returned for permission denied - stolen from http 403
(define-constant ERR_UNAUTHORIZED u4205)
(define-constant PERMISSION_DENIED_ERROR u4206)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal tx-sender)

(define-data-var is-initialized bool false)

(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

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
    ;; (print (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-qualified-name-by-name "swap"))
    (print amount)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-qualified-name-by-name "swap"))) (err no-acccess-err))
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-qualified-name-by-name "swap"))) (err no-acccess-err))
    (ft-burn? liquidity-token amount recipient)
  )
)

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)))
  (begin
    (print "token-liquidity.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-qualified-name-by-name "one-step-mint"))) (err no-acccess-err))
    (asserts! (not (var-get is-initialized)) (err PERMISSION_DENIED_ERROR))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    ;; (map-set roles { role: MINTER_ROLE, account: initial-owner } { allowed: true })
    (ok u0)
  )
)

(contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v1b add-liquidity-token (as-contract tx-sender))