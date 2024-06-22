---
title: "Trait exuberant-tan-swordfish"
draft: true
---
```
(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)
(define-constant ERR_BLOCK_INFO u42001)

(define-read-only (get-pair-data-at-block (block uint) (contract principal) (x-token <sip-010-trait>) (y-token <sip-010-trait>) (lp-token <sip-010-trait>))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
    (data (at-block block-hash (contract-call? .stableswap-usda-aeusdc-v-1-2 get-pair-data x-token y-token lp-token)))
  )
    (ok data)
  )
)
```
