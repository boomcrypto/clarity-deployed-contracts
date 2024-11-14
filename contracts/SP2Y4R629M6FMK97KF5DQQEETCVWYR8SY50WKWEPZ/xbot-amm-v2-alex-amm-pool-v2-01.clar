;; title: xbot-amm-v2
;; version:
;; summary:
;; description:

;; traits
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; constants
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2005))
(define-constant ERR-NOT-AUTHORIZED (err u810000000))
(define-constant ERR-INVALID-POINT (err u820000000))

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

(define-public (swap-helper-in (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (amount-in (/ (* dx (- u10000 (var-get fee-point))) u10000))
        )
        (try! (transfer-in-internal token-x-trait dx))
        (try! (transfer-out-internal token-y-trait sender (try! (swap-helper-internal false token-x-trait token-y-trait factor amount-in min-dy))))
        (print {extra-fee: (try! (balance-of-this token-x-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-x-trait (var-get fee-receiver) (try! (balance-of-this token-x-trait)))))
    )
)

(define-public (swap-helper-out (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (delta (try! (swap-helper-internal true token-x-trait token-y-trait factor dx min-dy)))
            (amount-out (/ (* delta (- u10000 (var-get fee-point))) u10000))
        )
        (asserts! (<= (default-to u0 min-dy) amount-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-y-trait sender amount-out))
        (print {extra-fee: (try! (balance-of-this token-y-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-y-trait (var-get fee-receiver) (try! (balance-of-this token-y-trait)))))
    )
)

(define-public (swap-helper-a-in (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (factor-x uint) (factor-y uint) (dx uint) (min-dz (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (amount-in (/ (* dx (- u10000 (var-get fee-point))) u10000))
        )
        (try! (transfer-in-internal token-x-trait dx))
        (try! (transfer-out-internal token-z-trait sender (try! (swap-helper-a-internal false token-x-trait token-y-trait token-z-trait factor-x factor-y amount-in min-dz))))
        (print {extra-fee: (try! (balance-of-this token-x-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-x-trait (var-get fee-receiver) (try! (balance-of-this token-x-trait)))))
    )
)

(define-public (swap-helper-a-out (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (factor-x uint) (factor-y uint) (dx uint) (min-dz (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (delta (try! (swap-helper-a-internal true token-x-trait token-y-trait token-z-trait factor-x factor-y dx min-dz)))
            (amount-out (/ (* delta (- u10000 (var-get fee-point))) u10000))
        )
        (asserts! (<= (default-to u0 min-dz) amount-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-z-trait sender amount-out))
        (print {extra-fee: (try! (balance-of-this token-z-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-z-trait (var-get fee-receiver) (try! (balance-of-this token-z-trait)))))
    )
)

(define-public (swap-helper-b-in
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint)
        (dx uint) (min-dw (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (amount-in (/ (* dx (- u10000 (var-get fee-point))) u10000))
        )
        (try! (transfer-in-internal token-x-trait dx))
        (try! (transfer-out-internal token-w-trait sender (try! (swap-helper-b-internal false token-x-trait token-y-trait token-z-trait token-w-trait factor-x factor-y factor-z amount-in min-dw))))
        (print {extra-fee: (try! (balance-of-this token-x-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-x-trait (var-get fee-receiver) (try! (balance-of-this token-x-trait)))))
    )
)

(define-public (swap-helper-b-out
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint)
        (dx uint) (min-dw (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (delta (try! (swap-helper-b-internal true token-x-trait token-y-trait token-z-trait token-w-trait factor-x factor-y factor-z dx min-dw)))
            (amount-out (/ (* delta (- u10000 (var-get fee-point))) u10000))
        )
        (asserts! (<= (default-to u0 min-dw) amount-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-w-trait sender amount-out))
        (print {extra-fee: (try! (balance-of-this token-w-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-w-trait (var-get fee-receiver) (try! (balance-of-this token-w-trait)))))
    )
)

(define-public (swap-helper-c-in
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>) (token-v-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
        (dx uint) (min-dv (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (amount-in (/ (* dx (- u10000 (var-get fee-point))) u10000))
        )
        (try! (transfer-in-internal token-x-trait dx))
        (try! (transfer-out-internal token-v-trait sender (try! (swap-helper-c-internal false token-x-trait token-y-trait token-z-trait token-w-trait token-v-trait factor-x factor-y factor-z factor-w amount-in min-dv))))
        (print {extra-fee: (try! (balance-of-this token-x-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-x-trait (var-get fee-receiver) (try! (balance-of-this token-x-trait)))))
    )
)

(define-public (swap-helper-c-out
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>) (token-v-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
        (dx uint) (min-dv (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender (try! (get-sender)))
            (delta (try! (swap-helper-c-internal true token-x-trait token-y-trait token-z-trait token-w-trait token-v-trait factor-x factor-y factor-z factor-w dx min-dv)))
            (amount-out (/ (* delta (- u10000 (var-get fee-point))) u10000))
        )
        (asserts! (<= (default-to u0 min-dv) amount-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-v-trait sender amount-out))
        (print {extra-fee: (try! (balance-of-this token-v-trait)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-v-trait (var-get fee-receiver) (try! (balance-of-this token-v-trait)))))
    )
)

(define-private (swap-helper-internal
        (fixed bool)
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
        (factor uint)
        (dx uint) (min-dy (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender)
            (balance-before (try! (balance-of-this token-y-trait)))
        )
        (if fixed
            (try! (contract-call? token-x-trait transfer-fixed dx sender (as-contract tx-sender) none))
            true)
        (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper token-x-trait token-y-trait factor dx min-dy)))
        (ok (- (try! (balance-of-this token-y-trait)) balance-before))
    )
)

(define-private (swap-helper-a-internal
        (fixed bool)
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>)
        (factor-x uint) (factor-y uint)
        (dx uint) (min-dz (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender)
            (balance-before (try! (balance-of-this token-z-trait)))
        )
        (if fixed
            (try! (contract-call? token-x-trait transfer-fixed dx sender (as-contract tx-sender) none))
            true)
        (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a token-x-trait token-y-trait token-z-trait factor-x factor-y dx min-dz)))
        (ok (- (try! (balance-of-this token-z-trait)) balance-before))
    )
)

(define-private (swap-helper-b-internal
        (fixed bool)
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint)
        (dx uint) (min-dw (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender)
            (balance-before (try! (balance-of-this token-w-trait)))
        )
        (if fixed
            (try! (contract-call? token-x-trait transfer-fixed dx sender (as-contract tx-sender) none))
            true)
        (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b token-x-trait token-y-trait token-z-trait token-w-trait factor-x factor-y factor-z dx min-dw)))
        (ok (- (try! (balance-of-this token-w-trait)) balance-before))
    )
)

(define-private (swap-helper-c-internal
        (fixed bool)
        (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>) (token-v-trait <ft-trait>)
        (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
        (dx uint) (min-dv (optional uint)))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender)
            (balance-before (try! (balance-of-this token-v-trait)))
        )
        (if fixed
            (try! (contract-call? token-x-trait transfer-fixed dx sender (as-contract tx-sender) none))
            true)
        (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c token-x-trait token-y-trait token-z-trait token-w-trait token-v-trait factor-x factor-y factor-z factor-w dx min-dv)))
        (ok (- (try! (balance-of-this token-v-trait)) balance-before))
    )
)

(define-private (balance-of-this (token <ft-trait>)) 
    ;; #[allow(unchecked_data)]
    (contract-call? token get-balance (as-contract tx-sender))
)

(define-private (transfer-in-internal (token <ft-trait>) (amount uint))
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

(define-private (transfer-out-internal (token <ft-trait>) (receiver principal) (amount uint))
    ;; #[allow(unchecked_data)]
    (ok 
        (or 
            (is-eq amount u0) 
            (as-contract (try! (contract-call? token transfer amount (as-contract tx-sender) receiver none)))
        )
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
