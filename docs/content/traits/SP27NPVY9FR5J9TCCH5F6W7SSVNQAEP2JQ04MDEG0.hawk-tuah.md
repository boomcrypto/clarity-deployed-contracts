---
title: "Trait hawk-tuah"
draft: true
---
```
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token hawk-tuah)

(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-SAME-PRINCIPAL (err u402))
(define-constant ERR-VTRADING-DISABLED (err u403))
(define-constant ERR-SLIPPAGE (err u404))
(define-constant ERR-URI (err u405))
(define-constant ERR-YOU-POOR (err u420))

(define-constant dev-principal 'SP27NPVY9FR5J9TCCH5F6W7SSVNQAEP2JQ04MDEG0)
(define-constant token-supply u69000000)

(define-constant contract-creator tx-sender)
(define-constant initial-virtual-stx-reserve u6000000000)
(define-constant market-cap-threshold u20000000000)
(define-constant fee u25)
(define-constant fee-receiver 'SP3ACDT1G88A4C9XT0MEB9GC3JAMXNFMXV47Q3TYY)
(define-constant liquidity-builder-address 'SP2BN9JN4WEG02QYVX5Y21VMB2JWV3W0KNHPH9R4P)
(define-constant burn-address 'SP000000000000000000002Q6VF78)
(define-constant deploy-fee u300000)

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bafybeiflnityx725i5ygba473cwvsuorwvg4bob6u5upqrareidkzkzlke.ipfs.dweb.link/")) 
(define-data-var virtual-trading-enabled bool false)
(define-data-var virtual-stx-reserve uint u0)
(define-data-var token-reserve uint u0)
(define-data-var real-stx-reserve uint u0)

(define-read-only (get-name) (ok "Hawk Tuah"))
(define-read-only (get-symbol) (ok "HAWK"))
(define-read-only (get-decimals) (ok u0))
(define-read-only (get-balance (user principal)) (ok (ft-get-balance hawk-tuah user)))
(define-read-only (get-total-supply) (ok (ft-get-supply hawk-tuah)))
(define-read-only (get-token-uri) (ok (var-get token-uri)))
(define-read-only (get-vir-trading) (ok (var-get virtual-trading-enabled)))
(define-read-only (get-reserves)
  (ok {
    virtual-stx-reserve: (var-get virtual-stx-reserve),
    real-stx-reserve: (var-get real-stx-reserve),
    token-reserve: (var-get token-reserve)
  })
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq dev-principal tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-some new-uri) ERR-URI)
    (var-set token-uri new-uri)
    (ok new-uri)
  )
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED)
        (asserts! (> amount u0) ERR-YOU-POOR)
        (asserts! (not (is-eq from to)) ERR-SAME-PRINCIPAL)
        (ft-transfer? hawk-tuah amount from to)
    )
)

(define-public (send-many (recipients (list 2000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-public (swap-stx-for-token (stx-amount uint) (min-tokens-out uint)) 
  (begin
    (asserts! (var-get virtual-trading-enabled) ERR-VTRADING-DISABLED)
    (asserts! (> stx-amount u0) ERR-YOU-POOR)
    (let (
      (stx-in stx-amount)
      (stx-fee (/ (* stx-in fee) u10000))
      (stx-in-after-fee (- stx-in stx-fee))
      (current-stx-reserve (+ (var-get real-stx-reserve) (var-get virtual-stx-reserve)))
      (current-token-reserve (var-get token-reserve))
      (k (* current-stx-reserve current-token-reserve))
      (new-stx-reserve (+ current-stx-reserve stx-in-after-fee))
      (new-token-reserve (/ k new-stx-reserve))
      (tokens-out (- current-token-reserve new-token-reserve))
    )
      (asserts! (>= tokens-out min-tokens-out) ERR-SLIPPAGE)
      (try! (stx-transfer? stx-fee tx-sender fee-receiver))
      (try! (stx-transfer? stx-in-after-fee tx-sender (as-contract tx-sender)))
      (var-set real-stx-reserve (+ (var-get real-stx-reserve) stx-in-after-fee))
      (var-set token-reserve new-token-reserve)
      (try! (ft-transfer? hawk-tuah tokens-out (as-contract tx-sender) tx-sender))
      (if (>= (/ (* (+ (var-get real-stx-reserve) (var-get virtual-stx-reserve)) token-supply) (var-get token-reserve)) market-cap-threshold)
        (begin
          (let (
            (vir-stx-reserve (var-get virtual-stx-reserve))
            (total-stx-reserve (+ (var-get real-stx-reserve) vir-stx-reserve))
            (contract-token-reserve (var-get token-reserve))
            (burn-amount (/ (* contract-token-reserve vir-stx-reserve) total-stx-reserve))
            (remaining-tokens (- contract-token-reserve burn-amount))
          )
            (try! (ft-transfer? hawk-tuah burn-amount (as-contract tx-sender) burn-address))
            (try! (ft-transfer? hawk-tuah remaining-tokens (as-contract tx-sender) liquidity-builder-address))
            (try! (as-contract (stx-transfer? (var-get real-stx-reserve) tx-sender liquidity-builder-address)))
            (var-set token-reserve u0)
            (var-set real-stx-reserve u0)
            (var-set virtual-stx-reserve u0)
            (var-set virtual-trading-enabled false)
            (ok tokens-out)
          )
        )
        (ok tokens-out)
      )
    )
  )
)

(define-public (swap-token-for-stx (token-amount uint) (min-stx-out uint) (recipient principal)) 
  (begin
    (asserts! (var-get virtual-trading-enabled) ERR-VTRADING-DISABLED)
    (asserts! (> token-amount u0) ERR-YOU-POOR)
    (asserts! (is-eq tx-sender recipient) ERR-UNAUTHORIZED)
    (let (
      (tokens-in token-amount)
      (current-stx-reserve (+ (var-get real-stx-reserve) (var-get virtual-stx-reserve)))
      (current-token-reserve (var-get token-reserve))
      (k (* current-stx-reserve current-token-reserve))
      (new-token-reserve (+ current-token-reserve tokens-in))
      (new-stx-reserve (/ k new-token-reserve))
      (stx-out (- current-stx-reserve new-stx-reserve))
      (stx-fee (/ (* stx-out fee) u10000))
      (stx-out-after-fee (- stx-out stx-fee))
    )
      (asserts! (>= stx-out-after-fee min-stx-out) ERR-SLIPPAGE)
      (try! (ft-transfer? hawk-tuah token-amount tx-sender (as-contract tx-sender)))
      (var-set real-stx-reserve (- (var-get real-stx-reserve) stx-out))
      (var-set token-reserve new-token-reserve)
      (try! (as-contract (stx-transfer? stx-fee tx-sender fee-receiver)))
      (try! (as-contract (stx-transfer? stx-out-after-fee tx-sender recipient)))
      (ok stx-out-after-fee)
    )
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(begin
  (try! (ft-mint? hawk-tuah token-supply (as-contract tx-sender)))
  (var-set virtual-stx-reserve initial-virtual-stx-reserve)
  (var-set token-reserve token-supply)
  (var-set virtual-trading-enabled true)
  (try! (stx-transfer? deploy-fee tx-sender fee-receiver))
  (ok true)
)
```
