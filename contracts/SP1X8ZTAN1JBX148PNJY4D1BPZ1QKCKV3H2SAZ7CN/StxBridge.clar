;; ---------------------------------------------------------
;; STX Bridge Contract
;; ---------------------------------------------------------

;; Error constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-AMOUNT u402)
(define-constant ERR-TRANSFER-FAILED u403)
(define-constant ERR-INVALID-PRINCIPAL u404)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Define a map to track deposited STX
(define-map stx-deposits 
  { user: principal } 
  { amount: uint }
)

;; Total deposits counter
(define-data-var total-deposits uint u0)

;; Read-only functions
(define-read-only (get-owner)
  (var-get contract-owner)
)

(define-read-only (is-valid-amount (amount uint))
  (> amount u0)
)

(define-read-only (is-valid-principal (recipient principal))
  (not (is-eq recipient (as-contract tx-sender)))
)

;; Function to get user's deposited STX balance
(define-read-only (get-user-deposit (user principal))
  (default-to { amount: u0 } (map-get? stx-deposits { user: user }))
)

;; Function to get total deposits
(define-read-only (get-total-deposits)
  (var-get total-deposits)
)

;; Transfer ownership of the contract
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set contract-owner new-owner))
  )
)

;; Function to update user's STX balance in the mapping (no actual STX transfer)
(define-public (lock-stx (amount uint))
  (begin
    ;; Validate inputs
    (asserts! (is-valid-amount amount) (err ERR-INVALID-AMOUNT))
    
    ;; Just update the mapping without transferring STX
    (let 
      (
        (current-deposit (get amount (get-user-deposit tx-sender)))
      )
      ;; Update user's deposit record
      (map-set stx-deposits { user: tx-sender } { amount: (+ current-deposit amount) })
      ;; Update total deposits
      (var-set total-deposits (+ (var-get total-deposits) amount))
      (ok true)
    )
  )
)

;; Function to bridge STX (owner-only)
(define-public (unlock-stx (amount uint) (recipient principal))
  (begin
    ;; Authorization check
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    
    ;; Validate inputs
    (asserts! (is-valid-amount amount) (err ERR-INVALID-AMOUNT))
    (asserts! (is-valid-principal recipient) (err ERR-INVALID-PRINCIPAL))
    (asserts! (<= amount (var-get total-deposits)) (err ERR-INVALID-AMOUNT))
    
    ;; Transfer STX from contract to recipient
    (let ((transfer-result (as-contract (stx-transfer? amount (as-contract tx-sender) recipient))))
      (if (is-ok transfer-result)
          (begin
            ;; Update total deposits
            (var-set total-deposits (- (var-get total-deposits) amount))
            (ok true)
          )
          (err ERR-TRANSFER-FAILED)
      )
    )
  )
)

;; Function for owner to refund a user's deposit
(define-public (refund-user (user principal) (amount uint))
  (begin
    ;; Authorization check
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    
    ;; Get user's current deposit
    (let 
      (
        (user-deposit (get amount (get-user-deposit user)))
      )
      ;; Validate inputs
      (asserts! (is-valid-principal user) (err ERR-INVALID-PRINCIPAL))
      (asserts! (is-valid-amount amount) (err ERR-INVALID-AMOUNT))
      (asserts! (<= amount user-deposit) (err ERR-INVALID-AMOUNT))
      
      ;; Transfer STX from contract to user
      (let ((transfer-result (as-contract (stx-transfer? amount (as-contract tx-sender) user))))
        (if (is-ok transfer-result)
            (begin
              ;; Update user's deposit record
              (map-set stx-deposits { user: user } { amount: (- user-deposit amount) })
              ;; Update total deposits
              (var-set total-deposits (- (var-get total-deposits) amount))
              (ok true)
            )
            (err ERR-TRANSFER-FAILED)
        )
      )
    )
  )
)