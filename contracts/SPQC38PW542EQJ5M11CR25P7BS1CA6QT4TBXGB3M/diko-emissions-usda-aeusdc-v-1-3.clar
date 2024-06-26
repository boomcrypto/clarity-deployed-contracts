;; diko-emissions-usda-aeusdc-v-1-3

(define-constant ERR_NOT_AUTHORIZED (err "ERR_NOT_AUTHORIZED"))
(define-constant ERR_NOT_WHITELISTED (err "ERR_NOT_WHITELISTED"))
(define-constant ERR_ALREADY_ADMIN (err "ERR_ALREADY_ADMIN"))
(define-constant ERR_ADMIN_OVERFLOW (err "ERR_ADMIN_OVERFLOW"))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err "ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER"))
(define-constant ERR_CLAIM_STATUS (err "ERR_CLAIM_STATUS"))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err "ERR_TOKEN_TRANSFER_FAILED"))
(define-constant ERR_INVALID_CYCLE_REWARDS_EXPIRATION_LIMIT (err "ERR_INVALID_CYCLE_REWARDS_EXPIRATION_LIMIT"))
(define-constant ERR_INVALID_AMOUNT (err "ERR_INVALID_AMOUNT"))
(define-constant ERR_INVALID_CYCLE (err "ERR_INVALID_CYCLE"))
(define-constant ERR_NO_CYCLE_DATA (err "ERR_NO_CYCLE_DATA"))
(define-constant ERR_NO_CYCLE_DATA_EXTERNAL (err "ERR_NO_CYCLE_DATA_EXTERNAL"))
(define-constant ERR_NO_CYCLE_USER_DATA_EXTERNAL (err "ERR_NO_CYCLE_USER_DATA_EXTERNAL"))
(define-constant ERR_CYCLE_REWARDS_NOT_EXPIRED (err "ERR_CYCLE_NOT_EXPIRED"))
(define-constant ERR_CYCLE_FINISHED (err "ERR_CYCLE_FINISHED"))
(define-constant ERR_ALL_CYCLE_REWARDS_CLAIMED (err "ERR_ALL_CYCLE_REWARDS_CLAIMED"))
(define-constant ERR_CYCLE_USER_REWARDS_CLAIMED (err "ERR_CYCLE_USER_REWARDS_CLAIMED"))
(define-constant ERR_CYCLE_NO_USER_REWARDS (err "ERR_CYCLE_NO_USER_REWARDS"))
(define-constant ERR_CYCLE_REWARDS_TOO_HIGH (err "ERR_CYCLE_REWARDS_TOO_HIGH"))

(define-constant DEPLOYMENT_HEIGHT u835413)
(define-constant CYCLE_LENGTH u144)
(define-constant CONTRACT_DEPLOYER tx-sender)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var helper-principal principal tx-sender)
(define-data-var claim-status bool true)
(define-data-var cycle-rewards-expiration-limit uint u30)
(define-data-var total-unclaimed-cycle-rewards uint u0)

(define-map cycles uint {total-rewards: uint, claimed-rewards: uint, unclaimed-rewards: uint})
(define-map user-at-cycle {user: principal, cycle: uint} {claimed: bool})

(define-read-only (get-admins)
  (ok (var-get admins))
)

(define-read-only (get-helper-principal)
  (ok (var-get helper-principal))
)

(define-read-only (get-claim-status)
  (ok (var-get claim-status))
)

(define-read-only (get-cycle-rewards-expiration-limit)
  (ok (var-get cycle-rewards-expiration-limit))
)

(define-read-only (get-total-unclaimed-cycle-rewards)
  (ok (var-get total-unclaimed-cycle-rewards))
)

(define-read-only (get-cycle (cycle uint))
  (ok (default-to {total-rewards: u0, claimed-rewards: u0, unclaimed-rewards: u0} (map-get? cycles cycle)))
)

(define-read-only (get-user-at-cycle (user principal) (cycle uint))
  (ok (default-to {claimed: false} (map-get? user-at-cycle {user: user, cycle: cycle})))
)

