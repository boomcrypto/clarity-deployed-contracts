;; TRAITS
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; CONSTANTS
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_ENOUGH_SBTC_BALANCE (err u1003))
(define-constant ERR_NOT_ENOUGH_TOKEN_BALANCE (err u1004))
(define-constant BUY_INFO_ERROR (err u2001))
(define-constant SELL_INFO_ERROR (err u2002))
(define-constant ERR_SELL_AMOUNT (err u2004))
(define-constant ERR_INVALID_AMOUNT (err u3001))
(define-constant ERR_NOTHING_TO_UNLOCK (err u3002))
(define-constant ERR_NOT_MAJORITY (err u3003))
(define-constant ERR_FEE_POOL_TOO_LOW (err u3004))

(define-constant DEX_ADDRESS (as-contract tx-sender))
(define-constant MAX_SUPPLY u2100000000000000)
(define-constant INITIAL_VIRTUAL_SBTC u1500000)
(define-constant DEFAULT_UNLOCK_THRESHOLD u1500) ;; new default threshold
(define-constant MAX_WITHDRAW_CAP u1000000) ;; max withdrawal amount for threshold updates

;; DATA VARIABLES
(define-data-var token-balance uint MAX_SUPPLY)
(define-data-var sbtc-balance uint u0)
(define-data-var virtual-sbtc-amount uint INITIAL_VIRTUAL_SBTC)
(define-data-var sbtc-fee-pool uint u0)
(define-data-var total-swap-fees-sent uint u0)

;; Locking system
(define-map locked-balances { user: principal } { amount: uint })
(define-data-var total-locked uint u0)
(define-data-var majority-holder (optional principal) none)

;; Dynamic threshold system
(define-data-var last-withdraw-amount uint u0)

;; -----------------------------
;; PUBLIC FUNCTIONS
;; -----------------------------

(define-public (buy (sbtc-amount uint))
  (begin
    (asserts! (> sbtc-amount u0) ERR_NOT_ENOUGH_SBTC_BALANCE)
    (let (
      (buy-info (unwrap! (get-buyable-token-details sbtc-amount) BUY_INFO_ERROR))
      (sbtc-total-fee (get fee buy-info))
      (sbtc-swap-fee (get swap-fee buy-info))
      (sbtc-majority-fee (get majority-fee buy-info))
      (sbtc-after-fee (get sbtc-buy buy-info))
      (tokens-out (get buyable-token buy-info))
      (new-sbtc-balance (get new-sbtc-balance buy-info))
      (new-token-balance (get new-token-balance buy-info))
      (recipient tx-sender)
    )
      ;; Transfer 0.6% immediately to swap fee wallet
      (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
        transfer sbtc-swap-fee tx-sender 'SP1FD5DXTJW8V5E6ZVDBZS83B3T6YM82QCM18Y5BF (some 0x00)))

      ;; Transfer remaining SBTC to DEX
      (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
        transfer sbtc-after-fee tx-sender DEX_ADDRESS (some 0x00)))

      ;; Transfer tokens to buyer
      (try! (as-contract (contract-call? 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.mas-sats 
        transfer tokens-out DEX_ADDRESS recipient (some 0x00))))

      ;; Update balances
      (var-set sbtc-balance (+ (var-get sbtc-balance) sbtc-after-fee))
      (var-set sbtc-fee-pool (+ (var-get sbtc-fee-pool) sbtc-majority-fee))
      (var-set token-balance new-token-balance)
      (var-set total-swap-fees-sent (+ (var-get total-swap-fees-sent) sbtc-swap-fee))

      (ok tokens-out)
    )
  )
)

