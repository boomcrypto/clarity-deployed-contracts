;; Define the SATZ Token Smart Contract

;; Tokenomic Constants
(define-constant TOTAL_SUPPLY u10000000000)  ;; 10 billion total supply
(define-constant TREASURY 'SP3D1VC4WBM939SA65CTHS7HEVF8GJA6N9Y2APJWV)  ;; Treasury wallet address
(define-constant MAX_TOKEN_TAX u5)  ;; Maximum token tax (5%)

;; Error Codes
(define-constant ERR_REENTRANCY_DETECTED u1001)
(define-constant ERR_TAX_EXCEEDS_MAX u1003)
(define-constant ERR_TRANSFER_FAILED u1004)
(define-constant ERR_ONLY_GOVERNANCE u1005)
(define-constant ERR_INVALID_INPUT u1006)
(define-constant ERR_SUPPLY_EXCEEDED u1007)
(define-constant ERR_NO_REWARDS_AVAILABLE u1008)  ;; New error code for reward claims

;; Token Metadata
(define-constant TOKEN_NAME "Bitcoin Labz")  ;; Token name
(define-constant TOKEN_SYMBOL "SATZ")  ;; Token symbol
(define-constant TOKEN_URI "https://raw.githubusercontent.com/Bitcoinlabz/SATZ-Smart-Contract/main/metadata/logo.png") ;; Metadata URI for token logo

;; Tax Rates (all in SATZ)
(define-constant TAX-RATE u5)      ;; 5% total tax on transfers
(define-constant TREASURY-TAX u3)  ;; 3% to treasury
(define-constant HOLDERS-TAX u2)   ;; 2% to holder rewards

;; Data Variables
(define-data-var circulating-supply uint u0)  ;; Tracks circulating supply
(define-data-var last-payout-height uint u0)  ;; For future payout tracking
(define-data-var governance-address principal 'SP3D1VC4WBM939SA65CTHS7HEVF8GJA6N9Y2APJWV)  ;; Fixed governance address
(define-data-var in-claim-rewards bool false) ;; Reentrancy guard

;; Holder rewards mapping: maps a principal (holder) to a uint reward.
(define-map holder-rewards {holder: principal} uint)

;; SIP-010 Compliance Implementation
(define-fungible-token SATZ TOTAL_SUPPLY)

;; Token Metadata Function
(define-read-only (get-token-uri)
  (ok TOKEN_URI))

;; Mint Function (For Liquidity Pool Allocation)
(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get governance-address)) (err ERR_ONLY_GOVERNANCE))
    (asserts! (<= (+ (var-get circulating-supply) amount) TOTAL_SUPPLY)
              (err ERR_SUPPLY_EXCEEDED))
    (var-set circulating-supply (+ (var-get circulating-supply) amount))
    (asserts! (is-ok (ft-mint? SATZ amount recipient)) (err ERR_TRANSFER_FAILED))
    (ok amount)
  ))

;; Function to Calculate Tax and Net Transfer Amount (all values in SATZ)
(define-private (calculate-tax (amount uint))
  (let ((total-tax (/ (* amount TAX-RATE) u100))
        (treasury-tax (/ (* amount TREASURY-TAX) u100))
        (holders-tax (/ (* amount HOLDERS-TAX) u100))
        (final-amount (- amount total-tax)))
    {treasury-tax: treasury-tax, holders-tax: holders-tax, final-amount: final-amount}))

;; Transfer with Tax Function (uses tx-sender as the sender)
(define-public (transfer-with-tax (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_INPUT)) ;; Ensure amount is > 0
    (let ((tax-details (calculate-tax amount))
          (treasury-tax (get treasury-tax tax-details))
          (holders-tax (get holders-tax tax-details))
          (final-amount (get final-amount tax-details)))
      (begin
        ;; Redundant constant check for safety
        (asserts! (<= TAX-RATE MAX_TOKEN_TAX) (err ERR_TAX_EXCEEDS_MAX))
        ;; Perform the SATZ transfers: net amount to recipient, tax to treasury
        (asserts! (is-ok (ft-transfer? SATZ final-amount tx-sender recipient)) (err ERR_TRANSFER_FAILED))
        (asserts! (is-ok (ft-transfer? SATZ treasury-tax tx-sender TREASURY)) (err ERR_TRANSFER_FAILED))
        ;; Accumulate the holder's tax rewards (no tax is charged when these rewards are later claimed)
        (let ((existing (default-to u0 (map-get? holder-rewards {holder: recipient}))))
          (map-set holder-rewards {holder: recipient} (+ existing holders-tax)))
        (ok true)
      ))
  ))

;; Claim Rewards Function (holders claim their accumulated rewards in SATZ without tax)
(define-public (claim-rewards)
  (begin
    ;; Reentrancy guard
    (asserts! (not (var-get in-claim-rewards)) (err ERR_REENTRANCY_DETECTED))
    (var-set in-claim-rewards true)
    (let ((reward (default-to u0 (map-get? holder-rewards {holder: tx-sender}))))
      (asserts! (> reward u0) (err ERR_NO_REWARDS_AVAILABLE))
      ;; Ensure minting the reward does not exceed the total supply
      (asserts! (<= (+ (var-get circulating-supply) reward) TOTAL_SUPPLY) (err ERR_SUPPLY_EXCEEDED))
      (asserts! (is-ok (ft-mint? SATZ reward tx-sender)) (err ERR_TRANSFER_FAILED))
      (var-set circulating-supply (+ (var-get circulating-supply) reward))
      (map-delete holder-rewards {holder: tx-sender})
      (var-set in-claim-rewards false)
      (print {action: "reward-claimed", holder: tx-sender, amount: reward})
      (ok reward)))
  )

;; Allow External Balance Query for the Token
(define-read-only (get-balance (address principal))
  (ok (ft-get-balance SATZ address)))
