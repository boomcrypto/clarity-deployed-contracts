(impl-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.sip-010-trait.sip-010-trait)
(impl-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.token-trait.token-trait)

(define-fungible-token ROMA u21000000000000)
(define-constant max-supply u21000000000000)
(define-constant cntrct-owner tx-sender)

(define-data-var current-divisor uint u1)
(define-data-var next-target-divisor uint u10000000000000)

;; error handling
(define-constant permission-denied-err (err u403))
(define-constant not-enough-funds-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant invalid-amount-err (err u409)) ;; conflict
(define-constant err-invalid-value (err u422)) ;; conflict
(define-constant contract-err (err u500)) ;; conflict

;; admin contracts
(define-data-var administrative-contracts (list 100 principal) (list) )
(define-data-var current-removing-administrative (optional principal) none )
;; is address an administrative address
(define-private (is-administrative (address principal))
  (or
    (is-eq cntrct-owner address )
    (not (is-none (index-of (var-get administrative-contracts) address)) )
  )
)
(define-read-only (is-admin (address principal))
  (begin
    (asserts! (is-administrative address) permission-denied-err)
    (ok u1)
  )
)
(define-public (add-address-to-administrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set administrative-contracts (unwrap-panic (as-max-len? (append (var-get administrative-contracts) address) u100) )) contract-err )
    (ok true)
  )
)
(define-private (filter-remove-from-administrative 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-administrative))
  )
)
(define-public (remove-address-from-adminstrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-administrative (some address) ) contract-err )
    (asserts! (var-set administrative-contracts (filter filter-remove-from-administrative (var-get administrative-contracts) ) ) contract-err )
    (ok true)
  )
)


;; minters contracts
(define-data-var minter-contracts (list 100 principal) (list) )
(define-data-var current-removing-minter (optional principal) none )
;; is address an minter address
(define-private (is-minter (address principal))
    (or
      (is-eq cntrct-owner address )
      (not (is-none (index-of (var-get minter-contracts) address)) )
    )
  )
(define-read-only (is-minter-address (address principal))
  (begin
    (asserts! (is-minter address) permission-denied-err)
    (ok u1)
  )
)
(define-public (add-address-to-minter
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set minter-contracts (unwrap-panic (as-max-len? (append (var-get minter-contracts) address) u100) )) (err u2 ) )
    (ok true)
  )
)
(define-private (filter-remove-from-minter 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-minter))
  )
)
(define-public (remove-address-from-minter
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-minter (some address) ) (err u2) )
    (asserts! (var-set minter-contracts (filter filter-remove-from-minter (var-get minter-contracts) ) ) (err u3) )
    (ok true)
  )
)

;; return if is in minter or administrative addresses
(define-private (is-minter-or-administrative (address principal))
    (or 
      (is-administrative address)
      (is-minter address)
    )
  )




;; bonus percentage for minting
(define-data-var bonus-percentage uint u0)
;; percentage is x100
(define-public (set-bonus-percentage (percentage uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (>= percentage u0) err-invalid-value)
    (asserts! (<= percentage u10000) err-invalid-value)
    (var-set bonus-percentage percentage)
    (ok u1)
  )
)

;; bonus contracts
(define-data-var bonus-contracts (list 100 principal) (list) )
(define-data-var current-removing-bonus (optional principal) none )
;; is address a bonus address
(define-private (is-bonus (address principal))
    (or
      (is-eq cntrct-owner address )
      (not (is-none (index-of (var-get bonus-contracts) address)) )
    )
  )
(define-read-only (is-bonus-address (address principal))
  (begin
    (asserts! (is-bonus address) permission-denied-err)
    (ok u1)
  )
)
(define-public (add-address-to-bonus
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set bonus-contracts (unwrap-panic (as-max-len? (append (var-get bonus-contracts) address) u100) )) (err u2 ) )
    (ok true)
  )
)
(define-private (filter-remove-from-bonus 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-bonus))
  )
)
(define-public (remove-address-from-bonus
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-bonus (some address) ) (err u2) )
    (asserts! (var-set bonus-contracts (filter filter-remove-from-bonus (var-get bonus-contracts) ) ) (err u3) )
    (ok true)
  )
)
(define-read-only (list-bonus-contracts)
  (ok (var-get bonus-contracts))
  )