(define-public (sell (tokens-in uint))
  (begin
    (asserts! (> tokens-in u0) ERR_NOT_ENOUGH_TOKEN_BALANCE)
    (let (
      (sell-info (unwrap! (get-sellable-sbtc tokens-in) SELL_INFO_ERROR))
      (sbtc-total-fee (get fee sell-info))
      (sbtc-swap-fee (get swap-fee sell-info))
      (sbtc-majority-fee (get majority-fee sell-info))
      (sbtc-receive (get sbtc-receive sell-info))
      (current-sbtc-balance (get current-sbtc-balance sell-info))
      (new-token-balance (get new-token-balance sell-info))
      (new-sbtc-balance (get new-sbtc-balance sell-info))
      (recipient tx-sender)
    )
      (asserts! (>= current-sbtc-balance sbtc-receive) ERR_NOT_ENOUGH_SBTC_BALANCE)
      (asserts! (>= sbtc-receive u0) ERR_SELL_AMOUNT)

      ;; User sends tokens to DEX
      (try! (contract-call? 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.mas-sats 
        transfer tokens-in tx-sender DEX_ADDRESS (some 0x00)))

      ;; Send SBTC to seller
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
        transfer sbtc-receive DEX_ADDRESS recipient (some 0x00))))

      ;; Transfer 0.6% immediately to swap fee wallet
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
        transfer sbtc-swap-fee DEX_ADDRESS 'SP1FD5DXTJW8V5E6ZVDBZS83B3T6YM82QCM18Y5BF (some 0x00))))

      ;; Update internal balances
      (var-set sbtc-balance (- (var-get sbtc-balance) (+ sbtc-receive sbtc-total-fee)))
      (var-set sbtc-fee-pool (+ (var-get sbtc-fee-pool) sbtc-majority-fee))
      (var-set token-balance new-token-balance)
      (var-set total-swap-fees-sent (+ (var-get total-swap-fees-sent) sbtc-swap-fee))

      (ok sbtc-receive)
    )
  )
)

(define-public (withdraw-fees (amount uint))
  (let (
    (recipient tx-sender)
    (maybe-majority (var-get majority-holder))
    (current-last-withdraw (var-get last-withdraw-amount))
  )
    (begin
      (asserts! (> amount u0) (err u400))
      (asserts! (<= amount (var-get sbtc-fee-pool)) (err u401))
      (asserts! (is-eq maybe-majority (some tx-sender)) ERR_UNAUTHORIZED)

      ;; Send SBTC fee from DEX to user
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        transfer amount DEX_ADDRESS recipient none)))

      ;; Subtract from internal pool
      (var-set sbtc-fee-pool (- (var-get sbtc-fee-pool) amount))

      ;; Update last-withdraw-amount if conditions are met
      (if (and (> amount current-last-withdraw) 
               (< amount MAX_WITHDRAW_CAP))
        (var-set last-withdraw-amount amount)
        false)

      (ok amount)
    )
  )
)

;; Token Locking Logic

(define-public (lock-tokens (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.mas-sats transfer amount tx-sender DEX_ADDRESS (some 0x00)))
    (let ((currently-locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender })))))
      (map-set locked-balances { user: tx-sender } { amount: (+ currently-locked amount) })
      (var-set total-locked (+ (var-get total-locked) amount))
    )
    (ok true)
  )
)

(define-public (unlock-tokens (amount uint))
  (let (
    (locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender }))))
    (recipient tx-sender)  ;; Capture user address before as-contract
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= locked amount) ERR_NOTHING_TO_UNLOCK)
      ;; Use can-unlock to check if fee pool meets threshold
      (asserts! (unwrap-panic (can-unlock)) ERR_FEE_POOL_TOO_LOW)
      ;; Use as-contract so DEX can transfer its own tokens to the recipient
      (try! (as-contract (contract-call? 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.mas-sats transfer amount DEX_ADDRESS recipient (some 0x00))))
      (map-set locked-balances { user: recipient } { amount: (- locked amount) })
      (var-set total-locked (- (var-get total-locked) amount))
      (ok true)
    )
  )
)

(define-public (claim-majority-holder-status)
  (let (
    (user-locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender }))))
    (total (var-get total-locked))
  )
    (begin
      (asserts! (> total u0) ERR_NOTHING_TO_UNLOCK)
      (if (> (* user-locked u100) (/ (* total u100) u2))
        (begin
          (var-set majority-holder (some tx-sender))
          (ok true)
        )
        ERR_NOT_MAJORITY
      )
    )
  )
)

;; -----------------------------
;; READ-ONLY FUNCTIONS
;; -----------------------------

