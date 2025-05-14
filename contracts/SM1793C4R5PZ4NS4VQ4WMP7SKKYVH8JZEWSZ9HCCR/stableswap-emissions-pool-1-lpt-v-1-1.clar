
;; stableswap-emissions-pool-1-lpt-v-1-1

;; Implement Stableswap emissions trait
(impl-trait .stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

(define-constant ERR_NOT_AUTHORIZED (err u2001))
(define-constant ERR_INVALID_AMOUNT (err u2002))
(define-constant ERR_INVALID_PRINCIPAL (err u2003))
(define-constant ERR_ALREADY_ADMIN (err u2004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2007))
(define-constant ERR_CLAIMING_DISABLED (err u2008))
(define-constant ERR_INVALID_CYCLE (err u2009))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u2010))
(define-constant ERR_CANNOT_GET_TOKEN_BALANCE (err u2011))
(define-constant ERR_INSUFFICIENT_TOKEN_BALANCE (err u2012))
(define-constant ERR_REWARDS_ALREADY_CLAIMED (err u2013))
(define-constant ERR_REWARDS_NOT_EXPIRED (err u2014))
(define-constant ERR_REWARDS_EXPIRED (err u2015))
(define-constant ERR_REWARDS_OVERFLOW (err u2016))
(define-constant ERR_NO_CYCLE_DATA (err u2017))
(define-constant ERR_NO_EXTERNAL_USER_DATA (err u2018))
(define-constant ERR_NO_EXTERNAL_CYCLE_DATA (err u2019))
(define-constant ERR_NO_REWARDS_TO_CLAIM (err u2020))
(define-constant ERR_MINIMUM_REWARDS_EXPIRATION (err u2021))
(define-constant ERR_HEIGHT_BEFORE_DEPLOYMENT (err u2022))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant DEPLOYMENT_HEIGHT u890153)
(define-constant CYCLE_LENGTH u144)

(define-constant MIN_REWARDS_EXPIRATION u7)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var claim-status bool true)

(define-data-var total-unclaimed-rewards uint u0)
(define-data-var rewards-expiration uint u365)

(define-map cycle-data uint {
  total-rewards: uint,
  claimed-rewards: uint,
  unclaimed-rewards: uint
})

(define-map user-claimed-at-cycle {user: principal, cycle: uint} bool)

(define-read-only (get-deployment-height) 
  (ok DEPLOYMENT_HEIGHT)
)

