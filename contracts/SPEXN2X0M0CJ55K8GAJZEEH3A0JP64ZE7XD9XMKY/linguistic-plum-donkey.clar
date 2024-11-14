;; xyk-emissions-stx-aeusdc-aeusdc-v-1-1

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_CLAIMING_DISABLED (err u7001))
(define-constant ERR_INVALID_CYCLE (err u7002))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u7003))
(define-constant ERR_REWARDS_ALREADY_CLAIMED (err u7004))
(define-constant ERR_REWARDS_NOT_EXPIRED (err u7005))
(define-constant ERR_REWARDS_OVERFLOW (err u7006))
(define-constant ERR_NO_CYCLE_DATA (err u7007))
(define-constant ERR_NO_EXTERNAL_USER_DATA (err u7008))
(define-constant ERR_NO_EXTERNAL_CYCLE_DATA (err u7009))
(define-constant ERR_NO_REWARDS_TO_CLAIM (err u7010))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant DEPLOYMENT_HEIGHT u855543)
(define-constant CYCLE_LENGTH u144)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var claim-status bool true)

(define-data-var total-unclaimed-rewards uint u0)
(define-data-var rewards-expiration uint u30)

(define-map cycle-data uint {
  total-rewards: uint,
  claimed-rewards: uint,
  unclaimed-rewards: uint
})

(define-map user-data-at-cycle {user: principal, cycle: uint} {
  claimed: bool
})

(define-read-only (get-deployment-height) 
  (ok DEPLOYMENT_HEIGHT)
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

(define-read-only (get-user-at-cycle (user principal) (cycle uint))
  (ok (map-get? user-data-at-cycle {user: user, cycle: cycle}))
)

(define-read-only (get-user-rewards-at-cycle (user principal) (cycle uint))
  (let (   
    (current-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (cycle-unclaimed-rewards (get unclaimed-rewards current-cycle-data))
    (user-data (default-to {claimed: false} (map-get? user-data-at-cycle {user: user, cycle: cycle})))
    (user-data-external (try! (get-external-user-data user cycle)))
    (cycle-data-external (try! (get-external-cycle-data cycle)))
    (user-lp-staked (unwrap-panic (get lp-staked user-data-external)))
    (cycle-lp-staked (unwrap-panic cycle-data-external))
    (user-rewards (/ (* (get total-rewards current-cycle-data) user-lp-staked) cycle-lp-staked))
  )
    (asserts! (is-eq (var-get claim-status) true) ERR_CLAIMING_DISABLED)
    (asserts! (< cycle (get-current-cycle)) ERR_INVALID_CYCLE)
    (asserts! (and (> cycle-unclaimed-rewards u0) (> user-rewards u0)) ERR_NO_REWARDS_TO_CLAIM)
    (asserts! (not (get claimed user-data)) ERR_REWARDS_ALREADY_CLAIMED)
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
      (var-set rewards-expiration expiration)
      (print {action: "set-rewards-expiration", caller: caller, data: {expiration: expiration}})
      (ok true)
    )
  )
)

(define-public (set-rewards (cycle uint) (amount uint))
  (let (
    (current-cycle (get-current-cycle))
    (current-cycle-data (default-to {total-rewards: u0, claimed-rewards: u0, unclaimed-rewards: u0} (map-get? cycle-data cycle)))
    (updated-total-unclaimed-rewards (+ (- (var-get total-unclaimed-rewards) (get unclaimed-rewards current-cycle-data)) amount))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> cycle current-cycle) ERR_INVALID_CYCLE)
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
    (current-cycle (get-current-cycle))
    (current-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (updated-total-unclaimed-rewards (- (var-get total-unclaimed-rewards) (get unclaimed-rewards current-cycle-data)))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (>= (- current-cycle cycle) (var-get rewards-expiration)) ERR_REWARDS_NOT_EXPIRED)
      (map-set cycle-data cycle (merge current-cycle-data {unclaimed-rewards: u0}))
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
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
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
    (current-cycle (get-current-cycle))
    (current-cycle-data (unwrap! (map-get? cycle-data cycle) ERR_NO_CYCLE_DATA))
    (cycle-unclaimed-rewards (get unclaimed-rewards current-cycle-data))
    (user-data (default-to {claimed: false} (map-get? user-data-at-cycle {user: tx-sender, cycle: cycle})))
    (user-data-external (try! (get-external-user-data tx-sender cycle)))
    (cycle-data-external (try! (get-external-cycle-data cycle)))
    (user-lp-staked (unwrap! (get lp-staked user-data-external) ERR_NO_EXTERNAL_USER_DATA))
    (cycle-lp-staked (unwrap! cycle-data-external ERR_NO_EXTERNAL_CYCLE_DATA))
    (user-rewards (/ (* (get total-rewards current-cycle-data) user-lp-staked) cycle-lp-staked))
    (updated-total-unclaimed-rewards (- (var-get total-unclaimed-rewards) user-rewards))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get claim-status) true) ERR_CLAIMING_DISABLED)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (and (> cycle-unclaimed-rewards u0) (> user-rewards u0)) ERR_NO_REWARDS_TO_CLAIM)
      (asserts! (not (get claimed user-data)) ERR_REWARDS_ALREADY_CLAIMED)
      (asserts! (<= user-rewards cycle-unclaimed-rewards) ERR_REWARDS_OVERFLOW)
      (try! (as-contract (transfer-rewards-token user-rewards tx-sender caller)))
      (map-set user-data-at-cycle {user: caller, cycle: cycle} (merge user-data {claimed: true}))
      (map-set cycle-data cycle (merge current-cycle-data {
        claimed-rewards: (+ (get claimed-rewards current-cycle-data) user-rewards),
        unclaimed-rewards: (- (get unclaimed-rewards current-cycle-data) user-rewards)
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

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (transfer-rewards-token (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)

(define-private (get-external-user-data (user principal) (cycle uint))
  (let (
    (call-a (unwrap! (contract-call?
                     'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY.current-amaranth-canid get-user-at-cycle
                     user cycle) ERR_NO_EXTERNAL_USER_DATA))
  )
    (ok call-a)
  )
)

(define-private (get-external-cycle-data (cycle uint))
  (let (
    (call-a (unwrap! (contract-call?
                     'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY.current-amaranth-canid get-lp-staked-at-cycle
                     cycle) ERR_NO_EXTERNAL_CYCLE_DATA))
  )
    (ok call-a)
  )
)