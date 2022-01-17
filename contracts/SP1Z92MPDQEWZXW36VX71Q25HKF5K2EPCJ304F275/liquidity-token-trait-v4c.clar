;; this is an SIP-010 method with an additional functions used by stackswap-swap
;; as Clarity does not support "includes", copy the needed functions, and add new ones

(use-trait sip-010-token .sip-010-v1a.sip-010-trait)

(define-trait liquidity-token-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; the human readable name of the token
    (get-name () (response (string-ascii 32) uint))

    ;; the ticker symbol, or empty if none
    (get-symbol () (response (string-ascii 32) uint))

    ;; the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
    (get-decimals () (response uint uint))

    ;; the balance of the passed principal
    (get-balance (principal) (response uint uint))

    ;; the current total supply (which does not need to be a constant)
    (get-total-supply () (response uint uint))

    ;; an optional URI that represents metadata of this token
    (get-token-uri () (response (optional (string-utf8 256)) uint))

    ;; additional functions specific to stackswap-swap

    ;; mint function only stackswap-swap contract can call
    (mint (principal uint) (response bool uint))

    ;; burn function only stackswap-swap contract can call
    (burn (principal uint) (response bool uint))

    ;;
    (get-data (principal) (response {
      name: (string-ascii 32),
      symbol: (string-ascii 32),
      decimals: uint,
      uri: (optional (string-utf8 256)),
      supply: uint,
      balance: uint,
    } uint))
    
    (transfer-token (uint <sip-010-token> principal) (response bool uint))
    

    (initialize-swap (principal principal) (response bool uint))

    (set-lp-data ({
        shares-total: uint,
        balance-x: uint,
        balance-y: uint,
        fee-balance-x: uint,
        fee-balance-y: uint,
        fee-to-address: principal,
        liquidity-token: principal,
        name: (string-ascii 32),
      } principal principal) (response bool uint))

    (get-lp-data () (response {
        shares-total: uint,
        balance-x: uint,
        balance-y: uint,
        fee-balance-x: uint,
        fee-balance-y: uint,
        fee-to-address: principal,
        liquidity-token: principal,
        name: (string-ascii 32),
      } uint))

    (set-fee-to-address (principal) (response bool uint))

    (get-tokens () (response {token-x: principal, token-y: principal} uint))
  )
)