;; title: stxbot-stxcity-dex-proxy by stx.bot & stx.city
;; version: 1.0

;; traits
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 
(use-trait sc-dex-trait .stxcity-dex-trait.stxcity-dex-trait)

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-POINT (err u400))

;; data vars
(define-data-var fee-point uint u100)
(define-data-var fee-receiver principal tx-sender)
(define-data-var contract-owner principal tx-sender)

(define-public (set-fee-point (point uint))
    (begin 
        (try! (check-is-owner))
        (try! (check-is-valid-point point))
        ;; #[allow(unchecked_data)]
        (ok (var-set fee-point point))
    )
)

(define-public (set-fee-receiver (receiver principal))
  (begin
    (try! (check-is-owner))
    ;; #[allow(unchecked_data)]
    (ok (var-set fee-receiver receiver))
  )
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    ;; #[allow(unchecked_data)]
    (ok (var-set contract-owner owner))
  )
)

(define-private (check-is-owner)
    (ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-valid-point (p uint))
    (ok (asserts! (<= p u10000) ERR-INVALID-POINT))
)

(define-private (get-sender)
    (begin 
        (asserts! (is-eq contract-caller tx-sender) ERR-NOT-AUTHORIZED)
        (ok tx-sender)
    )
)

;; read only functions
(define-read-only (get-fee-point)
    (ok (var-get fee-point))
)

(define-read-only (get-fee-receiver)
  (ok (var-get fee-receiver))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-private (balance-of-this (token <sip-010-trait>)) 
    ;; #[allow(unchecked_data)]
    (contract-call? token get-balance (as-contract tx-sender))
)

(define-private (transfer-in-internal (token <sip-010-trait>) (amount uint))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender) 
        )
        (ok 
            (or 
                (is-eq amount u0) 
                (try! (contract-call? token transfer amount sender (as-contract tx-sender) none))
            )
        )
    )
)

(define-private (transfer-out-internal (token <sip-010-trait>) (receiver principal) (amount uint))
    ;; #[allow(unchecked_data)]
    (ok 
        (or 
            (is-eq amount u0) 
            (as-contract (try! (contract-call? token transfer amount (as-contract tx-sender) receiver none)))
        )
    )
)

(define-private (stx-transfer-out-internal (receiver principal) (amount uint))
    ;; #[allow(unchecked_data)]
    (ok 
        (or 
            (is-eq amount u0) 
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) receiver)))
        )
    )
)

(define-public (buy (dex-trait <sc-dex-trait>) (token-trait <sip-010-trait>) (stx-amount uint) )
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (amount-in (/ (* stx-amount (- u10000 (var-get fee-point))) u10000))
        )
        (try! (stx-transfer? stx-amount sender (as-contract tx-sender)))
        (try! (as-contract (contract-call? dex-trait buy token-trait amount-in)))
        (try! (transfer-out-internal token-trait sender (try! (balance-of-this token-trait))))
        (let
            (
                (extra-fee (stx-get-balance (as-contract tx-sender)))
                (receiver (var-get fee-receiver))
            )
            (print {extra-fee: extra-fee, receiver: receiver})
            (ok (try! (stx-transfer-out-internal receiver extra-fee)))
        )
    )
)

(define-public (sell (dex-trait <sc-dex-trait>) (token-trait <sip-010-trait>) (tokens-in uint) )
    ;; #[allow(unchecked_data)]
    (let 
        ( (sender (try! (get-sender))) )
        (try! (contract-call? token-trait transfer tokens-in sender (as-contract tx-sender) none))
        (try! (as-contract (contract-call? dex-trait sell token-trait tokens-in)))
        (let
            (
                (total (stx-get-balance (as-contract tx-sender)))
                (amount-out (/ (* total (- u10000 (var-get fee-point))) u10000))
                (extra-fee (- total amount-out))
                (receiver (var-get fee-receiver))
            )
            (try! (stx-transfer-out-internal sender amount-out))
            (print {extra-fee: extra-fee, receiver: receiver})
            (ok (try! (stx-transfer-out-internal receiver extra-fee)))
        )
    )
)