(define-read-only (get-current-cycle) 
  (ok (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
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

(define-read-only (get-claim-status)
  (ok (var-get claim-status))
)

(define-read-only (get-total-unclaimed-rewards)
  (ok (var-get total-unclaimed-rewards))
)

(define-read-only (get-rewards-expiration)
  (ok (var-get rewards-expiration))
)

(define-read-only (get-cycle (cycle uint))
  (ok (map-get? cycle-data cycle))
)

(define-read-only (get-user-claimed-at-cycle (user principal) (cycle uint))
  (ok (map-get? user-claimed-at-cycle {user: user, cycle: cycle}))
)

(define-read-only (get-user-rewards-at-cycle (user principal) (cycle uint))
  (let (   
    (current-cycle (do-get-current-cycle))
    (target-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (cycle-unclaimed-rewards (get unclaimed-rewards target-cycle-data))
    (user-claimed-at-target-cycle (default-to false (map-get? user-claimed-at-cycle {user: user, cycle: cycle})))
    (user-data-external (try! (get-external-user-data user cycle)))
    (cycle-data-external (try! (get-external-cycle-data cycle)))
    (user-lp-staked (unwrap! (get lp-staked user-data-external) ERR_NO_EXTERNAL_USER_DATA))
    (cycle-lp-staked (unwrap! cycle-data-external ERR_NO_EXTERNAL_CYCLE_DATA))
    (user-rewards (/ (* (get total-rewards target-cycle-data) user-lp-staked) cycle-lp-staked))
  )
    (asserts! (is-eq (var-get claim-status) true) ERR_CLAIMING_DISABLED)
    (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
    (asserts! (<= (- current-cycle cycle) (var-get rewards-expiration)) ERR_REWARDS_EXPIRED)
    (asserts! (and (> cycle-unclaimed-rewards u0) (> user-rewards u0)) ERR_NO_REWARDS_TO_CLAIM)
    (asserts! (not user-claimed-at-target-cycle) ERR_REWARDS_ALREADY_CLAIMED)
    (asserts! (<= user-rewards cycle-unclaimed-rewards) ERR_REWARDS_OVERFLOW)
    (ok {unclaimed-rewards: user-rewards})
  )
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

(define-public (set-claim-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (var-set claim-status status)
      (print {action: "set-claim-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-rewards-expiration (expiration uint))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (>= expiration MIN_REWARDS_EXPIRATION) ERR_MINIMUM_REWARDS_EXPIRATION)
      (var-set rewards-expiration expiration)
      (print {action: "set-rewards-expiration", caller: caller, data: {expiration: expiration}})
      (ok true)
    )
  )
)

(define-public (set-rewards (cycle uint) (amount uint))
  (let (
    (current-cycle (do-get-current-cycle))
    (target-cycle-data (default-to {total-rewards: u0, claimed-rewards: u0, unclaimed-rewards: u0} (map-get? cycle-data cycle)))
    (contract-balance (try! (get-contract-token-balance)))
    (updated-total-unclaimed-rewards (+ (- (var-get total-unclaimed-rewards) (get unclaimed-rewards target-cycle-data)) amount))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (<= updated-total-unclaimed-rewards contract-balance) ERR_INSUFFICIENT_TOKEN_BALANCE)
      (map-set cycle-data cycle {total-rewards: amount, claimed-rewards: u0, unclaimed-rewards: amount})
      (var-set total-unclaimed-rewards updated-total-unclaimed-rewards)
      (print {
        action: "set-rewards",
        caller: caller,
        data: {
          current-cycle: current-cycle,
          total-unclaimed-rewards: updated-total-unclaimed-rewards,
          cycle: cycle,
          amount: amount
        }
      })
      (ok true)
    )
  )
)

(define-public (clear-expired-rewards (cycle uint))
  (let (
    (current-cycle (do-get-current-cycle))
    (target-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (updated-total-unclaimed-rewards (- (var-get total-unclaimed-rewards) (get unclaimed-rewards target-cycle-data)))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (> (- current-cycle cycle) (var-get rewards-expiration)) ERR_REWARDS_NOT_EXPIRED)
      (map-set cycle-data cycle (merge target-cycle-data {unclaimed-rewards: u0}))
      (var-set total-unclaimed-rewards updated-total-unclaimed-rewards)
      (print {
        action: "clear-expired-rewards",
        caller: caller,
        data: {
          current-cycle: current-cycle,
          total-unclaimed-rewards: updated-total-unclaimed-rewards,
          cycle: cycle
        }
      })
      (ok true)
    )
  )
)

(define-public (withdraw-rewards (amount uint) (recipient principal))
  (let (
    (contract-balance (try! (get-contract-token-balance)))
    (caller contract-caller)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= (- contract-balance amount) (var-get total-unclaimed-rewards)) ERR_INSUFFICIENT_TOKEN_BALANCE)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)
      (try! (as-contract (transfer-rewards-token amount tx-sender recipient)))
      (print {
        action: "withdraw-rewards",
        caller: caller,
        data: {
          amount: amount,
          recipient: recipient
        }
      })
      (ok true)
    )
  )
)

(define-public (claim-rewards (cycle uint))
  (let (
    (caller tx-sender)
    (current-cycle (do-get-current-cycle))
    (target-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (cycle-unclaimed-rewards (get unclaimed-rewards target-cycle-data))
    (user-claimed-at-target-cycle (default-to false (map-get? user-claimed-at-cycle {user: caller, cycle: cycle})))
    (user-data-external (try! (get-external-user-data caller cycle)))
    (cycle-data-external (try! (get-external-cycle-data cycle)))
    (user-lp-staked (unwrap! (get lp-staked user-data-external) ERR_NO_EXTERNAL_USER_DATA))
    (cycle-lp-staked (unwrap! cycle-data-external ERR_NO_EXTERNAL_CYCLE_DATA))
    (user-rewards (/ (* (get total-rewards target-cycle-data) user-lp-staked) cycle-lp-staked))
    (updated-total-unclaimed-rewards (- (var-get total-unclaimed-rewards) user-rewards))
  )
    (begin
      (asserts! (is-eq (var-get claim-status) true) ERR_CLAIMING_DISABLED)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (<= (- current-cycle cycle) (var-get rewards-expiration)) ERR_REWARDS_EXPIRED)
      (asserts! (and (> cycle-unclaimed-rewards u0) (> user-rewards u0)) ERR_NO_REWARDS_TO_CLAIM)
      (asserts! (not user-claimed-at-target-cycle) ERR_REWARDS_ALREADY_CLAIMED)
      (asserts! (<= user-rewards cycle-unclaimed-rewards) ERR_REWARDS_OVERFLOW)
      (try! (as-contract (transfer-rewards-token user-rewards tx-sender caller)))
      (map-set user-claimed-at-cycle {user: caller, cycle: cycle} true)
      (map-set cycle-data cycle (merge target-cycle-data {
        claimed-rewards: (+ (get claimed-rewards target-cycle-data) user-rewards),
        unclaimed-rewards: (- (get unclaimed-rewards target-cycle-data) user-rewards)
      }))
      (var-set total-unclaimed-rewards updated-total-unclaimed-rewards)
      (print {
        action: "claim-rewards",
        caller: caller,
        data: {
          current-cycle: current-cycle,
          cycle-lp-staked: cycle-lp-staked,
          cycle-unclaimed-rewards: cycle-unclaimed-rewards,
          total-unclaimed-rewards: updated-total-unclaimed-rewards,
          cycle: cycle,
          user-rewards: user-rewards,
          user-lp-staked: user-lp-staked
        }
      })
      (ok {user-rewards: user-rewards})
    )
  )
)

(define-public (set-rewards-multi (cycles (list 120 uint)) (amounts (list 120 uint)))
  (ok (map set-rewards cycles amounts))
)

(define-public (clear-expired-rewards-multi (cycles (list 120 uint)))
  (ok (map clear-expired-rewards cycles))
)

(define-public (claim-rewards-multi (cycles (list 120 uint)))
  (ok (map claim-rewards cycles))
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (do-get-current-cycle) 
  (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH)
)

(define-private (transfer-rewards-token (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-3 transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)

(define-private (get-contract-token-balance)
  (let (
    (call-a (unwrap! (contract-call?
                     'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-3 get-balance
                     (as-contract tx-sender)) ERR_CANNOT_GET_TOKEN_BALANCE))
  )
    (ok call-a)
  )
)

(define-private (get-external-user-data (user principal) (cycle uint))
  (let (
    (call-a (unwrap! (contract-call?
                     .stableswap-staking-stx-ststx-v-1-3 get-user-at-cycle
                     user cycle) ERR_NO_EXTERNAL_USER_DATA))
  )
    (ok call-a)
  )
)

(define-private (get-external-cycle-data (cycle uint))
  (let (
    (call-a (unwrap! (contract-call?
                     .stableswap-staking-stx-ststx-v-1-3 get-lp-staked-at-cycle
                     cycle) ERR_NO_EXTERNAL_CYCLE_DATA))
  )
    (ok call-a)
  )
)