(define-read-only (get-sbtc-balance) (ok (var-get sbtc-balance)))
(define-read-only (get-sbtc-fee-pool) (ok (var-get sbtc-fee-pool)))
(define-read-only (get-token-balance) (ok (var-get token-balance)))

(define-read-only (get-buyable-token-details (sbtc-amount uint))
  (let (
    (current-sbtc-balance (+ (var-get sbtc-balance) (var-get virtual-sbtc-amount)))
    (current-token-balance (var-get token-balance))
    (sbtc-total-fee (/ (* sbtc-amount u21) u1000))  ;; 2.1%
    (sbtc-swap-fee (/ (* sbtc-total-fee u6) u21))   ;; 0.6%
    (sbtc-majority-fee (/ (* sbtc-total-fee u15) u21))  ;; 1.5%
    (sbtc-after-fee (- sbtc-amount sbtc-total-fee))
    (k (* current-token-balance current-sbtc-balance))
    (new-sbtc-balance (+ current-sbtc-balance sbtc-after-fee))
    (new-token-balance (/ k new-sbtc-balance))
    (tokens-out (- current-token-balance new-token-balance))
  )
    (ok {
      fee: sbtc-total-fee,
      swap-fee: sbtc-swap-fee,
      majority-fee: sbtc-majority-fee,
      buyable-token: tokens-out,
      sbtc-buy: sbtc-after-fee,
      new-token-balance: new-token-balance,
      sbtc-balance: (var-get sbtc-balance),
      new-sbtc-balance: new-sbtc-balance,
      token-balance: (var-get token-balance)
    })
  )
)

(define-read-only (get-sellable-sbtc (token-amount uint))
  (let (
    (current-sbtc-balance (+ (var-get sbtc-balance) (var-get virtual-sbtc-amount)))
    (current-token-balance (var-get token-balance))
    (k (* current-token-balance current-sbtc-balance))
    (new-token-balance (+ current-token-balance token-amount))
    (new-sbtc-balance (/ k new-token-balance))
    (sbtc-out (- (- current-sbtc-balance new-sbtc-balance) u1))  ;; round protection
    (sbtc-total-fee (/ (* sbtc-out u21) u1000))  ;; 2.1%
    (sbtc-swap-fee (/ (* sbtc-total-fee u6) u21))   ;; 0.6%
    (sbtc-majority-fee (/ (* sbtc-total-fee u15) u21))  ;; 1.5%
    (sbtc-receive (- sbtc-out sbtc-total-fee))
  )
    (ok {
      fee: sbtc-total-fee,
      swap-fee: sbtc-swap-fee,
      majority-fee: sbtc-majority-fee,
      sbtc-out: sbtc-out,
      sbtc-receive: sbtc-receive,
      new-token-balance: new-token-balance,
      current-sbtc-balance: current-sbtc-balance,
      new-sbtc-balance: new-sbtc-balance,
      token-balance: (var-get token-balance)
    })
  )
)

(define-read-only (get-locked-balance (user principal))
  (ok (default-to u0 (get amount (map-get? locked-balances { user: user }))))
)

(define-read-only (get-total-locked)
  (ok (var-get total-locked))
)

(define-read-only (get-majority-holder)
  (ok (var-get majority-holder))
)

;; NEW: Dynamic threshold function for frontend display
(define-read-only (get-threshold)
  (ok (if (is-eq (var-get last-withdraw-amount) u0)
    DEFAULT_UNLOCK_THRESHOLD  ;; use 1500 if no withdrawals yet
    (var-get last-withdraw-amount) ;; use last withdrawal amount
  ))
)

;; NEW: Can unlock check using dynamic threshold
(define-read-only (can-unlock)
  (ok (>= (var-get sbtc-fee-pool) (unwrap-panic (get-threshold))))
)

;; NEW: Get last withdraw amount for debugging/display
(define-read-only (get-last-withdraw-amount)
  (ok (var-get last-withdraw-amount))
)

;; NEW: Get total swap fees sent to track 0.6% fees
(define-read-only (get-total-swap-fees-sent)
  (ok (var-get total-swap-fees-sent))
)