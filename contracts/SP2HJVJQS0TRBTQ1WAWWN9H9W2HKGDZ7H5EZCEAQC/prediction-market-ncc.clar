;; Prediction Market Smart Contract
;; Author: Christopher Perceptions
;; Powered by NoCodeClarity v2

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-resolved (err u102))
(define-constant err-market-not-resolved (err u103))
(define-constant err-no-reward (err u104))
(define-constant err-already-participated (err u105))
(define-constant err-transfer-failed (err u106))
(define-constant err-invalid-question (err u107))
(define-constant err-invalid-amount (err u108))

;; Platform fee constant (0.01 STX = 10000 uSTX)
(define-constant platform-fee u10000)

;; Data vars
(define-data-var market-nonce uint u1)
(define-data-var platform-balance uint u0)

;; Maps
(define-map markets uint {question: (string-utf8 256), creator: principal, yes-amount: uint, no-amount: uint, resolved: bool, outcome: (optional bool)})
(define-map market-balances {market-id: uint, user: principal} {yes: uint, no: uint, claimed: bool})

;; Public functions

(define-public (create-market (question (string-utf8 256)))
  (let
    ((market-id (var-get market-nonce))
     (question-length (len question)))
    
    ;; Validate question length
    (asserts! (and (> question-length u0) (<= question-length u256)) (err err-invalid-question))
    
    ;; Create market
    (map-set markets market-id 
      {question: question, 
       creator: tx-sender, 
       yes-amount: u0, 
       no-amount: u0, 
       resolved: false, 
       outcome: none})
    
    ;; Increment market nonce
    (var-set market-nonce (+ market-id u1))
    
    (ok market-id)))

(define-public (buy-prediction (market-id uint) (amount uint) (prediction bool))
  (let
    ((market (unwrap! (map-get? markets market-id) (err err-not-found)))
     (balance (default-to {yes: u0, no: u0, claimed: false} (map-get? market-balances {market-id: market-id, user: tx-sender}))))
    
    ;; Validate input
    (asserts! (> amount u0) (err err-invalid-amount))
    (asserts! (not (get resolved market)) (err err-already-resolved))
    (asserts! (if prediction
                (is-eq (get no balance) u0)
                (is-eq (get yes balance) u0))
              (err err-already-participated))
    
    (match (stx-transfer? (+ amount platform-fee) tx-sender (as-contract tx-sender))
      success (begin
        ;; Update platform balance
        (var-set platform-balance (+ (var-get platform-balance) platform-fee))
        
        ;; Update market
        (map-set markets market-id 
          (merge market 
            {yes-amount: (if prediction (+ (get yes-amount market) amount) (get yes-amount market)),
             no-amount: (if prediction (get no-amount market) (+ (get no-amount market) amount))}))

        ;; Update user balance
        (map-set market-balances {market-id: market-id, user: tx-sender} 
          (merge balance 
            {yes: (if prediction (+ (get yes balance) amount) (get yes balance)),
             no: (if prediction (get no balance) (+ (get no balance) amount))}))
        
        (ok true))
      error (err err-transfer-failed))))

(define-public (resolve-market (market-id uint) (outcome bool))
  (let
    ((market (unwrap! (map-get? markets market-id) (err err-not-found))))
    
    (asserts! (is-eq tx-sender (get creator market)) (err err-owner-only))
    (asserts! (not (get resolved market)) (err err-already-resolved))
    
    (map-set markets market-id (merge market {resolved: true, outcome: (some outcome)}))
    
    (print (merge {event: "market-resolved"} market))
    
    (ok true)))

(define-public (claim-reward (market-id uint))
  (let 
    ((market (unwrap! (map-get? markets market-id) (err err-not-found)))
     (balance (unwrap! (map-get? market-balances {market-id: market-id, user: tx-sender}) (err err-not-found))))
    
    (asserts! (get resolved market) (err err-market-not-resolved))
    (asserts! (not (get claimed balance)) (err err-no-reward))
    
    (match (get outcome market)
      outcome (let 
        ((total-pot (+ (get yes-amount market) (get no-amount market)))
         (winning-amount (if outcome (get yes-amount market) (get no-amount market)))
         (user-stake (if outcome (get yes balance) (get no balance)))
         (reward (/ (* user-stake total-pot) winning-amount)))
        
        (asserts! (> reward u0) (err err-no-reward))
        (match (as-contract (stx-transfer? reward tx-sender tx-sender))
          success (begin
            (map-set market-balances {market-id: market-id, user: tx-sender} (merge balance {claimed: true}))
            (ok reward))
          error (err err-transfer-failed)))
      (err err-market-not-resolved))))

(define-public (withdraw-platform-fees)
  (let ((balance (var-get platform-balance)))
    (asserts! (is-eq tx-sender contract-owner) (err err-owner-only))
    (asserts! (> balance u0) (err err-no-reward))
    (match (as-contract (stx-transfer? balance contract-owner tx-sender))
      success (begin
        (var-set platform-balance u0)
        (ok balance))
      error (err err-transfer-failed))))

;; Read-only functions

(define-read-only (get-market (market-id uint))
  (map-get? markets market-id))

(define-read-only (get-balance (market-id uint) (user principal))
  (map-get? market-balances {market-id: market-id, user: user}))

(define-read-only (get-platform-balance)
  (var-get platform-balance))