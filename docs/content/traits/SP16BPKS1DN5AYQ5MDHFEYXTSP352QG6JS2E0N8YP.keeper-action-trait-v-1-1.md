---
title: "Trait keeper-action-trait-v-1-1"
draft: true
---
```
;; keeper-action-trait-v-1-1

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait xyk-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-trait-v-1-2.xyk-staking-trait)
(use-trait xyk-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-emissions-trait-v-1-2.xyk-emissions-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stableswap-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-trait-v-1-2.stableswap-staking-trait)
(use-trait stableswap-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

;; Define keeper action trait
(define-trait keeper-action-trait
  (
    (get-output (
      uint uint principal principal (buff 64) principal
      (optional (list 12 <ft-trait>))
      (optional (list 12 <xyk-pool-trait>))
      (optional (list 12 <xyk-staking-trait>))
      (optional (list 12 <xyk-emissions-trait>))
      (optional (list 12 <stableswap-pool-trait>))
      (optional (list 12 <stableswap-staking-trait>))
      (optional (list 12 <stableswap-emissions-trait>))
      (optional (list 12 uint))
      (optional (list 12 bool))
      (optional (list 12 principal))
    ) (response uint uint))
    (get-minimum (
      uint uint principal principal (buff 64) principal
      (optional (list 12 <ft-trait>))
      (optional (list 12 <xyk-pool-trait>))
      (optional (list 12 <xyk-staking-trait>))
      (optional (list 12 <xyk-emissions-trait>))
      (optional (list 12 <stableswap-pool-trait>))
      (optional (list 12 <stableswap-staking-trait>))
      (optional (list 12 <stableswap-emissions-trait>))
      (optional (list 12 uint))
      (optional (list 12 bool))
      (optional (list 12 principal))
    ) (response uint uint))
    (execute-action (
      uint uint principal principal (buff 64) principal
      (optional (list 12 <ft-trait>))
      (optional (list 12 <xyk-pool-trait>))
      (optional (list 12 <xyk-staking-trait>))
      (optional (list 12 <xyk-emissions-trait>))
      (optional (list 12 <stableswap-pool-trait>))
      (optional (list 12 <stableswap-staking-trait>))
      (optional (list 12 <stableswap-emissions-trait>))
      (optional (list 12 uint))
      (optional (list 12 bool))
      (optional (list 12 principal))
    ) (response uint uint))
  )
)
```