(define-read-only (get-user-rewards-at-cycle (user principal) (cycle uint))
  (let (
    (current-cycle (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
    (cycle-data (unwrap! (map-get? cycles cycle) ERR_NO_CYCLE_DATA))
    (cycle-user-data (default-to {claimed: false} (map-get? user-at-cycle {user: user, cycle: cycle})))
    (cycle-user-claimed (get claimed cycle-user-data))
    (cycle-user-data-external (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-3 get-user-data-at-cycle 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 user cycle) ERR_NO_CYCLE_USER_DATA_EXTERNAL))
    (cycle-user-lp-staked (get lp-token-staked cycle-user-data-external))
    (cycle-total-lp-staked-external (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-3 get-data-at-cycle 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 cycle) ERR_NO_CYCLE_DATA_EXTERNAL))
    (cycle-rewards (/ (* (get total-rewards cycle-data) cycle-user-lp-staked) cycle-total-lp-staked-external))
  )
    (asserts! (is-eq (var-get claim-status) true) ERR_CLAIM_STATUS)
    (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
    (asserts! (> (get unclaimed-rewards cycle-data) u0) ERR_ALL_CYCLE_REWARDS_CLAIMED)
    (asserts! (not cycle-user-claimed) ERR_CYCLE_USER_REWARDS_CLAIMED)
    (asserts! (> cycle-rewards u0) ERR_CYCLE_NO_USER_REWARDS)
    (asserts! (<= cycle-rewards (get unclaimed-rewards cycle-data)) ERR_CYCLE_REWARDS_TOO_HIGH)
    (ok {unclaimed-rewards: cycle-rewards})
  )
)

(define-public (add-admin (admin principal))
  (let (
    (current-admins (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of current-admins admin)) ERR_ALREADY_ADMIN)
    (print {action: "add-admin", caller: caller, admin: admin})
    (ok (var-set admins (unwrap! (as-max-len? (append current-admins admin) u5) ERR_ADMIN_OVERFLOW)))
  )
)

(define-public (remove-admin (admin principal))
  (let (
    (current-admin-list (var-get admins))
    (caller-principal-position-in-list (index-of current-admin-list tx-sender))
    (removeable-principal-position-in-list (index-of current-admin-list admin))
    (caller tx-sender)
  )
    (asserts! (is-some caller-principal-position-in-list) ERR_NOT_AUTHORIZED)
    (asserts! (is-some removeable-principal-position-in-list) ERR_NOT_WHITELISTED)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set helper-principal admin)
    (print {action: "remove-admin", caller: caller, admin: admin})
    (ok (var-set admins (filter is-not-removeable current-admin-list)))
  )
)

(define-public (set-claim-status (status bool))
  (let (
    (current-admins (var-get admins))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
      (var-set claim-status status)
      (print {action: "set-claim-status", caller: caller, status: status})
      (ok true)
    )
  )
)

(define-public (set-cycle-rewards-expiration-limit (limit uint))
  (let (
    (current-admins (var-get admins))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
      (asserts! (>= limit u30) ERR_INVALID_CYCLE_REWARDS_EXPIRATION_LIMIT)
      (var-set cycle-rewards-expiration-limit limit)
      (print {action: "set-cycle-rewards-expiration-limit", caller: caller, limit: limit})
      (ok true)
    )
  )
)

(define-public (set-cycle-rewards (cycle uint) (amount uint))
  (let (
    (current-admins (var-get admins))
    (current-cycle (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
    (cycle-data (default-to {total-rewards: u0, claimed-rewards: u0, unclaimed-rewards: u0} (map-get? cycles cycle)))
    (updated-total-unclaimed-cycle-rewards (+ (- (var-get total-unclaimed-cycle-rewards) (get unclaimed-rewards cycle-data)) amount))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> cycle current-cycle) ERR_CYCLE_FINISHED)
      (map-set cycles cycle {total-rewards: amount, claimed-rewards: u0, unclaimed-rewards: amount})
      (var-set total-unclaimed-cycle-rewards updated-total-unclaimed-cycle-rewards)
      (print {action: "set-cycle-rewards", caller: caller, cycle: cycle, amount: amount})
      (ok true)
    )
  )
)

