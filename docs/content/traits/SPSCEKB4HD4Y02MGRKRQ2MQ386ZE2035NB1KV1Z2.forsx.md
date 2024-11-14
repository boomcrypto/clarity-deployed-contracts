---
title: "Trait forsx"
draft: true
---
```
(define-constant STABLECOIN_XUSD u0)
(define-constant STABLECOIN_SUSDT u1)

;; Constants for token contracts
(define-constant CONTRACT_XUSD 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD)
(define-constant CONTRACT_SUSDT 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt)

(define-constant TOKEN_XUSD "wrapped-usd")
(define-constant TOKEN_SUSDT "susdt")

;; Scaling factor for fixed-point arithmetic
(define-constant SCALE_FACTOR (pow u10 u6))

;; Error codes
(define-constant ERR-NOT-OWNER u115)
(define-constant ERR-ALREADY-ACTIVATED u116)
(define-constant ERR-NOT-ACTIVATED u117)
(define-constant ERR-ALREADY-DEACTIVATED u118)

;; Define trait for fungible tokens
(define-trait ft-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (get-balance (principal) (response uint uint))
  )
)

;; Data variables
(define-data-var stx-balance uint u0)
(define-data-var stx-price uint u0)
(define-data-var owner principal tx-sender)
(define-data-var recipient principal tx-sender)
(define-data-var contract-activated bool false)

;; Private function to check if contract is activated
(define-private (check-activated)
  (if (var-get contract-activated)
    (ok true)
    (err ERR-NOT-ACTIVATED)
  )
)

;; Function to activate the contract
(define-public (activate-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-OWNER))
    (asserts! (not (var-get contract-activated)) (err ERR-ALREADY-ACTIVATED))
    (ok (var-set contract-activated true))
  )
)

;; Function to deactivate the contract
(define-public (deactivate-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-OWNER))
    (asserts! (var-get contract-activated) (err ERR-ALREADY-DEACTIVATED))
    (ok (var-set contract-activated false))
  )
)

(define-public (swap-token-for-stx (token <ft-trait>) (amount uint))
  (begin
    (try! (check-activated))
    (let
      (
        (price (var-get stx-price))
        (stx-amount (/ (* amount SCALE_FACTOR) price))
        (current-stx-balance (var-get stx-balance))
        (recipient-address (var-get recipient))
      )
      (asserts! (or (is-eq (contract-of token) CONTRACT_XUSD) (is-eq (contract-of token) CONTRACT_SUSDT)) (err u120))
      (asserts! (> price u0) (err u102))
      (asserts! (<= stx-amount current-stx-balance) (err u103))
      (asserts! (>= (unwrap-panic (contract-call? token get-balance tx-sender)) amount) (err u104))
      
      (match (contract-call? token transfer amount tx-sender recipient-address)
        success
          (begin
            (asserts! (is-ok (stx-transfer? (/ stx-amount SCALE_FACTOR) (as-contract tx-sender) tx-sender)) (err u108))
            (var-set stx-balance (- current-stx-balance stx-amount))
            (print {event: "Swap", token: (contract-of token), amount: amount, stx-amount: stx-amount, new-stx-balance: (var-get stx-balance)})
            (ok (/ stx-amount SCALE_FACTOR))
          )
        error (err error)
      )
    )
  )
)

(define-public (set-recipient (new-recipient principal))
  (begin
    (try! (check-activated))
    (asserts! (is-eq tx-sender (var-get owner)) (err u105))
    (asserts! (not (is-eq new-recipient 'SP000000000000000000002Q6VF78)) (err u109))
    (ok (var-set recipient new-recipient))
  )
)

(define-public (set-stx-price (price uint))
  (begin
    (try! (check-activated))
    (asserts! (is-eq tx-sender (var-get owner)) (err u100))
    (asserts! (and (> price u0) (< price u1000000000000)) (err u110))
    (ok (var-set stx-price (* price SCALE_FACTOR)))
  )
)

(define-public (add-stx (amount uint))
  (begin
    (try! (check-activated))
    (asserts! (is-eq tx-sender (var-get owner)) (err u101))
    (let
      (
        (current-balance (var-get stx-balance))
        (new-balance (+ current-balance amount))
      )
      (asserts! (>= new-balance current-balance) (err u114)) ;; Check for overflow
      (print {event: "Before-Transfer", current-balance: current-balance})
      (match (stx-transfer? amount tx-sender (as-contract tx-sender))
        success
          (begin
            (var-set stx-balance new-balance)
            (print {event: "After-Transfer", amount: amount, new-balance: new-balance, stored-balance: (var-get stx-balance)})
            (ok new-balance)
          )
        error 
          (begin
            (print {event: "Transfer-Failed", error: error})
            (err u106)
          )
      )
    )
  )
)

(define-public (withdraw-stx (amount uint))
  (begin
    (try! (check-activated))
    (asserts! (is-eq tx-sender (var-get owner)) (err u111))
    (let ((scaled-amount (* amount SCALE_FACTOR)))
      (asserts! (<= scaled-amount (var-get stx-balance)) (err u112))
      (asserts! (is-ok (as-contract (stx-transfer? amount tx-sender (var-get owner)))) (err u113))
      (var-set stx-balance (- (var-get stx-balance) scaled-amount))
      (print {event: "Withdraw-STX", amount: amount, new-balance: (var-get stx-balance)})
      (ok (/ (var-get stx-balance) SCALE_FACTOR))
    )
  )
)

(define-read-only (get-stx-balance)
  (begin
    (try! (check-activated))
    (let ((balance (var-get stx-balance)))
      (print {event: "Read-Balance", balance: balance})
      (ok balance)
    )
  )
)

(define-read-only (get-stx-price)
  (begin
    (try! (check-activated))
    (ok (/ (var-get stx-price) SCALE_FACTOR))
  )
)

(define-read-only (get-recipient)
  (begin
    (try! (check-activated))
    (ok (var-get recipient))
  )
)

(define-read-only (is-contract-activated)
  (ok (var-get contract-activated))
)
```
