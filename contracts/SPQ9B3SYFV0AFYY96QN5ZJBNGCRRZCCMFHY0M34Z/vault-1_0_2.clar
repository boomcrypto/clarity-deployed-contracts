;; sBTC Vault Contract - converted from STX vault

;; Error constants - avoiding u1-u4 reserved by SIP-010
(define-constant ERR-INVALID-AMOUNT (err u100)) ;; Non-positive deposit/withdrawal amount
(define-constant ERR-NOT-MERCHANT (err u101)) ;; Caller is not the merchant
(define-constant ERR-INSUFFICIENT-BALANCE (err u102)) ;; Insufficient contract balance
(define-constant ERR-INVALID-PRICE (err u103)) ;; Deposit amount doesn't match price
(define-constant ERR-LIST-FULL (err u104)) ;; Customer list is at maximum capacity
(define-constant ERR-TRANSFER-FAILED (err u105)) ;; sBTC transfer failed

;; Constants
(define-constant MAX-CUSTOMERS u1000) ;; Maximum number of unique customers

;; Data variables for price (changeable by merchant)
(define-data-var price uint u10000) ;; Price in satoshis (sBTC base unit)

;; sBTC contract reference - automatically handled by Clarinet
(define-constant SBTC-CONTRACT 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant ZEST-CONTRACT 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-7)

;; Data variables
(define-data-var merchant principal tx-sender) ;; Deployer is the merchant
(define-data-var total-deposits uint u0) ;; Tracks total sBTC deposited
(define-data-var customer-list (list 1000 principal) (list)) ;; Customer list

;; Data maps
(define-map customer-deposits principal uint) ;; Tracks total deposits per customer
(define-map deposit-count principal uint) ;; Tracks number of deposits per customer

;; Deposit sBTC into the vault (must match price, multiple deposits allowed)
(define-public (deposit (amount uint))
  (let ((current-total (default-to u0 (map-get? customer-deposits tx-sender)))
        (current-list (var-get customer-list)))
    (begin
      ;; Validate amount matches price
      (asserts! (is-eq amount (var-get price)) ERR-INVALID-PRICE)
      
      ;; Transfer sBTC from sender to contract
      (match (contract-call? SBTC-CONTRACT transfer 
                           amount 
                           tx-sender 
                           (as-contract tx-sender) 
                           none)
        success (begin
          ;; Add customer to list if first deposit
          (if (is-eq current-total u0)
            (begin
              (asserts! (< (len current-list) MAX-CUSTOMERS) ERR-LIST-FULL)
              ;; Add customer to list
              (var-set customer-list 
                (unwrap-panic (as-max-len? (append current-list tx-sender) u1000))))
            false)
          
          ;; Update customer deposit total
          (map-set customer-deposits
            tx-sender
            (+ current-total amount))
          
          ;; Update deposit count
          (map-set deposit-count
            tx-sender
            (+ (default-to u0 (map-get? deposit-count tx-sender)) u1))
          
          ;; Update total deposits
          (var-set total-deposits (+ (var-get total-deposits) amount))
          (ok true))
        error ERR-TRANSFER-FAILED)
    )
  )
)

;; Withdraw sBTC from the vault (merchant only)
(define-public (withdraw (amount uint))
  (begin
    ;; Validate caller is merchant
    (asserts! (is-eq tx-sender (var-get merchant)) ERR-NOT-MERCHANT)
    ;; Validate amount is positive
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Get contract's sBTC balance
    (let ((contract-balance (unwrap-panic (contract-call? SBTC-CONTRACT get-balance (as-contract tx-sender)))))
      ;; Validate sufficient balance
      (asserts! (<= amount contract-balance) ERR-INSUFFICIENT-BALANCE)
      
      ;; Transfer sBTC from contract to merchant
      (as-contract 
        (match (contract-call? SBTC-CONTRACT transfer 
                             amount 
                             tx-sender 
                             (var-get merchant) 
                             none)
          success (ok true)
          error ERR-TRANSFER-FAILED))
    )
  )
)

;; Get the merchant's principal
(define-read-only (get-merchant)
  (var-get merchant)
)

;; Update product price (merchant only)
(define-public (set-price (new-price uint))
  (begin
    ;; Validate caller is merchant
    (asserts! (is-eq tx-sender (var-get merchant)) ERR-NOT-MERCHANT)
    ;; Validate price is positive
    (asserts! (> new-price u0) ERR-INVALID-AMOUNT)
    ;; Update price
    (var-set price new-price)
    (ok true)
  )
)

;; Get the product price in satoshis
(define-read-only (get-price)
  (var-get price)
)

;; Get total sBTC deposits
(define-read-only (get-total-deposits)
  (var-get total-deposits)
)

;; Get contract's current sBTC balance
(define-public (get-contract-balance)
  (contract-call? SBTC-CONTRACT get-balance (as-contract tx-sender))
)

(define-read-only (get-sbtc-balance)
  (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance (as-contract tx-sender))
)

;; Get a customer's total deposits
(define-read-only (get-customer-deposit (customer principal))
  (default-to u0 (map-get? customer-deposits customer))
)

;; Get a customer's deposit count
(define-read-only (get-deposit-count (customer principal))
  (default-to u0 (map-get? deposit-count customer))
)

;; Get a customer's current sBTC balance
(define-public (get-customer-sbtc-balance (customer principal))
  (contract-call? SBTC-CONTRACT get-balance customer)
)

;; Get list of all customer deposits
(define-read-only (get-all-customer-deposits)
  (map get-customer-info (var-get customer-list))
)

;; Private function to format customer deposit info
(define-private (get-customer-info (customer principal))
  { 
    customer: customer, 
    total: (get-customer-deposit customer), 
    count: (get-deposit-count customer)
  }
)
