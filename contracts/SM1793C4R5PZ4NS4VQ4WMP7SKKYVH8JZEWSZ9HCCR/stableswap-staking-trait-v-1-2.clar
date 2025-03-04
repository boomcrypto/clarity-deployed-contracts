
;; stableswap-staking-trait-v-1-2

;; Define staking trait for Stableswap Core
(define-trait stableswap-staking-trait
  (
    (get-deployment-height () (response uint uint))
    (get-current-cycle () (response uint uint))
    (get-cycle-from-height (uint) (response uint uint))
    (get-starting-height-from-cycle (uint) (response uint bool))
    (get-staking-status () (response bool bool))
    (get-early-unstake-status () (response bool bool))
    (get-early-unstake-fee-address () (response principal principal))
    (get-early-unstake-fee () (response uint uint))
    (get-minimum-staking-duration () (response uint uint))
    (get-maximum-staking-duration () (response uint uint))
    (get-total-lp-staked () (response uint uint))
    (get-lp-staked-at-cycle (uint) (response (optional uint) uint))
    (get-user (principal) (response (optional {
      cycles-staked: (list 12000 uint),
      cycles-to-unstake: (list 12000 uint),
      lp-staked: uint
    }) uint))
    (get-user-at-cycle (principal uint) (response (optional {
      lp-staked: uint,
      lp-to-unstake: uint
    }) uint))
    (stake-lp-tokens (uint uint) (response {
      amount: uint,
      cycles: uint
    } uint))
    (unstake-lp-tokens () (response uint uint))
    (early-unstake-lp-tokens () (response {
      matured-lp-to-unstake-user: uint,
      early-lp-to-unstake-user: uint
    } uint))
  )
)