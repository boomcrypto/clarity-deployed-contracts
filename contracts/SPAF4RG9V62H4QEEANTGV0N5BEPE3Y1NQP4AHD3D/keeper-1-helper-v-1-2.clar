;; keeper-1-helper-v-1-2

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u9001))
(define-constant ERR_INVALID_AMOUNT (err u9002))
(define-constant ERR_ALREADY_ADMIN (err u9003))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u9004))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u9005))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u9006))
(define-constant ERR_KEEPER_STATUS (err u9007))
(define-constant ERR_INVALID_FEE (err u9008))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Maximum BPS
(define-constant BPS u10000)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; Data var used to enable or disable this keeper type
(define-data-var keeper-status bool true)

;; Percent fee taken by this keeper type
(define-data-var keeper-fee uint u0)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get keeper status
(define-read-only (get-keeper-status)
  (ok (var-get keeper-status))
)

;; Get keeper fee
(define-read-only (get-keeper-fee)
  (ok (var-get keeper-fee))
)

;; Get keeper fee for a given amount
(define-read-only (get-keeper-fee-amount (amount uint))
  (ok (/ (* amount (var-get keeper-fee)) BPS))
)

;; Get output for execute-action-a function
(define-public (get-action-a (amount uint))
  (let (
    ;; Assert keeper type is enabled
    (keeper-check (asserts! (var-get keeper-status) ERR_KEEPER_STATUS))

    ;; Assert amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (get-keeper-fee-amount amount) ERR_INVALID_FEE))
    (amount-after-keeper-fee (- amount keeper-fee-amount))

    ;; Get quote for pBTC to STX swap via XYK Core
    (quote-pbtc-to-stx (contract-call?
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-pbtc-stx-v-1-1
                       'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-pBTC
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                       amount-after-keeper-fee))
  )
    ;; Return action data
    (ok {
      amount: amount,
      keeper-fee-amount: keeper-fee-amount,
      quote-pbtc-to-stx: quote-pbtc-to-stx
    })
  )
)

;; Add an admin to the admins list
(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and new admin is not in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)

      ;; Add admin to list with max length of 5
      (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))

      ;; Print add admin data and return true
      (print {action: "add-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and admin to remove is in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)

      ;; Assert contract deployer cannot be removed
      (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)

      ;; Set admin-helper to admin to remove and filter admins-list to remove admin
      (var-set admin-helper admin)
      (var-set admins (filter admin-not-removable admins-list))

      ;; Print remove admin data and return true
      (print {action: "remove-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Enable or disable this keeper type
(define-public (set-keeper-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set keeper-status to status
      (var-set keeper-status status)

      ;; Print function data and return true
      (print {action: "set-keeper-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Set percent fee taken by this keeper type
(define-public (set-keeper-fee (fee uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Assert fee is less than maximum BPS
      (asserts! (< fee BPS) ERR_INVALID_FEE)

      ;; Set keeper-fee to fee
      (var-set keeper-fee fee)

      ;; Print function data and return true
      (print {action: "set-keeper-fee", caller: caller, data: {fee: fee}})
      (ok true)
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)