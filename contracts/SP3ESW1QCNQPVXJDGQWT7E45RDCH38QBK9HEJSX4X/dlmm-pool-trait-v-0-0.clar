;; dlmm-pool-trait-v-0-0

;; Use SIP 010 trait
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-0-0.sip-010-trait)

;; Define pool trait for DLMM Core
(define-trait dlmm-pool-trait
  (
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals (uint) (response uint uint))
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    (get-total-supply (uint) (response uint uint))
    (get-overall-supply () (response uint uint))
    (get-balance (uint principal) (response uint uint))
    (get-overall-balance (principal) (response uint uint))
    (get-pool () (response {
      pool-id: uint,
      pool-name: (string-ascii 32),
      pool-symbol: (string-ascii 32),
      pool-uri: (string-ascii 256),
      pool-created: bool,
      creation-height: uint,
      core-address: principal,
      variable-fees-manager: principal,
      fee-address: principal,
      x-token: principal,
      y-token: principal,
      pool-token: principal,
      bin-step: uint,
      initial-price: uint,
      active-bin-id: int,
      x-protocol-fee: uint,
      x-provider-fee: uint,
      x-variable-fee: uint,
      y-protocol-fee: uint,
      y-provider-fee: uint,
      y-variable-fee: uint,
      bin-change-count: uint,
      last-variable-fees-update: uint,
      variable-fees-cooldown: uint,
      freeze-variable-fees-manager: bool,
      dynamic-config: (buff 4096)
    } uint))
    (get-pool-for-swap (bool) (response {
      pool-id: uint,
      pool-name: (string-ascii 32),
      fee-address: principal,
      x-token: principal,
      y-token: principal,
      bin-step: uint,
      initial-price: uint,
      active-bin-id: int,
      protocol-fee: uint,
      provider-fee: uint,
      variable-fee: uint
    } uint))
    (get-pool-for-add () (response {
      pool-id: uint,
      pool-name: (string-ascii 32),
      x-token: principal,
      y-token: principal,
      bin-step: uint,
      initial-price: uint,
      active-bin-id: int,
      x-protocol-fee: uint,
      x-provider-fee: uint,
      x-variable-fee: uint,
      y-protocol-fee: uint,
      y-provider-fee: uint,
      y-variable-fee: uint
    } uint))
    (get-pool-for-withdraw () (response {
      pool-id: uint,
      pool-name: (string-ascii 32),
      x-token: principal,
      y-token: principal
    } uint))
    (get-variable-fees-data () (response {
      variable-fees-manager: principal,
      x-variable-fee: uint,
      y-variable-fee: uint,
      bin-change-count: uint,
      last-variable-fees-update: uint,
      variable-fees-cooldown: uint,
      freeze-variable-fees-manager: bool,
      dynamic-config: (buff 4096)
    } uint))
    (get-active-bin-id () (response int uint))
    (get-bin-balances (uint) (response {x-balance: uint, y-balance: uint, bin-shares: uint} uint))
    (get-user-bins (principal) (response (list 1001 uint) uint))
    (set-pool-uri ((string-ascii 256)) (response bool uint))
    (set-variable-fees-manager (principal) (response bool uint))
    (set-fee-address (principal) (response bool uint))
    (set-active-bin-id (int) (response bool uint))
    (set-x-fees (uint uint) (response bool uint))
    (set-y-fees (uint uint) (response bool uint))
    (set-variable-fees (uint uint) (response bool uint))
    (set-variable-fees-cooldown (uint) (response bool uint))
    (set-freeze-variable-fees-manager () (response bool uint))
    (set-dynamic-config ((buff 4096)) (response bool uint))
    (update-bin-balances (uint uint uint) (response bool uint))
    (update-bin-balances-on-withdraw (uint uint uint uint) (response bool uint))
    (transfer (uint uint principal principal) (response bool uint))
    (transfer-memo (uint uint principal principal (buff 34)) (response bool uint))
    (transfer-many ((list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal})) (response bool uint))
    (transfer-many-memo ((list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)})) (response bool uint))
    (pool-transfer (<sip-010-trait> uint principal) (response bool uint))
    (pool-mint (uint uint principal) (response bool uint))
    (pool-burn (uint uint principal) (response bool uint))
    (create-pool (principal principal principal principal principal int uint uint uint (string-ascii 32) (string-ascii 32) (string-ascii 256)) (response bool uint))
  )
)