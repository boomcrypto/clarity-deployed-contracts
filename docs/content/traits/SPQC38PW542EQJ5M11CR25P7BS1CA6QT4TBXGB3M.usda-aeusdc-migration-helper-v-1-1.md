---
title: "Trait usda-aeusdc-migration-helper-v-1-1"
draft: true
---
```
;; usda-aeusdc-migration-helper-v-1-1

(define-constant ERR_NOT_AUTHORIZED (err "ERR_NOT_AUTHORIZED"))
(define-constant ERR_INVALID_AMOUNT (err "ERR_INVALID_AMOUNT"))
(define-constant ERR_MIGRATION_STATUS (err "ERR_MIGRATION_STATUS"))
(define-constant ERR_WITHDRAW_LIQUIDITY_FAILED (err "ERR_WITHDRAW_LIQUIDITY_FAILED"))
(define-constant ERR_ADD_LIQUIDITY_FAILED (err "ERR_ADD_LIQUIDITY_FAILED"))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err "ERR_TOKEN_TRANSFER_FAILED"))

(define-data-var contract-owner principal tx-sender)
(define-data-var migration-status bool true)

(define-map user-extra-amount principal uint)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-migration-status)
  (ok (var-get migration-status))
)

(define-read-only (get-user-extra-amount (user principal))
  (ok (default-to u0 (map-get? user-extra-amount user)))
)

(define-public (set-contract-owner (owner principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (var-set contract-owner owner)
      (print {action: "set-contract-owner", caller: caller, data: {owner: owner}})
      (ok true)
    )
  )
)

(define-public (set-migration-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (var-set migration-status status)
      (print {action: "set-migration-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-user-extra-amount (user principal) (amount uint))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (map-set user-extra-amount user amount)
      (print {action: "set-user-extra-amount", caller: caller, data: {user: user, amount: amount}})
      (ok true)
    )
  )
)

(define-public (withdraw-lp-tokens (amount uint) (recipient principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (unwrap! (as-contract (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4 transfer amount tx-sender recipient none)) ERR_TOKEN_TRANSFER_FAILED)
      (print {action: "withdraw-lp-tokens", caller: caller, data: {amount: amount, recipient: recipient}})
      (ok true)
    )
  )
)

(define-public (migrate-liquidity (amount uint))
  (let (
    (extra (default-to u0 (map-get? user-extra-amount tx-sender)))
    (withdraw (unwrap! (withdraw-liquidity amount) ERR_WITHDRAW_LIQUIDITY_FAILED))
    (x-amount (get withdrawal-x-balance withdraw))
    (y-amount (get withdrawal-y-balance withdraw))
    (add (unwrap! (add-liquidity x-amount y-amount) ERR_ADD_LIQUIDITY_FAILED))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get migration-status) true) ERR_MIGRATION_STATUS)

      (if (> extra u0)
        (unwrap! (as-contract (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4 transfer extra tx-sender caller none)) ERR_TOKEN_TRANSFER_FAILED)
        false
      )

      (map-set user-extra-amount caller u0)
      (print {action: "migrate-liquidity", caller: caller, data: {amount: amount, x-amount: x-amount, y-amount: y-amount, add: add, extra: extra}})
      (ok true)
    )
  )
)

(define-public (set-user-extra-amount-multi (users (list 120 principal)) (amounts (list 120 uint)))
  (ok (map set-user-extra-amount users amounts))
)

(define-private (add-liquidity (x-amount uint) (y-amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 add-liquidity
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
          x-amount y-amount u0)))
  )
    (ok call)
  )
)

(define-private (withdraw-liquidity (amount uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 withdraw-liquidity
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
          amount u0 u0)))
  )
    (ok call)
  )
)
```
