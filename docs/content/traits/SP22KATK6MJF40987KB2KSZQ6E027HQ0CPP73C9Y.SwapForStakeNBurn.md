---
title: "Trait SwapForStakeNBurn"
draft: true
---
```
;; By Highroller.btc
;; This contract swaps up to the entire supply of of LiSTX for ROCK
;; and let's the public chose how much to send to burn or to the staking pool

(use-trait v-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78)
(define-constant staking 'SP22KATK6MJF40987KB2KSZQ6E027HQ0CPP73C9Y.StakeForRock)

(define-constant LiSTX_CONTRACT 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx)
(define-constant wstx_CONTRACT 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
(define-constant ERR_SWAP_FAILED (err u1003))
(define-constant ROCK_Contract 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock)
(define-data-var last-swap-height uint u0)
(define-constant WQSTXv3 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlqstx-v3)
(define-constant WSTXv2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)

(define-data-var balNow uint u0)

(define-public (hot-swap

    (v-share-fee-to <v-share-fee-to-trait>)
    
    (a-factors (tuple (a uint)))
)
  (begin
    ;; Call the swap function in the target contract
    (let (
      (current-balance (unwrap-panic (contract-call? LiSTX_CONTRACT get-balance (as-contract tx-sender))))
      (swap-result (as-contract (contract-call? 
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.router-velar-alex-v-1-2 
        swap-helper-a
        current-balance
        u1
        true
        (tuple (a wstx_CONTRACT) (b ROCK_Contract))
        v-share-fee-to
        (tuple (a WQSTXv3) (b WSTXv2))
        a-factors
      )))
    )
    ;; Check if the swap was successful
    (match swap-result
      swap-ok (ok swap-ok)
      swap-err (err ERR_SWAP_FAILED)
    )
  )
))

(define-public (toStake (amount uint))
  (contract-call? ROCK_Contract transfer amount (as-contract tx-sender) staking none)
)

(define-public (burn (amount uint))
  (contract-call? ROCK_Contract transfer amount (as-contract tx-sender) BURN_ADDRESS none)
)
```
