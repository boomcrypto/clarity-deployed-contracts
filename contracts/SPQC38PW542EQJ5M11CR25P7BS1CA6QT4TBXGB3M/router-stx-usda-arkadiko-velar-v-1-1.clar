;; router-stx-usda-arkadiko-velar-v-1-1

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_SWAP_STATUS (err u4001))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var swap-status bool true)

(define-read-only (get-admins)
  (ok (var-get admins))
)

(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

(define-read-only (get-swap-status)
  (ok (var-get swap-status))
)

(define-read-only (get-quote-a
    (amount uint)
    (id uint) (reversed bool)
    (swap-fee (tuple (num uint) (den uint)))
  )
  (let (
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   amount
                   r0 r1
                   swap-fee)))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dy
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                           quote-a)))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-b
    (amount uint)
    (id uint) (reversed bool)
    (swap-fee (tuple (num uint) (den uint)))
  )
  (let (
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dx
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                           amount)))
    (quote-b (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   quote-a
                   r0 r1
                   swap-fee)))
  )
    (ok quote-b)
  )
)

(define-public (set-swap-status (status bool))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (var-set swap-status status)
      (print {action: "set-swap-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    (asserts! (is-standard admin) ERR_INVALID_PRINCIPAL)
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
    (asserts! (is-standard admin) ERR_INVALID_PRINCIPAL)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removeable admins-list))
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to amount) ERR_SWAP_A))
    (swap-b (unwrap! (arkadiko-a swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: caller, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (unwrap! (arkadiko-b amount) ERR_SWAP_A))
    (swap-b (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: caller, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (arkadiko-a (dx uint))
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                  dx u1)))
  )
    (ok (default-to u0 (element-at? swap-a u1)))
  )
)

(define-private (arkadiko-b (dy uint))
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                  dy u1)))
  )
    (ok (default-to u0 (element-at? swap-a u0)))
  )
)

(define-private (velar-a
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (amt-in uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
                  id 
                  token0 token1
                  token-in token-out
                  share-fee-to
                  amt-in u1)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)