(define-public (clear-expired-cycle-rewards (cycle uint))
  (let (
    (current-admins (var-get admins))
    (current-cycle (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
    (cycle-data (unwrap! (map-get? cycles cycle) ERR_NO_CYCLE_DATA))
    (updated-total-unclaimed-cycle-rewards (- (var-get total-unclaimed-cycle-rewards) (get unclaimed-rewards cycle-data)))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (>= (- current-cycle cycle) (var-get cycle-rewards-expiration-limit)) ERR_CYCLE_REWARDS_NOT_EXPIRED)
      (map-set cycles cycle (merge cycle-data {unclaimed-rewards: u0}))
      (var-set total-unclaimed-cycle-rewards updated-total-unclaimed-cycle-rewards)
      (print {action: "clear-expired-cycle-rewards", caller: caller, cycle: cycle})
      (ok true)
    )
  )
)

(define-public (withdraw-cycle-rewards (amount uint) (recipient principal))
  (let (
    (current-admins (var-get admins))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of current-admins caller)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer amount tx-sender recipient none)) ERR_TOKEN_TRANSFER_FAILED)
      (print {action: "withdraw-cycle-rewards", caller: caller, amount: amount, recipient: recipient})
      (ok true)
    )
  )
)

(define-public (claim-cycle-rewards (cycle uint))
  (let (
    (current-cycle (/ (- burn-block-height DEPLOYMENT_HEIGHT) CYCLE_LENGTH))
    (cycle-data (unwrap! (map-get? cycles cycle) ERR_NO_CYCLE_DATA))
    (cycle-user-data (default-to {claimed: false} (map-get? user-at-cycle {user: tx-sender, cycle: cycle})))
    (cycle-user-claimed (get claimed cycle-user-data))
    (cycle-user-data-external (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-3 get-user-data-at-cycle 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 tx-sender cycle) ERR_NO_CYCLE_USER_DATA_EXTERNAL))
    (cycle-user-lp-staked (get lp-token-staked cycle-user-data-external))
    (cycle-total-lp-staked-external (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-3 get-data-at-cycle 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 cycle) ERR_NO_CYCLE_DATA_EXTERNAL))
    (cycle-rewards (/ (* (get total-rewards cycle-data) cycle-user-lp-staked) cycle-total-lp-staked-external))
    (updated-total-unclaimed-cycle-rewards (- (var-get total-unclaimed-cycle-rewards) cycle-rewards))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get claim-status) true) ERR_CLAIM_STATUS)
      (asserts! (< cycle current-cycle) ERR_INVALID_CYCLE)
      (asserts! (> (get unclaimed-rewards cycle-data) u0) ERR_ALL_CYCLE_REWARDS_CLAIMED)
      (asserts! (not cycle-user-claimed) ERR_CYCLE_USER_REWARDS_CLAIMED)
      (asserts! (> cycle-rewards u0) ERR_CYCLE_NO_USER_REWARDS)
      (asserts! (<= cycle-rewards (get unclaimed-rewards cycle-data)) ERR_CYCLE_REWARDS_TOO_HIGH)
      (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer cycle-rewards tx-sender caller none)) ERR_TOKEN_TRANSFER_FAILED)
      (map-set user-at-cycle {user: caller, cycle: cycle} (merge cycle-user-data {claimed: true}))
      (map-set cycles cycle (merge cycle-data {claimed-rewards: (+ (get claimed-rewards cycle-data) cycle-rewards), unclaimed-rewards: (- (get unclaimed-rewards cycle-data) cycle-rewards)}))
      (var-set total-unclaimed-cycle-rewards updated-total-unclaimed-cycle-rewards)
      (print {action: "claim-cycle-rewards", caller: caller, cycle: cycle, cycle-rewards: cycle-rewards})
      (ok true)
    )
  )
)

(define-public (set-cycle-rewards-multi (cycles-list (list 120 uint)) (amount (list 120 uint)))
  (ok (map set-cycle-rewards cycles-list amount))
)

(define-public (clear-expired-cycle-rewards-multi (cycles-list (list 120 uint)))
  (ok (map clear-expired-cycle-rewards cycles-list))
)

(define-public (claim-cycle-rewards-multi (cycles-list (list 120 uint)))
  (ok (map claim-cycle-rewards cycles-list))
)

(define-private (is-not-removeable (admin principal))
  (not (is-eq admin (var-get helper-principal)))
)