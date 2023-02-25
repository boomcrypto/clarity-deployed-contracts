
;; creature-racer-payment
;; payment deposit contact. Each payment is split to operator
;; wallet,  raward pool and referral pool

;; 
;; =========
;; CONSTANTS
;; =========
;;

;; contract-owner: whoever deployed the contract. It's the only
;;                 principal allowed to change other roles.
(define-constant contract-owner tx-sender)


;; Error definitions
;; -----------------

(define-constant err-forbidden (err u403))
(define-constant err-operator-unset (err u1001))
(define-constant err-insufficient-amount (err u2001))
(define-constant err-unknown-transfer-error (err u2003))


;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;

;; Principals / wallets
;; --------------------

;; Address of principal which is currently supported by this contract
(define-data-var supported-wallet (optional principal) none)


;; Deposit split
;; -------------

;; operator's share in every deposit, defaults
;; to 100uSTX
(define-data-var portion-for-operator uint u100)

;; percent of stx to be transferred to supported wallet
(define-data-var percent-for-supported-wallet uint u0)

;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;


;; Receive (deposit) funds
;; -----------------------
;; Arguments:
;;  amount-ustx: amount of microSTX to be transferred
;; Returns:
;;  (ok true)   - funds accepted and allocated
;;  (err u1)    - not enough STX on sender account
;;  (err u2)    - called by same principal
;;  (err u3)    - attempt to transfer 0 STX
;;  (err u4)    - unauthorized transfer attempt
;;  (err u1001) - operator neeeds to be set
;;  (err u2001) - amount is less than operator income
(define-public (receive-funds (amount-ustx uint))
    (let (
          (origin tx-sender)
          (operator-principal
           (unwrap! (unwrap! 
                  (contract-call? .creature-racer-admin-v2
                                  get-operator)
                  err-operator-unset) err-operator-unset))
          
          (operator-income (var-get portion-for-operator))
          (supported-maybe (var-get supported-wallet))
          )
      (asserts! (> amount-ustx operator-income) 
                err-insufficient-amount)
      (let (
            (portion-for-reward-pool 
             (- amount-ustx operator-income))
            (referral-pool-share 
             (unwrap-panic 
              (as-contract
               (contract-call? .creature-racer-referral-nft-v2
                               calculate-referral-profit
                               origin portion-for-reward-pool)))
              )
            (portion-for-referral-pool 
             (get profit referral-pool-share))
            (pct-for-supported-wallet 
             (if (is-some supported-maybe) 
                 (var-get percent-for-supported-wallet) u0))
            )
        (unwrap-panic (stx-transfer? amount-ustx tx-sender 
                                     .creature-racer-payment-v2))
        
        (if (> portion-for-referral-pool u0)
            (try! (as-contract 
                    (stx-transfer? portion-for-referral-pool
                                   tx-sender
                                   .creature-racer-referral-pool-v2)))
            false)
        (asserts! (try!
                  (as-contract
                   (stx-transfer? operator-income tx-sender
                                  operator-principal)))
                 err-unknown-transfer-error)
        

        (let
            (
             (portion-for-reward-pool-2
              (- portion-for-reward-pool 
                 portion-for-referral-pool))
             (amount-for-supported-wallet 
              (/ (* portion-for-reward-pool-2 
                    pct-for-supported-wallet)
                 u100))
             )
          (if (> amount-for-supported-wallet u0)
              (try! (as-contract
               (stx-transfer? amount-for-supported-wallet
                             tx-sender 
                             (unwrap-panic supported-maybe))))
              false
              )
          
          (as-contract
           (contract-call? .creature-racer-reward-pool-v2
                           receive-funds
                           (- portion-for-reward-pool-2
                              amount-for-supported-wallet)))
          )
        )
      )
)

;; Set portion for operator
;; ------------------------
;; Set amount of microSTX to be transferred to operator's wallet from
;; each receive-funds amount.
;; 
;; Arguments:
;;  amount: microSTX to be deducted from each payment and transferred
;;          to operator account.
;; Returns:
;;  (result uint uint): previous value
(define-public (set-portion-for-operator (amount uint))
    (let ((old-portion (var-get portion-for-operator)))
      (asserts! (is-eq tx-sender contract-owner) err-forbidden)
      ;; #[allow(unchecked_data)]
      (var-set portion-for-operator amount)
      (ok old-portion)
      )
)

;; Change / reset supported principal
;; ----------------------------------
;; Returns:
;; (result (optional principal) uint) principal of previous supported wallet

(define-public (change-supported-wallet (new-supported (optional principal))
                                        (new-percent uint))
    (let ((old-wallet (var-get supported-wallet)))
      (asserts! (is-eq tx-sender contract-owner) err-forbidden)
      ;; #[allow(unchecked_data)]
      (var-set supported-wallet new-supported)
      ;; #[allow(unchecked_data)]
      (var-set percent-for-supported-wallet new-percent)
      (ok old-wallet)
      )
)


