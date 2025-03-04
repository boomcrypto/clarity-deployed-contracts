
;; keeper-action-trait-v-1-1

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait .xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait xyk-staking-trait .xyk-staking-trait-v-1-2.xyk-staking-trait)
(use-trait xyk-emissions-trait .xyk-emissions-trait-v-1-2.xyk-emissions-trait)
(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stableswap-staking-trait .stableswap-staking-trait-v-1-2.stableswap-staking-trait)
(use-trait stableswap-emissions-trait .stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

;; Define keeper action trait
(define-trait keeper-action-trait
  (
    (get-output (
      uint uint principal principal (buff 64) principal
      (optional (list 26 <ft-trait>))
      (optional (list 26 <xyk-pool-trait>))
      (optional (list 26 <xyk-staking-trait>))
      (optional (list 26 <xyk-emissions-trait>))
      (optional (list 26 <stableswap-pool-trait>))
      (optional (list 26 <stableswap-staking-trait>))
      (optional (list 26 <stableswap-emissions-trait>))
      (optional (list 26 uint))
      (optional (list 26 bool))
      (optional (list 26 principal))
    ) (response uint uint))
    (get-minimum (
      uint uint principal principal (buff 64) principal
      (optional (list 26 <ft-trait>))
      (optional (list 26 <xyk-pool-trait>))
      (optional (list 26 <xyk-staking-trait>))
      (optional (list 26 <xyk-emissions-trait>))
      (optional (list 26 <stableswap-pool-trait>))
      (optional (list 26 <stableswap-staking-trait>))
      (optional (list 26 <stableswap-emissions-trait>))
      (optional (list 26 uint))
      (optional (list 26 bool))
      (optional (list 26 principal))
    ) (response uint uint))
    (execute-action (
      uint uint principal principal (buff 64) principal
      (optional (list 26 <ft-trait>))
      (optional (list 26 <xyk-pool-trait>))
      (optional (list 26 <xyk-staking-trait>))
      (optional (list 26 <xyk-emissions-trait>))
      (optional (list 26 <stableswap-pool-trait>))
      (optional (list 26 <stableswap-staking-trait>))
      (optional (list 26 <stableswap-emissions-trait>))
      (optional (list 26 uint))
      (optional (list 26 bool))
      (optional (list 26 principal))
    ) (response uint uint))
  )
)