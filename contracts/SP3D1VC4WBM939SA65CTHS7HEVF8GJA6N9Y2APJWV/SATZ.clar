;; Tokenomic Constants with Tax Logic
(define-constant TOTAL_SUPPLY u10000000000)  ;; 10 billion total supply
;; Treasury wallet updated to the new address
(define-constant TREASURY 'SP3D1VC4WBM939SA65CTHS7HEVF8GJA6N9Y2APJWV)
(define-constant TAX_RATE u5)      ;; 5% total tax
(define-constant TREASURY_TAX u3)  ;; Fixed 3% treasury tax
(define-constant HOLDERS_TAX u2)   ;; Fixed 2% holders tax

;; Error Codes for Debugging
(define-constant ERR_ONLY_GOVERNANCE u1005)
(define-constant ERR_EXCEEDS_SUPPLY u1007)
(define-constant ERR_TRANSFER_FAILED u1004)
(define-constant ERR_INVALID_INPUT u1008)
(define-constant ERR_INSUFFICIENT_STX u1009)  ;; Insufficient STX provided for tax
(define-constant ERR_ALREADY_INITIALIZED u1010)  ;; Initialization already performed

;; SIP-010 Compliance Implementation
(define-fungible-token SATZ TOTAL_SUPPLY)

;; Governance Address (set to the new treasury address)
(define-data-var governance-address principal 'SP3D1VC4WBM939SA65CTHS7HEVF8GJA6N9Y2APJWV)

;; A flag to ensure the tokens are only minted once.
(define-data-var initialized bool false)

;; Holder Rewards Map (STX rewards)
(define-map holder-rewards principal uint)  ;; Tracks STX rewards per holder

;; Initialization function to mint the entire supply to the treasury wallet.
(define-public (initialize)
  (begin
    (asserts! (not (var-get initialized)) (err ERR_ALREADY_INITIALIZED))
    (var-set initialized true)
    (ft-mint? SATZ TOTAL_SUPPLY TREASURY)
  )
)

;; Function to Calculate Tax and Transfer Amount
(define-private (calculate-tax (amount uint))
  (let ((total-tax (/ (* amount TAX_RATE) u100))
        (treasury-tax-amount (/ (* amount TREASURY_TAX) u100))
        (holders-tax-amount (/ (* amount HOLDERS_TAX) u100))
        (final-amount (- amount total-tax)))
    {treasury-tax: treasury-tax-amount, holders-tax: holders-tax-amount, final-amount: final-amount}))

;; Universal Transfer Function with STX Tax
(define-public (transfer (amount uint) (sender principal) (recipient principal) (stx-amount uint) (memo (optional (buff 34))))
  (let ((sender-balance (ft-get-balance SATZ sender)))
    (begin
      ;; Validate the amount
      (asserts! (> amount u0) (err ERR_INVALID_INPUT))       ;; Amount must be greater than 0
      (asserts! (<= amount sender-balance) (err ERR_INVALID_INPUT))  ;; Amount must not exceed sender's balance

      ;; Calculate tax and validate STX payment
      (let ((tax-details (calculate-tax amount))
            (treasury-tax-portion (get treasury-tax tax-details))  ;; Avoid shadowing
            (holders-tax-portion (get holders-tax tax-details))    ;; Avoid shadowing
            (final-transfer-amount (get final-amount tax-details)) ;; Avoid shadowing
            (required-stx (+ treasury-tax-portion holders-tax-portion)))
        (begin
          ;; Validate that the provided STX amount covers the tax
          (asserts! (>= stx-amount required-stx) (err ERR_INSUFFICIENT_STX))

          ;; Perform STX transfer for treasury tax
          (asserts! (is-ok (stx-transfer? treasury-tax-portion tx-sender TREASURY)) (err ERR_TRANSFER_FAILED))
          
          ;; Distribute holder tax to the holder-rewards map
          (map-set holder-rewards recipient
            (+ holders-tax-portion (default-to u0 (map-get? holder-rewards recipient))))

          ;; Perform the SATZ transfer after tax deduction
          (asserts! (is-ok (ft-transfer? SATZ final-transfer-amount sender recipient)) (err ERR_TRANSFER_FAILED))
          (ok true)
        ))
    )))

;; Claim STX Rewards Function
(define-public (claim-rewards)
  (let ((reward (default-to u0 (map-get? holder-rewards tx-sender))))
    (begin
      (asserts! (> reward u0) (err ERR_INVALID_INPUT))  ;; Ensure there are rewards to claim
      (asserts! (is-ok (stx-transfer? reward TREASURY tx-sender)) (err ERR_TRANSFER_FAILED))
      (map-delete holder-rewards tx-sender)  ;; Remove claimed rewards
      (ok reward)
    )))

;; External Balance Query for Holder Rewards
(define-read-only (get-holder-rewards (address principal))
  (ok (default-to u0 (map-get? holder-rewards address))))

;; Update Governance Address Function
(define-public (update-governance-address (new-governance principal))
  (begin
    ;; Ensure the caller is the current governance address
    (asserts! (is-eq tx-sender (var-get governance-address)) (err ERR_ONLY_GOVERNANCE))
    ;; Ensure the new governance address is valid and not the same as the caller
    (asserts! (not (is-eq new-governance tx-sender)) (err ERR_INVALID_INPUT))
    ;; Update the governance address
    (var-set governance-address new-governance)
    (print {action: "update-governance", new-governance: new-governance})
    (ok true)
  ))
