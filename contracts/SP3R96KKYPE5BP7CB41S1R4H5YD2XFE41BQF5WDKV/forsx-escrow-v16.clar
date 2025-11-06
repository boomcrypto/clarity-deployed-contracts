;; forsx-escrow-minimal.clar
;; Adding created-at with block-height
(define-read-only (get-trade (trade-id uint))
  (map-get? simple-trades trade-id)
)

;; Cancel trade with STX transfers
(define-public (cancel-trade (trade-id uint))
  (let
    (
      (trade (unwrap! (map-get? simple-trades trade-id) err-no-active-trade))
      (is-seller (is-eq tx-sender (get seller trade)))
      (is-buyer (is-eq tx-sender (get buyer trade)))
    )
    
    ;; Check that the trade is still pending
    (asserts! (is-eq (get state trade) u1) err-invalid-state)
    
    ;; Check that the caller is either the buyer, seller, or contract owner
    (asserts! (or is-seller is-buyer (is-eq tx-sender (var-get contract-owner))) err-unauthorized)
    
    ;; Update trade state to cancelled
    (map-set simple-trades trade-id (merge trade {state: u3}))
    
    ;; Return funds to buyer - FIXED: use contract-caller instead of tx-sender
    (try! (as-contract (stx-transfer? (get amount trade) (as-contract tx-sender) (get buyer trade))))
    
    (ok true)
  )
)

;; Error constants for confirm-receipt
(define-constant err-no-active-trade (err u404))
(define-constant err-invalid-state (err u402))
(define-constant err-sender-already-confirmed (err u406))

;; Private function to complete a trade and distribute funds
(define-private (complete-trade (trade-id uint))
  (let
    (
      (trade (unwrap! (map-get? simple-trades trade-id) err-no-active-trade))
      (fee-amount (/ (* (get amount trade) (var-get platform-fee)) u10000))
      (seller-amount (- (get amount trade) fee-amount))
    )
    
    ;; Update trade state to completed
    (map-set simple-trades trade-id (merge trade {state: u2}))
    
    ;; Transfer funds to seller (minus fee) - FIXED
    (try! (as-contract (stx-transfer? seller-amount (as-contract tx-sender) (get seller trade))))
    
    ;; Transfer fee to contract owner - FIXED  
    (try! (as-contract (stx-transfer? fee-amount (as-contract tx-sender) (var-get contract-owner))))
    
    (ok true)
  )
)

;; Update confirm-receipt to use complete-trade
(define-public (confirm-receipt (trade-id uint))
  (let
    (
      (trade (unwrap! (map-get? simple-trades trade-id) err-no-active-trade))
      (is-seller (is-eq tx-sender (get seller trade)))
      (is-buyer (is-eq tx-sender (get buyer trade)))
    )
    
    ;; Check that the trade is still pending
    (asserts! (is-eq (get state trade) u1) err-invalid-state)
    
    ;; Check that the caller is either the buyer or seller
    (asserts! (or is-seller is-buyer) err-unauthorized)
    
    ;; Check that the caller hasn't already confirmed
    (asserts! (not (if is-seller
                      (get seller-confirmed trade)
                      (get buyer-confirmed trade))) 
              err-sender-already-confirmed)
    
    ;; Update the confirmation status
    (if is-seller
        (map-set simple-trades trade-id (merge trade {seller-confirmed: true}))
        (map-set simple-trades trade-id (merge trade {buyer-confirmed: true})))
    
    ;; If both parties have confirmed, complete the trade
    (let ((updated-trade (unwrap! (map-get? simple-trades trade-id) err-no-active-trade)))
      (if (and (get buyer-confirmed updated-trade)
               (get seller-confirmed updated-trade))
          (complete-trade trade-id)
          (ok true)))
  )
)

;; Error codes
(define-constant err-unauthorized (err u401))

;; Simple data variables
(define-data-var platform-fee uint u200) ;; 2% fee
(define-data-var contract-owner principal tx-sender)
(define-data-var next-trade-id uint u1)

;; Complete trade map without created-at field
(define-map simple-trades uint {
  amount: uint,
  state: uint,
  buyer: principal,
  seller: principal,
  buyer-confirmed: bool,
  seller-confirmed: bool
})

;; Simple functions to test deployment
(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
    (var-set platform-fee new-fee)
    (ok true)
  )
)



(define-constant err-not-enough-funds (err u403))

;; Create trade with STX transfer
(define-public (create-trade (seller principal) (amount uint))
  (let
    (
      (trade-id (var-get next-trade-id))
    )
    ;; Check that the buyer has enough funds
    (asserts! (>= (stx-get-balance tx-sender) amount) err-not-enough-funds)
    
    ;; Store trade data
    (map-set simple-trades trade-id {
      amount: amount,
      state: u1,
      buyer: tx-sender,
      seller: seller,
      buyer-confirmed: false,
      seller-confirmed: false
    })
    
    ;; Transfer funds from buyer to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Increment the trade ID
    (var-set next-trade-id (+ trade-id u1))
    
    (ok trade-id)
  )
)