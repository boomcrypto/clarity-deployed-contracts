---
title: "Trait xbot-velar-univ2-path2"
draft: true
---
```
;; title: xbot-velar-univ2-path2
;; version:
;; summary:
;; description:

;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

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

(define-public
  (do-swap
   (in-as-fee    bool)
   (amt-in       uint)
   (amt-out-min  uint)
   (token-in     <ft-trait>)
   (token-out    <ft-trait>))
   (if in-as-fee
      (let 
        (
            (sender (try! (get-sender)))
            (amt-fee (/ (* amt-in (var-get fee-point)) u10000))
            (amt-swap-in (- amt-in amt-fee))
            (amt-out (try! (do-swap-internal amt-in amt-swap-in token-in token-out)))
        )
        (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-out sender amt-out))
        (print {extra-fee: (try! (balance-of-this token-in)), receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-in (var-get fee-receiver) (try! (balance-of-this token-in)))))
      )
      (let 
        (
            (sender (try! (get-sender)))
            (amt-swap-out (try! (do-swap-internal amt-in amt-in token-in token-out)))
            (amt-fee (/ (* amt-swap-out (var-get fee-point)) u10000))
            (amt-out (- amt-swap-out amt-fee))
        )
        (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (transfer-out-internal token-out sender amt-out))
        (print {extra-fee: amt-fee, receiver: (var-get fee-receiver)})
        (ok (try! (transfer-out-internal token-out (var-get fee-receiver) amt-fee)))
    )
   )
)

(define-public
  (swap-3
    (in-as-fee    bool)
    (amt-in       uint)
    (amt-out-min  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>))
    (if in-as-fee
        (let 
            (
                (sender (try! (get-sender)))
                (amt-fee (/ (* amt-in (var-get fee-point)) u10000))
                (amt-swap-in (- amt-in amt-fee))
                (amt-out (try! (swap-3-internal amt-in amt-swap-in token-a token-b token-c)))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-c sender amt-out))
            (print {extra-fee: (try! (balance-of-this token-a)), receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-a (var-get fee-receiver) (try! (balance-of-this token-a)))))
        )
        (let 
            (
                (sender (try! (get-sender)))
                (amt-swap-out (try! (swap-3-internal amt-in amt-in token-a token-b token-c)))
                (amt-fee (/ (* amt-swap-out (var-get fee-point)) u10000))
                (amt-out (- amt-swap-out amt-fee))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-c sender amt-out))
            (print {extra-fee: amt-fee, receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-c (var-get fee-receiver) amt-fee)))
        )
   )
)

(define-public
  (swap-4
    (in-as-fee    bool)
    (amt-in       uint)
    (amt-out-min  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>)
    (token-d      <ft-trait>))
    (if in-as-fee
        (let 
            (
                (sender (try! (get-sender)))
                (amt-fee (/ (* amt-in (var-get fee-point)) u10000))
                (amt-swap-in (- amt-in amt-fee))
                (amt-out (try! (swap-4-internal amt-in amt-swap-in token-a token-b token-c token-d)))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-d sender amt-out))
            (print {extra-fee: (try! (balance-of-this token-a)), receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-a (var-get fee-receiver) (try! (balance-of-this token-a)))))
        )
        (let 
            (
                (sender (try! (get-sender)))
                (amt-swap-out (try! (swap-4-internal amt-in amt-in token-a token-b token-c token-d)))
                (amt-fee (/ (* amt-swap-out (var-get fee-point)) u10000))
                (amt-out (- amt-swap-out amt-fee))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-d sender amt-out))
            (print {extra-fee: amt-fee, receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-d (var-get fee-receiver) amt-fee)))
        )
   )
)

(define-public
  (swap-5
    (in-as-fee    bool)
    (amt-in       uint)
    (amt-out-min  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>)
    (token-d      <ft-trait>)
    (token-e      <ft-trait>))
    (if in-as-fee
        (let 
            (
                (sender (try! (get-sender)))
                (amt-fee (/ (* amt-in (var-get fee-point)) u10000))
                (amt-swap-in (- amt-in amt-fee))
                (amt-out (try! (swap-5-internal amt-in amt-swap-in token-a token-b token-c token-d token-e)))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-e sender amt-out))
            (print {extra-fee: (try! (balance-of-this token-a)), receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-a (var-get fee-receiver) (try! (balance-of-this token-a)))))
        )
        (let 
            (
                (sender (try! (get-sender)))
                (amt-swap-out (try! (swap-5-internal amt-in amt-in token-a token-b token-c token-d token-e)))
                (amt-fee (/ (* amt-swap-out (var-get fee-point)) u10000))
                (amt-out (- amt-swap-out amt-fee))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-e sender amt-out))
            (print {extra-fee: amt-fee, receiver: (var-get fee-receiver)})
            (ok (try! (transfer-out-internal token-e (var-get fee-receiver) amt-fee)))
        )
   )
)

(define-private (do-swap-internal
    (amt-in       uint)
    (amt-swap-in  uint)
    (token-in     <ft-trait>)
    (token-out    <ft-trait>))
    ;; #[allow(unchecked_data)]
    (begin
      (try! (transfer-in-internal token-in amt-in))
      (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap amt-swap-in token-in token-out 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
      (ok (try! (balance-of-this token-out)))
    )
)

(define-private (swap-3-internal
    (amt-in       uint)
    (amt-swap-in  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>))
    ;; #[allow(unchecked_data)]
    (begin
      (try! (transfer-in-internal token-a amt-in))
      (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3 amt-swap-in u0 token-a token-b token-c 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
      (ok (try! (balance-of-this token-c)))
    )
)

(define-private (swap-4-internal
    (amt-in       uint)
    (amt-swap-in  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>)
    (token-d      <ft-trait>))
    ;; #[allow(unchecked_data)]
    (begin
      (try! (transfer-in-internal token-a amt-in))
      (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4 amt-swap-in u0 token-a token-b token-c token-d 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
      (ok (try! (balance-of-this token-d)))
    )
)

(define-private (swap-5-internal
    (amt-in       uint)
    (amt-swap-in  uint)
    (token-a      <ft-trait>)
    (token-b      <ft-trait>)
    (token-c      <ft-trait>)
    (token-d      <ft-trait>)
    (token-e      <ft-trait>))
    ;; #[allow(unchecked_data)]
    (begin
      (try! (transfer-in-internal token-a amt-in))
      (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5 amt-swap-in u0 token-a token-b token-c token-d token-e 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
      (ok (try! (balance-of-this token-e)))
    )
)

```
