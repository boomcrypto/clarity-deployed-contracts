---
title: "Trait xyk-staking-sbtc-bdc-v-1-1"
draft: true
---
```
;; xyk-staking-sbtc-bdc-v-1-1

(define-constant ERR_NOT_AUTHORIZED (err u4001))
(define-constant ERR_INVALID_AMOUNT (err u4002))
(define-constant ERR_INVALID_PRINCIPAL (err u4003))
(define-constant ERR_ALREADY_ADMIN (err u4004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u4005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u4006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u4007))
(define-constant ERR_STAKING_DISABLED (err u4008))
(define-constant ERR_EARLY_UNSTAKE_DISABLED (err u4009))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u4010))
(define-constant ERR_INVALID_STAKING_DURATION (err u4011))
(define-constant ERR_INVALID_MIN_STAKING_DURATION (err u4012))
(define-constant ERR_INVALID_MAX_STAKING_DURATION (err u4013))
(define-constant ERR_CYCLES_STAKED_OVERFLOW (err u4014))
(define-constant ERR_CYCLES_TO_UNSTAKE_OVERFLOW (err u4015))
(define-constant ERR_NO_USER_DATA (err u4016))
(define-constant ERR_NO_EARLY_LP_TO_UNSTAKE (err u4017))
(define-constant ERR_INVALID_FEE (err u4018))
(define-constant ERR_HEIGHT_BEFORE_DEPLOYMENT (err u4019))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant CYCLES_LIST (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
                             u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
                             u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60
                             u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80
                             u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100
                             u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116
                             u117 u118 u119 u120))

(define-constant DEPLOYMENT_HEIGHT u875109)
(define-constant CYCLE_LENGTH u144)

(define-constant BPS u10000)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var helper-value uint u0)
(define-data-var helper-list (list 12000 uint) (list ))

(define-data-var staking-status bool true)
(define-data-var early-unstake-status bool true)

(define-data-var early-unstake-fee-address principal tx-sender)
(define-data-var early-unstake-fee uint u50)

(define-data-var minimum-staking-duration uint u1)
(define-data-var maximum-staking-duration uint u120)

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

(define-read-only (get-deployment-height) 
  (ok DEPLOYMENT_HEIGHT)
)

(define-read-only (get-current-cycle) 
  (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH)
)

(define-read-only (get-cycle-from-height (height uint)) 
  (begin
    (asserts! (>= height DEPLOYMENT_HEIGHT) ERR_HEIGHT_BEFORE_DEPLOYMENT)
    (ok (/ (- height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
  )
)

(define-read-only (get-starting-height-from-cycle (cycle uint)) 
  (ok (+ DEPLOYMENT_HEIGHT (* cycle CYCLE_LENGTH)))
)

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

(define-read-only (get-early-unstake-status)
  (ok (var-get early-unstake-status))
)

(define-read-only (get-early-unstake-fee-address)
  (ok (var-get early-unstake-fee-address))
)

(define-read-only (get-early-unstake-fee)
  (ok (var-get early-unstake-fee))
)

(define-read-only (get-minimum-staking-duration)
  (ok (var-get minimum-staking-duration))
)

(define-read-only (get-maximum-staking-duration)
  (ok (var-get maximum-staking-duration))
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
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removable admins-list))
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
      (print {action: "set-staking-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-early-unstake-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (var-set early-unstake-status status)
      (print {action: "set-early-unstake-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-early-unstake-fee-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      (var-set early-unstake-fee-address address)
      (print {action: "set-early-unstake-fee-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

(define-public (set-early-unstake-fee (fee uint))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (< fee BPS) ERR_INVALID_FEE)
      (var-set early-unstake-fee fee)
      (print {action: "set-early-unstake-fee", caller: caller, data: {fee: fee}})
      (ok true)
    )
  )
)

(define-public (set-staking-duration (min-duration uint) (max-duration uint))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (and (> min-duration u0) (<= min-duration max-duration)) ERR_INVALID_MIN_STAKING_DURATION)
      (asserts! (< max-duration u121) ERR_INVALID_MAX_STAKING_DURATION)
      (var-set minimum-staking-duration min-duration)
      (var-set maximum-staking-duration max-duration)
      (print {
        action: "set-staking-duration",
        caller: caller,
        data: {
          min-duration: min-duration,
          max-duration: max-duration
        }
      })
      (ok true)
    )
  )
)

(define-public (stake-lp-tokens (amount uint) (cycles uint))
  (let (
    (caller tx-sender)
    (current-user-data (map-get? user-data caller))
    (user-cycles-staked (default-to (list ) (get cycles-staked current-user-data)))
    (user-cycles-to-unstake (default-to (list ) (get cycles-to-unstake current-user-data)))
    (helper-value-for-filter (var-set helper-value cycles))
    (filtered-cycles-list (filter filter-values-lte-helper-value CYCLES_LIST))
    (current-cycle (get-current-cycle))
    (helper-value-for-map (var-set helper-value current-cycle))
    (next-cycles (map sum-with-helper-value filtered-cycles-list))
    (helper-list-for-filter (var-set helper-list user-cycles-staked))
    (filtered-next-cycles-list (filter filter-out-values-contained-in-helper-list next-cycles))
    (cycle-to-unstake (+ u1 current-cycle cycles))
    (user-data-at-unstaking-cycle (map-get? user-data-at-cycle {user: caller, cycle: cycle-to-unstake}))
    (updated-total-lp-staked (+ (var-get total-lp-staked) amount))
    (updated-user-lp-staked (+ (default-to u0 (get lp-staked current-user-data)) amount))
  )
    (begin
      (asserts! (is-eq (var-get staking-status) true) ERR_STAKING_DISABLED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (and (>= cycles (var-get minimum-staking-duration)) (<= cycles (var-get maximum-staking-duration))) ERR_INVALID_STAKING_DURATION)
      (try! (transfer-lp-token amount caller (as-contract tx-sender)))
      (fold fold-user-data-per-cycle next-cycles {amount: amount, cycles-staked: user-cycles-staked})
      (var-set total-lp-staked updated-total-lp-staked)
      (if (is-some current-user-data)
        (map-set user-data caller {
          cycles-staked: (unwrap! (as-max-len? (concat user-cycles-staked filtered-next-cycles-list) u12000) ERR_CYCLES_STAKED_OVERFLOW),
          cycles-to-unstake: (if (is-some (index-of user-cycles-to-unstake cycle-to-unstake))
            user-cycles-to-unstake
            (unwrap! (as-max-len? (concat user-cycles-to-unstake (list cycle-to-unstake)) u12000) ERR_CYCLES_TO_UNSTAKE_OVERFLOW)
          ),
          lp-staked: updated-user-lp-staked
        })
        (map-set user-data caller {
          cycles-staked: next-cycles,
          cycles-to-unstake: (list cycle-to-unstake),
          lp-staked: amount
        })
      )
      (if (is-some user-data-at-unstaking-cycle)
        (map-set user-data-at-cycle {user: caller, cycle: cycle-to-unstake} (merge 
          (default-to {lp-staked: u0, lp-to-unstake: u0} user-data-at-unstaking-cycle)
          {lp-to-unstake: (+ amount (default-to u0 (get lp-to-unstake user-data-at-unstaking-cycle)))}
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
          current-cycle: current-cycle,
          total-lp-staked: updated-total-lp-staked,
          amount: amount,
          cycles: cycles,
          cycle-to-unstake: cycle-to-unstake,
          user-lp-staked: updated-user-lp-staked
        }
      })
      (ok {amount: amount, cycles: cycles})
    )   
  )
)

(define-public (unstake-lp-tokens)
  (let (
    (caller tx-sender)
    (current-cycle (get-current-cycle))
    (helper-value-current-cycle (var-set helper-value current-cycle))
    (current-user-data (unwrap! (map-get? user-data caller) ERR_NO_USER_DATA))
    (user-cycles-to-unstake (get cycles-to-unstake current-user-data))
    (filtered-user-cycles-to-unstake (filter filter-values-lte-helper-value user-cycles-to-unstake))
    (user-lp-staked (get lp-staked current-user-data))
    (unstake-data (fold fold-cycles-to-unstakeable-cycles filtered-user-cycles-to-unstake {lp-to-unstake: u0, cycles-to-unstake: filtered-user-cycles-to-unstake}))
    (lp-to-unstake (get lp-to-unstake unstake-data))
    (updated-user-lp-staked (- user-lp-staked lp-to-unstake))
    (updated-total-lp-staked (- (var-get total-lp-staked) lp-to-unstake))
  )
    (begin
      (if (> lp-to-unstake u0)
        (begin
          (try! (as-contract (transfer-lp-token lp-to-unstake tx-sender caller)))
          (var-set total-lp-staked updated-total-lp-staked)
          (map-set user-data caller (merge
            current-user-data
            {lp-staked: updated-user-lp-staked, cycles-to-unstake: (get cycles-to-unstake unstake-data)}
          )))
        false
      )
      (print {
        action: "unstake-lp-tokens",
        caller: caller,
        data: {
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

(define-public (early-unstake-lp-tokens)
  (let (
    (caller tx-sender)
    (unstake-matured-user-lp (try! (unstake-lp-tokens)))
    (current-cycle (get-current-cycle))
    (current-user-data (unwrap! (map-get? user-data caller) ERR_NO_USER_DATA))
    (user-cycles-staked (get cycles-staked current-user-data))
    (unstake-data (fold fold-early-unstake-per-cycle user-cycles-staked {current-cycle: current-cycle, lp-to-unstake: u0}))
    (early-lp-to-unstake-total (get lp-staked current-user-data))
    (early-lp-to-unstake-fees (/ (* early-lp-to-unstake-total (var-get early-unstake-fee)) BPS))
    (early-lp-to-unstake-user (- early-lp-to-unstake-total early-lp-to-unstake-fees))
    (updated-total-lp-staked (- (var-get total-lp-staked) early-lp-to-unstake-total))
  )
    (begin
      (asserts! (is-eq (var-get early-unstake-status) true) ERR_EARLY_UNSTAKE_DISABLED)
      (asserts! (> early-lp-to-unstake-total u0) ERR_NO_EARLY_LP_TO_UNSTAKE)
      (try! (as-contract (transfer-lp-token early-lp-to-unstake-user tx-sender caller)))
      (if (> early-lp-to-unstake-fees u0)
        (try! (as-contract (transfer-lp-token early-lp-to-unstake-fees tx-sender (var-get early-unstake-fee-address))))
        false
      )
      (var-set total-lp-staked updated-total-lp-staked)
      (map-set user-data caller (merge 
        current-user-data
        {cycles-to-unstake: (list ), lp-staked: u0}
      ))
      (print {
        action: "early-unstake-lp-tokens",
        caller: caller,
        data: {
          current-cycle: current-cycle,
          total-lp-staked: updated-total-lp-staked,
          matured-lp-to-unstake-user: unstake-matured-user-lp,
          early-lp-to-unstake-total: early-lp-to-unstake-total,
          early-lp-to-unstake-fees: early-lp-to-unstake-fees,
          early-lp-to-unstake-user: early-lp-to-unstake-user,
          cycles-to-unstake: user-cycles-staked,
          user-lp-staked: u0
        }
      })
      (ok {matured-lp-to-unstake-user: unstake-matured-user-lp, early-lp-to-unstake-user: early-lp-to-unstake-user})
    )
  )
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (filter-values-lte-helper-value (value uint)) 
  (<= value (var-get helper-value))
)

(define-private (filter-out-values-contained-in-helper-list (value uint)) 
  (not (is-some (index-of (var-get helper-list) value)))
)

(define-private (filter-out-values-eq-to-helper-value (value uint)) 
  (not (is-eq value (var-get helper-value)))
)

(define-private (sum-with-helper-value (value uint)) 
  (+ (var-get helper-value) value)
)

(define-private (fold-user-data-per-cycle (next-cycle uint) (static-data {amount: uint, cycles-staked: (list 12000 uint)}))
  (let (
    (caller tx-sender)
    (amount-static (get amount static-data))
    (user-cycle-data (default-to {lp-staked: u0, lp-to-unstake: u0} (map-get? user-data-at-cycle {user: caller, cycle: next-cycle})))
    (cycle-lp-data (map-get? lp-staked-at-cycle next-cycle))
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
    (caller tx-sender)
    (lp-to-unstake-static (get lp-to-unstake static-data))
    (user-cycle-data (default-to {lp-staked: u0, lp-to-unstake: u0} (map-get? user-data-at-cycle {user: caller, cycle: cycle})))
    (user-lp-to-unstake (get lp-to-unstake user-cycle-data))
    (helper-value-for-filter (var-set helper-value cycle))
    (filtered-cycles-to-unstake (filter filter-out-values-eq-to-helper-value (get cycles-to-unstake static-data)))
  )
    (if (> user-lp-to-unstake u0)
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

(define-private (fold-early-unstake-per-cycle (cycle uint) (static-data {current-cycle: uint, lp-to-unstake: uint})) 
  (let (
    (caller tx-sender)
    (current-cycle-static (get current-cycle static-data))
    (lp-to-unstake-static (get lp-to-unstake static-data))
    (user-cycle-data (default-to {lp-staked: u0, lp-to-unstake: u0} (map-get? user-data-at-cycle {user: caller, cycle: cycle})))
    (cycle-lp-data (map-get? lp-staked-at-cycle cycle))
    (user-lp-staked (get lp-staked user-cycle-data))
  )
    (if (and (> user-lp-staked u0) (> cycle current-cycle-static))
      (begin
        (map-delete user-data-at-cycle {user: caller, cycle: cycle})
        (if (is-some cycle-lp-data)
          (map-set lp-staked-at-cycle cycle (- (default-to u0 cycle-lp-data) user-lp-staked))
          false
        )
        {current-cycle: current-cycle-static, lp-to-unstake: (+ user-lp-staked lp-to-unstake-static)}
      )
      static-data
    )
  )
)

(define-private (transfer-lp-token (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-bdc-v-1-1 transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)
```