(define-read-only (get-bonus-percentage)
  (ok (var-get bonus-percentage))
  )


;; mint token preventing runtime error
(define-private (mint-amount (amount uint) (address principal))
  (if 
    (<= (+ (ft-get-supply ROMA) amount) max-supply)
    (ft-mint? ROMA amount address)
    (if 
      ( is-eq u0 (- max-supply (ft-get-supply ROMA)) )
      (ok true)
      (ft-mint? ROMA (- max-supply (ft-get-supply ROMA)) address)
    )
  )
)


;; mint bonuses to bonus contracts
(define-data-var current-mint-amount uint u0 )
(define-private (give-address-bonus (address principal))
    (unwrap-panic (mint-amount (/ (* ( / (var-get current-mint-amount) u100 ) (var-get bonus-percentage) ) u100) address))
  )
(define-private (mint-bonuses (amount uint))
  (if
    (> (var-get bonus-percentage) u0)
    (begin
      (var-set current-mint-amount amount)
      (map give-address-bonus (var-get bonus-contracts) )
      true
    )
    true
  )
)



;; double divisor for targeting the step
(define-private (double-divisor)
  (if (> (ft-get-supply ROMA) (var-get next-target-divisor))
    (begin
      (var-set current-divisor (* (var-get current-divisor) u2))
      (var-set next-target-divisor 
        (+ 
          (/ 
            (- 
              max-supply
              (var-get next-target-divisor)
            ) 
            u2 
          ) 
          (var-get next-target-divisor) 
        ) )
      true
    )
    true
  )
)



;; Public functions
(define-read-only (get-name)
  (ok "ROMATOKEN"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-symbol)
  (ok "ROMA"))

(define-read-only (get-token-uri)
  (ok none))

(define-read-only (get-total-supply)
  (ok (ft-get-supply ROMA)))

;; Transfers tokens to a specified principal.
(define-public (transfer (amount uint) (sender principal) (recipient principal) (bf (optional (buff 34))) )
  (if (is-eq sender tx-sender)
    (match (ft-transfer? ROMA amount tx-sender recipient)
      result (ok true)
      error (ft-transfer-err error))
  permission-denied-err))

;; get address token balance
(define-read-only (get-balance (owner principal))
   (ok (ft-get-balance ROMA owner)))

(define-read-only (get-balance-of (owner principal))
   (ok (ft-get-balance ROMA owner)))

(define-read-only (get-current-supply)
   (ok (ft-get-supply ROMA)))

(define-read-only (get-current-divisor)
   (ok (var-get current-divisor)))

(define-read-only (get-next-target-divisor)
   (ok (var-get next-target-divisor)))

;; divide amount with current divisor
(define-private (get-amount-divided (amount uint))
    (/ amount (var-get current-divisor))
  )

;; Mint new tokens.
(define-public (mint (account principal) (amount uint))
    (let ((divided-amount (get-amount-divided amount)))
      (asserts! (is-minter-or-administrative tx-sender) permission-denied-err)
      (unwrap-panic (mint-amount divided-amount account))
      (mint-bonuses divided-amount )
      (asserts! (double-divisor) contract-err )
      (ok divided-amount)))

(define-public (burn (account principal) (amount uint))
    (begin
      (asserts! (is-eq account tx-sender) permission-denied-err)
      (ft-burn? ROMA amount account)
    )
)

(define-private (ft-transfer-err (code uint))
  (if (is-eq u1 code)
    not-enough-funds-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        invalid-amount-err
        (err code)))))


;; Initialize the contract giving 1M to contract owner
(begin
  (mint cntrct-owner u1000000000000))