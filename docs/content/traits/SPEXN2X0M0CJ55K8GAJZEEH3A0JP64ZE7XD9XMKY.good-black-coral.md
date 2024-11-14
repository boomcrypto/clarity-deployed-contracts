---
title: "Trait good-black-coral"
draft: true
---
```
;; xyk-staking-stx-aeusdc-v-1-1

(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_STAKING_DISABLED (err u6001))
(define-constant ERR_INCORRECT_POOL_TRAIT (err u6002))
(define-constant ERR_INVALID_CYCLE_LENGTH (err u6003))
(define-constant ERR_CYCLES_STAKED_OVERFLOW (err u6004))
(define-constant ERR_CYCLES_TO_UNSTAKE_OVERFLOW (err u6005))
(define-constant ERR_NO_USER_DATA (err u6006))
(define-constant ERR_NO_LP_TO_UNSTAKE (err u6007))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant POOL_ADDRESS 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1)

(define-constant CYCLES_LIST (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
                             u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
                             u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60
                             u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80
                             u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100
                             u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116
                             u117 u118 u119 u120))

(define-constant DEPLOYMENT_HEIGHT burn-block-height)
(define-constant CYCLE_LENGTH u144)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var helper-value uint u0)
(define-data-var helper-list (list 12000 uint) (list ))

(define-data-var staking-status bool true)

(define-data-var total-lp-staked uint u0)

(define-map lp-staked-at-cycle uint uint)

(define-map user-data principal {
  cycles-staked: (list 12000 uint),
  cycles-to-unstake: (list 12000 uint),
  lp-staked: uint
})

(define-map user-data-at-cycle {user: principal, cycle: uint} {
  lp-staked: uint,
  lp-to-unstake: uint
})

(define-read-only (get-admins)
  (ok (var-get admins))
)

(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

(define-read-only (get-helper-value)
  (ok (var-get helper-value))
)

(define-read-only (get-helper-list)
  (ok (var-get helper-list))
)

(define-read-only (get-staking-status)
  (ok (var-get staking-status))
)

(define-read-only (get-current-cycle) 
  (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH)
)

(define-read-only (get-cycle-from-height (height uint)) 
  (/ (- height DEPLOYMENT_HEIGHT) CYCLE_LENGTH)
)

(define-read-only (get-starting-height-from-cycle (cycle uint)) 
  (ok (+ DEPLOYMENT_HEIGHT (* cycle CYCLE_LENGTH)))
)

(define-read-only (get-deployment-height) 
  (ok DEPLOYMENT_HEIGHT)
)

(define-read-only (get-total-lp-staked)
  (ok (var-get total-lp-staked))
)

(define-read-only (get-lp-staked-at-cycle (cycle uint))
  (ok (map-get? lp-staked-at-cycle cycle))
)

(define-read-only (get-user (user principal))
  (ok (map-get? user-data user))
)

(define-read-only (get-user-at-cycle (user principal) (cycle uint))
  (ok (map-get? user-data-at-cycle {user: user, cycle: cycle}))
)

(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller-in-list (index-of admins-list tx-sender))
    (admin-to-remove-in-list (index-of admins-list admin))
    (caller tx-sender)
  )
    (asserts! (is-some caller-in-list) ERR_NOT_AUTHORIZED)
    (asserts! (is-some admin-to-remove-in-list) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removeable admins-list))
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (set-staking-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (var-set staking-status status)
      (print {action: "set-staking-status", caller: caller, data: {pool-contract: POOL_ADDRESS, status: status}})
      (ok true)
    )
  )
)

(define-public (stake-lp-tokens (pool-trait <xyk-pool-trait>) (amount uint) (cycles uint))
  (let (
    (current-user-data (map-get? user-data tx-sender))
    (user-cycles-staked (default-to (list ) (get cycles-staked current-user-data)))
    (user-cycles-to-unstake (default-to (list ) (get cycles-to-unstake current-user-data)))
    (helper-value-for-filter (var-set helper-value cycles))
    (filtered-cycles-list (filter filter-cycles-list CYCLES_LIST))
    (current-cycle (get-current-cycle))
    (helper-value-for-map (var-set helper-value current-cycle))
    (next-cycles (map map-filtered-cycles-list filtered-cycles-list))
    (helper-list-for-filter (var-set helper-list user-cycles-staked))
    (filtered-next-cycles-list (filter filter-next-cycles-list next-cycles))
    (cycle-to-unstake (+ u1 (+ current-cycle cycles)))
    (updated-total-lp-staked (+ (var-get total-lp-staked) amount))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get staking-status) true) ERR_STAKING_DISABLED)
      (asserts! (is-eq (contract-of pool-trait) POOL_ADDRESS) ERR_INCORRECT_POOL_TRAIT)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (and (> cycles u0) (< cycles u121)) ERR_INVALID_CYCLE_LENGTH)
      (try! (contract-call? pool-trait transfer amount caller (as-contract tx-sender) none))
      (fold fold-user-data-per-cycle next-cycles {amount: amount, cycles-staked: user-cycles-staked})
      (var-set total-lp-staked updated-total-lp-staked)
      (if (is-some current-user-data)
        (map-set user-data caller {
          cycles-staked: (unwrap! (as-max-len? (concat user-cycles-staked filtered-next-cycles-list) u12000) ERR_CYCLES_STAKED_OVERFLOW),
          cycles-to-unstake: (if (is-some (index-of user-cycles-to-unstake cycle-to-unstake))
            user-cycles-to-unstake
            (unwrap! (as-max-len? (concat user-cycles-to-unstake (list cycle-to-unstake)) u12000) ERR_CYCLES_TO_UNSTAKE_OVERFLOW)
          ),
          lp-staked: (+ amount (default-to u0 (get lp-staked current-user-data)))
        })
        (map-set user-data caller {
          cycles-staked: next-cycles,
          cycles-to-unstake: (list cycle-to-unstake),
          lp-staked: amount
        })
      )
      (if (is-some (map-get? user-data-at-cycle {user: caller, cycle: cycle-to-unstake}))
        (map-set user-data-at-cycle {user: caller, cycle: cycle-to-unstake} (merge 
          (default-to {lp-staked: u0, lp-to-unstake: u0} (map-get? user-data-at-cycle {user: caller, cycle: cycle-to-unstake}))
          {lp-to-unstake: (+ amount (default-to u0 (get lp-to-unstake (map-get? user-data-at-cycle {user: caller, cycle: cycle-to-unstake}))))}
        ))
        (map-set user-data-at-cycle {user: caller, cycle: cycle-to-unstake} { 
          lp-staked: u0,
          lp-to-unstake: amount
        })
      )
      (print {
        action: "stake-lp-tokens",
        caller: caller,
        data: {
          pool-contract: (contract-of pool-trait),
          current-cycle: current-cycle,
          total-lp-staked: updated-total-lp-staked,
          amount: amount,
          cycles: cycles,
          cycle-to-unstake: cycle-to-unstake,
          user-lp-staked: (+ amount (default-to u0 (get lp-staked current-user-data)))
        }
      })
      (ok {amount: amount, cycles: cycles})
    )   
  )
)

(define-public (unstake-lp-tokens (pool-trait <xyk-pool-trait>))
  (let (
    (current-cycle (get-current-cycle))
    (helper-value-current-cycle (var-set helper-value current-cycle))
    (current-user-data (unwrap! (map-get? user-data tx-sender) ERR_NO_USER_DATA))
    (user-cycles-to-unstake (get cycles-to-unstake current-user-data))
    (user-lp-staked (get lp-staked current-user-data))      
    (unstake-data (fold fold-cycles-to-unstakeable-cycles user-cycles-to-unstake {lp-to-unstake: u0, cycles-to-unstake: user-cycles-to-unstake}))
    (lp-to-unstake (get lp-to-unstake unstake-data))
    (updated-user-lp-staked (- user-lp-staked lp-to-unstake))
    (updated-total-lp-staked (- (var-get total-lp-staked) lp-to-unstake))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (contract-of pool-trait) POOL_ADDRESS) ERR_INCORRECT_POOL_TRAIT)
      (asserts! (> lp-to-unstake u0) ERR_NO_LP_TO_UNSTAKE)
      (try! (as-contract (contract-call? pool-trait transfer lp-to-unstake tx-sender caller none)))
      (var-set total-lp-staked updated-total-lp-staked)
      (map-set user-data caller (merge
        current-user-data
        {lp-staked: updated-user-lp-staked, cycles-to-unstake: (get cycles-to-unstake unstake-data)}
      ))
      (print {
        action: "unstake-lp-tokens",
        caller: caller,
        data: {
          pool-contract: (contract-of pool-trait),
          current-cycle: current-cycle,
          total-lp-staked: updated-total-lp-staked,
          amount: lp-to-unstake,
          cycles-to-unstake: (get cycles-to-unstake unstake-data),
          user-lp-staked: updated-user-lp-staked
        }
      })
      (ok lp-to-unstake)
    )
  )
)

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (filter-cycles-list (value uint)) 
  (if (<= value (var-get helper-value)) 
    true
    false
  )
)

(define-private (filter-next-cycles-list (value uint)) 
  (if (is-some (index-of (var-get helper-list) value))
    false
    true
  )
)

(define-private (filter-unstaked-cycles-list (value uint)) 
  (if (is-eq value (var-get helper-value)) 
    false
    true
  )
)

(define-private (map-filtered-cycles-list (value uint)) 
  (+ (var-get helper-value) value)
)

(define-private (fold-user-data-per-cycle (next-cycle uint) (static-data {amount: uint, cycles-staked: (list 12000 uint)}))
  (let (
    (amount-static (get amount static-data))
    (user-cycle-data (default-to {lp-staked: u0, lp-to-unstake: u0} (map-get? user-data-at-cycle {user: tx-sender, cycle: next-cycle})))
    (cycle-lp-data (map-get? lp-staked-at-cycle next-cycle))
    (caller tx-sender)
  )
    (if (is-some (index-of (get cycles-staked static-data) next-cycle))
      (map-set user-data-at-cycle {user: caller, cycle: next-cycle} (merge 
        user-cycle-data
        {lp-staked: (+ amount-static (get lp-staked user-cycle-data))}
      ))
      (map-set user-data-at-cycle {user: caller, cycle: next-cycle} (merge 
        user-cycle-data
        {lp-staked: amount-static}
      ))
    )
    (if (is-some cycle-lp-data)
      (map-set lp-staked-at-cycle next-cycle (+ amount-static (default-to u0 cycle-lp-data)))
      (map-set lp-staked-at-cycle next-cycle amount-static)
    )
    static-data
  )
)

(define-private (fold-cycles-to-unstakeable-cycles (cycle uint) (static-data {lp-to-unstake: uint, cycles-to-unstake: (list 12000 uint)})) 
  (let (
    (lp-to-unstake-static (get lp-to-unstake static-data))
    (user-cycle-data (match (map-get? user-data-at-cycle {user: tx-sender, cycle: cycle}) 
      unwrapped-value
        unwrapped-value
      {lp-staked: u0, lp-to-unstake: u0}
    ))      
    (user-lp-to-unstake (get lp-to-unstake user-cycle-data))
    (helper-value-for-filter (var-set helper-value cycle))
    (filtered-cycles-to-unstake (filter filter-unstaked-cycles-list (get cycles-to-unstake static-data)))
    (caller tx-sender)
  )
    (if (and (> user-lp-to-unstake u0) (<= cycle (get-current-cycle)))
      (begin 
        (map-set user-data-at-cycle {user: caller, cycle: cycle} (merge 
          user-cycle-data
          {lp-to-unstake: u0}
        ))
        {lp-to-unstake: (+ user-lp-to-unstake lp-to-unstake-static), cycles-to-unstake: filtered-cycles-to-unstake}
      )
      static-data
    )
  )
)
```
