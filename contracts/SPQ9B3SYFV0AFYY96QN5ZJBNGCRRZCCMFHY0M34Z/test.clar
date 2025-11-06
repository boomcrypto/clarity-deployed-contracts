(define-constant ERR-INVALID-AMOUNT (err u1)) ;; Non-positive deposit/withdrawal amount
(define-constant ERR-NOT-MERCHANT (err u2)) ;; Caller is not the merchant
(define-constant ERR-INSUFFICIENT-BALANCE (err u4)) ;; Insufficient contract balance
(define-constant ERR-INVALID-PRICE (err u6)) ;; Deposit amount doesn't match price
(define-constant ERR-LIST-FULL (err u7)) ;; Customer list is at maximum capacity
(define-constant PRICE u10000) ;; Price in microstacks
(define-constant MAX-CUSTOMERS u1000) ;; Maximum number of unique customers (reduced for practical limits)

(define-data-var merchant principal tx-sender) ;; Deployer is the merchant
(define-data-var total-deposits uint u0) ;; Tracks total STX deposited
(define-data-var customer-list (list 1000 principal) (list)) ;; Now matches MAX-CUSTOMERS
(define-map customer-deposits principal uint) ;; Tracks total deposits per customer
(define-map deposit-count principal uint) ;; Tracks number of deposits per customer

;; Deposit STX into the vault (must match price, multiple deposits allowed)
(define-public (deposit (amount uint))
  (let ((current-total (default-to u0 (map-get? customer-deposits tx-sender)))
        (current-list (var-get customer-list)))
    (begin
      (asserts! (is-eq amount PRICE) ERR-INVALID-PRICE)
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (if (is-eq current-total u0)
        (begin
          (asserts! (< (len current-list) MAX-CUSTOMERS) ERR-LIST-FULL)
          ;; Use unwrap-panic since we've already checked the length
          (var-set customer-list 
            (unwrap-panic (as-max-len? (append current-list tx-sender) u1000))))
        false)
      (map-set customer-deposits
        tx-sender
        (+ current-total amount))
      (map-set deposit-count
        tx-sender
        (+ (default-to u0 (map-get? deposit-count tx-sender)) u1))
      (var-set total-deposits (+ (var-get total-deposits) amount))
      (ok true)
    )
  )
)

;; Withdraw STX from the vault (merchant only)
(define-public (withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get merchant)) ERR-NOT-MERCHANT)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) ERR-INSUFFICIENT-BALANCE)
    (as-contract (try! (stx-transfer? amount tx-sender (var-get merchant))))
    (ok true)
  )
)

;; Get the merchant's principal
(define-read-only (get-merchant)
  (var-get merchant)
)

;; Get the product price
(define-read-only (get-price)
  PRICE
)

;; Get total deposits
(define-read-only (get-total-deposits)
  (var-get total-deposits)
)

;; Get a customer's total deposits
(define-read-only (get-customer-deposit (customer principal))
  (default-to u0 (map-get? customer-deposits customer))
)

;; Get a customer's deposit count
(define-read-only (get-deposit-count (customer principal))
  (default-to u0 (map-get? deposit-count customer))
)

;; Get list of all customer deposits
(define-read-only (get-all-customer-deposits)
  (map get-customer-info (var-get customer-list))
)

;; Private function to format customer deposit info
(define-private (get-customer-info (customer principal))
  { customer: customer, total: (get-customer-deposit customer), count: (get-deposit-count customer) }
)
