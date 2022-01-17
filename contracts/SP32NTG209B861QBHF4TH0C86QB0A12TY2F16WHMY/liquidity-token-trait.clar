(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-trait liquidity-token-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    (get-name () (response (string-ascii 32) uint))

    (get-symbol () (response (string-ascii 32) uint))

    (get-decimals () (response uint uint))

    (get-balance (principal) (response uint uint))

    (get-total-supply () (response uint uint))

    (get-token-uri () (response (optional (string-utf8 256)) uint))


    (mint (principal uint) (response bool uint))

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
  )
)