---
title: "Trait migration-stx-ststx-v-1-1"
draft: true
---
```

;; migration-stx-ststx-v-1-1
;; Contract to facilitate migration from stableswap-stx-ststx-v-1-2 to stableswap-core-v-1-3

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-3.stableswap-pool-trait)

;; Error constants
(define-constant ERR_WITHDRAWING_LIQUIDITY (err u6001))
(define-constant ERR_ADDING_LIQUIDITY (err u6002))

;; Migrate from v-1-2 pool to v-1-3 pool
(define-public (migrate (lp-amount uint) (min-stx uint) (min-ststx uint) (min-new-lp uint) (cycles uint))
  (let (
    ;; Claim any staking rewards
    (claim-rewards (claim-any-rewards))

    ;; Reclaim any staked idle LP tokens and calculate updated LP amount
    (reclaim-idle-lp (reclaim-any-idle-lp))
    (updated-lp-amount (+ lp-amount reclaim-idle-lp))
    
    ;; Withdraw liquidity from v-1-2 pool
    (withdraw-liquidity (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 withdraw-liquidity
                                 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                                 updated-lp-amount min-stx min-ststx) ERR_WITHDRAWING_LIQUIDITY))
    (stx-withdrawn (get withdrawal-x-balance withdraw-liquidity))
    (ststx-withdrawn (get withdrawal-y-balance withdraw-liquidity))

    ;; Add liquidity to v-1-3 pool
    (add-liquidity (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 add-liquidity
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-3
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                            'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                            stx-withdrawn ststx-withdrawn min-new-lp) ERR_ADDING_LIQUIDITY))
    
    ;; Stake new LP tokens if cycles is greater than 0
    (stake-new-lp (if (> cycles u0)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-stx-ststx-v-1-3 stake-lp-tokens
            add-liquidity cycles))
      {amount: u0, cycles: u0}))

    (caller tx-sender)
  )
    (begin
      (print {
        action: "migrate",
        caller: caller,
        data: {
          lp-amount: lp-amount,
          updated-lp-amount: updated-lp-amount,
          min-stx: min-stx,
          min-ststx: min-ststx,
          min-new-lp: min-new-lp,
          cycles: cycles,
          rewards-claimed: claim-rewards,
          idle-lp-reclaiemd: reclaim-idle-lp,
          stx-withdrawn: stx-withdrawn,
          ststx-withdrawn: ststx-withdrawn,
          new-lp-amount: add-liquidity,
          new-lp-staked: stake-new-lp
        }
      })
      (ok add-liquidity)
    )
  )
)

;; Helper function for claiming any available rewards
(define-private (claim-any-rewards)
  (begin
    (match (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 claim-all-staking-rewards
           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
      reward-amount (get x-token-reward reward-amount)
      error u0
    )
  )
)

;; Helper function for reclaiming any idle LP tokens
(define-private (reclaim-any-idle-lp)
  (begin
    (match (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 unstake-all-lp-tokens
           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2)
      reclaimed-amount reclaimed-amount
      error u0
    )
  )
)
```
