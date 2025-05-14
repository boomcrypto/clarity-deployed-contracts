---
title: "Trait cat-presale"
draft: true
---
```
;; Cat Presale Contract - CATGOTOMARS Project
;; Version: 1.0 - Mainnet Deployment
;; Description: A presale contract for the $CAT token on the Stacks blockchain.
;; Users contribute STX to purchase $CAT tokens based on dynamic pricing in USDT set by an oracle.
;; Token claims and distribution are handled separately after the presale ends.

;; === Constants ===
(define-constant CONTRACT_OWNER tx-sender)          ;; Contract owner, set to the deployer at initialization
(define-constant MICRO-UNITS-PER-STX u1000000)     ;; Conversion rate: 1 STX = 1,000,000 micro-STX
(define-constant ERR-NOT-AUTHORIZED u1)            ;; Error: Caller is not authorized (owner or oracle)
(define-constant ERR-INVALID-AMOUNT u2)            ;; Error: Amount must be greater than 0
(define-constant ERR-ORACLE-UNAUTHORIZED u3)       ;; Error: Only oracle can update STX price
(define-constant ERR-PRESALE-CLOSED u6)            ;; Error: Presale is closed, no more purchases allowed
(define-constant ERR-TRANSFER-FAILED u8)           ;; Error: STX transfer failed
(define-constant ERR-PRESALE-NOT-CLOSED u14)       ;; Error: Presale must be closed for withdrawal

;; === Data Variables ===
(define-data-var total-stx-raised uint u0)         ;; Total STX raised in the presale (in whole STX units)
(define-data-var softcap uint u100000)             ;; Softcap target: 100,000 STX (in whole STX units)
(define-data-var presale-closed bool false)        ;; Status flag: true if presale is closed, false otherwise
(define-data-var cat-price-in-usdt uint u100)      ;; $CAT price in micro-USDT (e.g., 0.0001 USDT/CAT initially)
(define-data-var stx-price-in-usdt uint u800000)   ;; STX price in micro-USDT (e.g., 0.8 USDT/STX initially)
(define-data-var oracle-address principal CONTRACT_OWNER) ;; Address of the oracle for STX price updates

;; === Data Maps ===
;; Tracks each buyer's contributions: STX sent and $CAT allocated (in whole units)
(define-map buyer-contributions
  { user: principal }
  { stx-amount: uint, cat-amount: uint })

;; === Public Functions ===

;; Allows the contract owner to update the $CAT price in micro-USDT
(define-public (set-cat-price-in-usdt (new-price uint))
  (begin
    ;; Restrict to contract owner only
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR-NOT-AUTHORIZED))
    ;; Ensure the new price is greater than 0
    (asserts! (> new-price u0) (err ERR-INVALID-AMOUNT))
    ;; Update the $CAT price
    (var-set cat-price-in-usdt new-price)
    (ok true)))

;; Allows the oracle to update the STX price in micro-USDT
(define-public (set-stx-price-in-usdt (new-price uint))
  (begin
    ;; Restrict to the designated oracle only
    (asserts! (is-eq tx-sender (var-get oracle-address)) (err ERR-ORACLE-UNAUTHORIZED))
    ;; Ensure the new price is greater than 0
    (asserts! (> new-price u0) (err ERR-INVALID-AMOUNT))
    ;; Update the STX price
    (var-set stx-price-in-usdt new-price)
    (ok true)))

;; Allows the contract owner to update the oracle address
(define-public (set-oracle-address (new-oracle principal))
  (begin
    ;; Restrict to contract owner only
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR-NOT-AUTHORIZED))
    ;; Update the oracle address
    (var-set oracle-address new-oracle)
    (ok true)))

;; Allows users to buy $CAT tokens by sending STX, calculating CAT amount based on current prices
(define-public (buy-tokens (stx-amount uint))
  (let
    (
      (buyer tx-sender)                            ;; Sender of the transaction
      (micro-stx-amount (* stx-amount MICRO-UNITS-PER-STX)) ;; Convert STX to micro-STX
      ;; Calculate expected $CAT amount based on current STX and CAT prices in micro-USDT
      (expected-cat-amount (/ (* stx-amount (var-get stx-price-in-usdt)) (var-get cat-price-in-usdt)))
      ;; Fetch current contributions or default to 0
      (current-contribution (get-contributions buyer))
      (new-stx-amount (+ stx-amount (get stx-amount current-contribution))) ;; Updated STX contribution
      (new-cat-amount (+ expected-cat-amount (get cat-amount current-contribution))) ;; Updated CAT allocation
    )
    ;; Ensure presale is still open
    (asserts! (not (var-get presale-closed)) (err ERR-PRESALE-CLOSED))
    ;; Validate STX amount is greater than 0
    (asserts! (> stx-amount u0) (err ERR-INVALID-AMOUNT))
    ;; Transfer STX to the contract
    (try! (stx-transfer? micro-stx-amount buyer (as-contract tx-sender)))
    ;; Update total STX raised
    (var-set total-stx-raised (+ (var-get total-stx-raised) stx-amount))
    ;; Record buyer's contributions
    (map-set buyer-contributions { user: buyer }
      { stx-amount: new-stx-amount, cat-amount: new-cat-amount })
    (ok true)))

;; Allows the contract owner to close the presale
(define-public (close-presale)
  (begin
    ;; Restrict to contract owner only
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR-NOT-AUTHORIZED))
    ;; Set presale status to closed
    (var-set presale-closed true)
    (ok true)))

;; Allows the contract owner to withdraw all raised STX after presale closure
(define-public (withdraw)
  (let
    (
      (amount (var-get total-stx-raised))          ;; Total STX to withdraw (in whole units)
      (micro-amount (* amount MICRO-UNITS-PER-STX)) ;; Convert to micro-STX for transfer
    )
    ;; Restrict to contract owner only
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR-NOT-AUTHORIZED))
    ;; Ensure presale is closed
    (asserts! (var-get presale-closed) (err ERR-PRESALE-NOT-CLOSED))
    ;; Ensure there are funds to withdraw
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    ;; Transfer STX from contract to owner
    (try! (as-contract (stx-transfer? micro-amount tx-sender CONTRACT_OWNER)))
    ;; Reset total STX raised
    (var-set total-stx-raised u0)
    (ok true)))

;; === Read-Only Functions ===

;; Retrieves a user's contributions (STX sent and $CAT allocated)
(define-read-only (get-contributions (user principal))
  (default-to { stx-amount: u0, cat-amount: u0 }
    (map-get? buyer-contributions { user: user })))

;; Returns the total STX raised in the presale (in whole STX units)
(define-read-only (get-total-stx-raised)
  (var-get total-stx-raised))

;; Returns the softcap target (in whole STX units)
(define-read-only (get-softcap)
  (var-get softcap))

;; Returns whether the presale is closed
(define-read-only (is-presale-closed)
  (var-get presale-closed))

;; Returns the current $CAT price in micro-USDT
(define-read-only (get-cat-price-in-usdt)
  (var-get cat-price-in-usdt))

;; Returns the current STX price in micro-USDT
(define-read-only (get-stx-price-in-usdt)
  (var-get stx-price-in-usdt))
```
