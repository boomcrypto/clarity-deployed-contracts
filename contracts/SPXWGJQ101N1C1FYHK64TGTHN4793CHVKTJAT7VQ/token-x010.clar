;; sip010-token
(impl-trait .trait-sip-010.sip-010-trait)

;; xtoken
(define-fungible-token xtoken)

;; (define-constant contract-owner tx-sender)
(define-data-var contract-owner principal tx-sender)

(define-constant err-owner-only (err u100))
(define-constant err-amount-zero (err u101))
(define-constant err_transfer_failed (err u1001))

;; Stores metadata (optional 256-character UTF-8 string).
(define-data-var token-uri (optional (string-utf8 256)) none)

(define-read-only (get-symbol)
  (ok "X1")
)

(define-read-only (get-balance (who principal) )
 (ok (ft-get-balance xtoken who))
)
(define-read-only (get-total-supply)
 (ok (ft-get-supply xtoken))
)
(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))


 ;; Validate input: Ensure the string length is within allowed limits
    ;; (asserts! (<= (len value) u256) (err u102))
;;   some: Wraps the new value in an optional type.
  (if (is-eq tx-sender (var-get contract-owner))
    (ok (var-set token-uri (some value)))
    (err err-owner-only)
  )
)


(define-read-only (get-name)
  (ok "xtoken")
)
(define-read-only (get-decimals)
  (ok u6)
)

;; Custom function to mint tokens, only available to the contract owner
(define-public (mint (amount uint) (who principal))
  (begin
    (asserts! (is-eq who (var-get contract-owner)) err-owner-only)
    (asserts! (> amount u0) err-amount-zero)
    ;; amount, who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-mint? xtoken amount who)
  )
)

(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; Ensure the transfer amount is valid
    (asserts! (> amount u0)  err-amount-zero)

    ;; Perform the token transfer
    (asserts! 
      (is-ok (ft-transfer? xtoken amount sender recipient))
     err_transfer_failed
    )

    ;; Print optional memo (if provided)
    (match memo to-print (print to-print) 0x)

    ;; Return success
    (ok true)
  )
)
(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq owner (var-get contract-owner)) err-owner-only)
    (asserts! (> amount u0) (err u100))
    ;; (asserts! (>= (ft-get-balance owner) amount) (err u101))
   (try!  (ft-burn? xtoken amount owner))
    (ok true)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-balance-fixed (who principal))
  (ok (ft-get-balance xtoken who))
)

(define-read-only (get-total-supply-fixed)
  (ok (ft-get-supply xtoken))
)



(define-public (mint-fixed (amount uint) (who principal))
  (begin
    ;; Reuse the `mint` logic
    (mint amount who)
  )
)

(define-public (burn-fixed (amount uint) (owner principal))
  (begin
    ;; Reuse the `burn` logic
    (burn amount owner)
  )
)

(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    ;; Call the `transfer` function directly with the same parameters
    (transfer amount sender recipient memo)
  )
)

