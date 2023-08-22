;; @contract Reverse Bonds
;; @version 1.1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u5103001)
(define-constant ERR-CONTRACT-DISABLED u4101001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var treasury-balances-block-height uint block-height)

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-is-enabled bool false)

;; ------------------------------------------
;; Getters
;; ------------------------------------------

;; Current contract balances
(define-read-only (contract-balances)
  (let (
    (balance-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance (as-contract tx-sender))))
    (balance-stx (stx-get-balance (as-contract tx-sender)))
    (balance-xbtc (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance (as-contract tx-sender))))
    (balance-diko (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance (as-contract tx-sender))))
    (balance-alex (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-balance (as-contract tx-sender))))
  )
    (ok {
      usda: balance-usda,
      stx: balance-stx,
      xbtc: balance-xbtc,
      diko: balance-diko,
      alex: balance-alex 
    })
  )
)

;; Amounts user should receive based on current LDN
(define-read-only (user-receive (user principal))
  (let (
    (user-amount (unwrap-panic (contract-call? .lydian-token get-balance user)))
    (total-amount (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (token-balances (unwrap-panic (contract-balances)))
  )
    (ok {
      usda: (/ (* user-amount (get usda token-balances)) total-amount),
      stx: (/ (* user-amount (get stx token-balances)) total-amount),
      xbtc: (/ (* user-amount (get xbtc token-balances)) total-amount),
      diko: (/ (* user-amount (get diko token-balances)) total-amount),
      alex: (/ (* user-amount (get alex token-balances)) total-amount) 
    })
  )
)

;; ------------------------------------------
;; Reverse bond
;; ------------------------------------------

(define-public (reverse-bond)
  (begin
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (reverse-bond-helper)
  )
)

(define-public (reverse-bond-owner)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (reverse-bond-helper)
  )
)

;; Execute
(define-private (reverse-bond-helper)
  (let (
    (receiver tx-sender)

    (ldn-to-burn (unwrap-panic (contract-call? .lydian-token get-balance receiver)))
    (to-receive (unwrap-panic (user-receive receiver)))
  )
    ;; Transfer and burn
    (if (> ldn-to-burn u0)
      (begin
        (try! (contract-call? .lydian-token transfer ldn-to-burn receiver (as-contract tx-sender) none))
        (try! (as-contract (contract-call? .lydian-token burn tx-sender ldn-to-burn)))
      )
      true
    )

    ;; Get tokens
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (get usda to-receive) tx-sender receiver none)))
    (try! (as-contract (stx-transfer? (get stx to-receive) tx-sender receiver)))
    (try! (as-contract (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer (get xbtc to-receive) tx-sender receiver none)))
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer (get diko to-receive) tx-sender receiver none)))
    (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 transfer (get alex to-receive) tx-sender receiver none)))

    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (set-contract-is-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set contract-is-enabled enabled)
    (ok true)
  )
)

(define-public (set-treasury-balances-block-height (height uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set treasury-balances-block-height height)
    (ok true)
  )
)

(define-public (get-stx-tokens (recipient principal))
  (let (
    (balance (stx-get-balance (as-contract tx-sender)))
  )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? balance tx-sender recipient)))
    (ok true)
  )
)

(define-public (get-sip10-tokens (token-trait <ft-trait>) (recipient principal))
  (let (
    (balance (unwrap-panic (contract-call? token-trait get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (contract-call? token-trait transfer balance tx-sender recipient none)))
    (ok true)
  )
)

;; ------------------------------------------
;; STX
;; ------------------------------------------

(define-public (stx-transfer (amount uint) (receiver principal))
  (stx-transfer? amount tx-sender receiver)
)

(define-read-only (stx-balance (user principal))
  (stx-get-balance user)
)
