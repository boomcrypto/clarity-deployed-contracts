;; router-stableswap-usda-aeusdc-v-1-2

(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-3.stableswap-pool-trait)
(use-trait usda-aeusdc-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u6001))
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_INVALID_PRINCIPAL (err u6003))
(define-constant ERR_ALREADY_ADMIN (err u6004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u6005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u6006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u6007))
(define-constant ERR_SWAP_STATUS (err u6008))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_QUOTE_A (err u6012))
(define-constant ERR_QUOTE_B (err u6013))

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

(define-public (get-quote-a
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (usda-aeusdc-tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (usda-aeusdc-qa amount usda-aeusdc-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (usda-aeusdc-qa quote-a usda-aeusdc-tokens) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (usda-aeusdc-tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (usda-aeusdc-sa amount usda-aeusdc-tokens) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (usda-aeusdc-sa swap-a usda-aeusdc-tokens) ERR_SWAP_B)
                (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          usda-aeusdc-data: {
            usda-aeusdc-tokens: usda-aeusdc-tokens,
            usda-aeusdc-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

(define-private (is-stableswap-path-reversed
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool-contract <stableswap-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not (and (is-eq (contract-of token-in) (get x-token pool-data)) (is-eq (contract-of token-out) (get y-token pool-data))))
  )
)

(define-private (is-usda-aeusdc-path-reversed
    (token-in <usda-aeusdc-ft-trait>) (token-out <usda-aeusdc-ft-trait>)
  )
  (not (and (is-eq (contract-of token-in) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) (is-eq (contract-of token-out) 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)))
)

(define-private (stableswap-qa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 get-dy
                 (get a pools)
                 (get a tokens) (get b tokens)
                 amount))
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 get-dx
                 (get a pools)
                 (get b tokens) (get a tokens)
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (usda-aeusdc-qa
    (amount uint)
    (tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (is-reversed (is-usda-aeusdc-path-reversed (get a tokens) (get b tokens)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 get-dy
                 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                 amount))
                 (try! (contract-call?
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 get-dx
                 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (stableswap-sa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (usda-aeusdc-sa
    (amount uint)
    (tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (is-reversed (is-usda-aeusdc-path-reversed (get a tokens) (get b tokens)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-x-for-y
                      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                      'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                      amount u1))
                (try! (contract-call?
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-y-for-x
                      'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                      amount u1))))
  )
    (ok swap-a)
  )
)