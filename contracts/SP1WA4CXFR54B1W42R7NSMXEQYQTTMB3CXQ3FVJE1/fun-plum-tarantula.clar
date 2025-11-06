;; fun-plum-tarantula

;; Use SIP 010 trait
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Define pool trait for Stableswap Core
(define-trait stableswap-pool-trait
  (
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
    (get-total-supply () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-pool () (response {
      pool-id: uint,
      pool-name: (string-ascii 32),
      pool-symbol: (string-ascii 32),
      pool-uri: (string-utf8 256),
      pool-created: bool,
      creation-height: uint,
      pool-status: bool,
      core-address: principal,
      midpoint-manager: principal,
      fee-address: principal,
      x-token: principal,
      y-token: principal,
      pool-token: principal,
      x-balance: uint,
      y-balance: uint,
      d: uint,
      midpoint-primary-numerator: uint,
      midpoint-primary-denominator: uint,
      midpoint-withdraw-numerator: uint,
      midpoint-withdraw-denominator: uint,
      total-shares: uint,
      x-protocol-fee: uint,
      x-provider-fee: uint,
      y-protocol-fee: uint,
      y-provider-fee: uint,
      liquidity-fee: uint,
      amplification-coefficient: uint,
      convergence-threshold: uint,
      imbalanced-withdraws: bool,
      last-midpoint-update: uint,
      withdraw-cooldown: uint,
      freeze-midpoint-manager: bool
    } uint))
    (set-pool-uri ((string-utf8 256)) (response bool uint))
    (set-pool-status (bool) (response bool uint))
    (set-midpoint-manager (principal) (response bool uint))
    (set-fee-address (principal) (response bool uint))
    (set-midpoint (uint uint uint uint) (response bool uint))
    (set-x-fees (uint uint) (response bool uint))
    (set-y-fees (uint uint) (response bool uint))
    (set-liquidity-fee (uint) (response bool uint))
    (set-amplification-coefficient (uint) (response bool uint))
    (set-convergence-threshold (uint) (response bool uint))
    (set-imbalanced-withdraws (bool) (response bool uint))
    (set-withdraw-cooldown (uint) (response bool uint))
    (set-freeze-midpoint-manager () (response bool uint))
    (update-pool-balances (uint uint uint) (response bool uint))
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (pool-transfer (<sip-010-trait> uint principal) (response bool uint))
    (pool-mint (uint principal) (response bool uint))
    (pool-burn (uint principal) (response bool uint))
    (create-pool (principal principal principal principal principal uint uint uint (string-ascii 32) (string-ascii 32) (string-utf8 256) bool) (response bool uint))
  )
)