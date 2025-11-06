(define-constant ERR-TRANSFER (err u201))
(define-constant INSUFFICIENT-BALANCE (err u203))
(define-constant ERR-NOT-OWNER (err u403))
(define-constant ERR-UNLOCK-EXISTS (err u404))
(define-constant INVALID_RECIPIENT (err u405))
(define-constant INVALID_ID (err u405))
(define-constant ERR-ENTER-NEW-OWNER (err u406))

(define-data-var contract-owner principal tx-sender) ;; Set deployer as owner

;; Counter to generate unique lock-ids
(define-data-var lock-id-counter uint u0)

(define-data-var total-locked-stx uint u0)

;; Track total lock events
(define-map total-stx-locks
  { lock-id: uint }
  {
    sender: principal,
    amount: uint,
  }
)

(define-data-var total-unlocked-stx uint u0)


;; Lock function for STX
(define-public (lock-stx (amount uint))
  (begin
    (asserts! (> amount u0) INSUFFICIENT-BALANCE)
    (asserts! (>= (stx-get-balance tx-sender) amount) INSUFFICIENT-BALANCE)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-locked-stx (+ (var-get total-locked-stx) amount))
    ;; (let ((existing-amount (default-to u0 (map-get? stx-locks tx-sender))))
    ;;   (map-set stx-locks tx-sender (+ amount existing-amount))
    (let ((current-lock-id (var-get lock-id-counter)))
      (var-set lock-id-counter (+ current-lock-id u1))
      (map-set total-stx-locks { lock-id: current-lock-id } {
        sender: tx-sender,
        amount: amount,
      })
      (ok {
        op: "STX Locked",
        sender: tx-sender,
        amount-locked: amount,
        total-locked: (var-get total-locked-stx),
        lock-id: current-lock-id,
      })
    )
  )
)

(define-public (unlock-stx
    (amount uint)
    (recipient principal)
  )
  (begin
    ;; 1. Basic safeguards
    (asserts! (> amount u0) INSUFFICIENT-BALANCE)
     (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-OWNER)
    (asserts! (not (is-eq recipient (as-contract tx-sender))) INVALID_RECIPIENT)
 
      ;; 3. Verify contract balance
      (let ((contract-balance (stx-get-balance (as-contract tx-sender))))
        (asserts! (>= contract-balance amount) INSUFFICIENT-BALANCE)
        ;; 4. Execute transfer
        (try! (as-contract (stx-transfer? amount (as-contract tx-sender) recipient)))
        ;; 5. Update state
        (var-set total-unlocked-stx (+ (var-get total-unlocked-stx) amount))
     
        ;; 6. Return success
        (ok {
          op: "STX Unlocked",
          recipient: recipient,
          amount: amount,
          total-unlocked: (var-get total-unlocked-stx),
          status: true,
        })
      )
    )
  )



(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Only current owner can transfer
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-OWNER)
    (asserts! (not (is-eq new-owner (var-get contract-owner)))
      ERR-ENTER-NEW-OWNER
    )
    ;; Update owner
    (var-set contract-owner new-owner)
    (ok true)
  )
)
(define-public (withdraw-stx (amount uint))
  (begin
    ;; Check that the sender is the contract owner
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-OWNER)
    ;; Check that amount is greater than zero
    (asserts! (> amount u0) INSUFFICIENT-BALANCE)
    ;; Check contract has enough balance
    (let ((contract-balance (stx-get-balance (as-contract tx-sender))))
      (asserts! (>= contract-balance amount) INSUFFICIENT-BALANCE)
      ;; Attempt transfer to owner
      (try! (as-contract (stx-transfer? amount (as-contract tx-sender) (var-get contract-owner))))
      (ok {
        op: "STX Withdrawn by Owner",
        owner: (var-get contract-owner),
        amount: amount,
        remaining-contract-balance: (- contract-balance amount),
      })
    )
  )
)

;; Read-only function to get current lock id counter
(define-read-only (get-lock-id-counter)
  (var-get lock-id-counter)
)

;; Read-only function to get lock event by lock-id
(define-read-only (get-lock-by-id (lock-id uint))
  (map-get? total-stx-locks { lock-id: lock-id })
)

(define-read-only (get-total-locked-amount)
  (var-get total-locked-stx)
)


(define-read-only (get-total-unlocked-stx)
  (var-get total-unlocked-stx)
)

(define-read-only (get-balance (account principal))
  (stx-get-balance account)
)

(define-read-only (get-owner)
  (ok (var-get contract-owner))
)