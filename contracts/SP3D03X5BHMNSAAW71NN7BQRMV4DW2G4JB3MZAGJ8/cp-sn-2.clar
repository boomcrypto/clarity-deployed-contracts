;; $SNOW FT Contract
;; This contract represents the $SNOW FT - the fungible token for the CrashPunks metaverse.
;; Written by StrataLabs

;; $SNOW FT Unique Properties
;; 1. Minting should only be allowed by the staking contract

;;(impl-trait .ft-trait.sip-010-trait)
(impl-trait 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.ft-trait.sip-010-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant contract-owner tx-sender)
(define-constant TOKEN_NAME "SNOW")
(define-constant TOKEN_SYMBOL "SNW")
(define-constant TOKEN_DECIMALS u8)
(define-constant TOKEN_URI none)
(define-constant TOKEN_MAX_SUPPLY u100000000000000)

;;;;;;;;;;;;;;;;;;;
;; FT Vars/Cons ;;
;;;;;;;;;;;;;;;;;;;

(define-fungible-token snow TOKEN_MAX_SUPPLY)

;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;

(define-constant ERR_SENDER_NOT_VALID (err u1000))
(define-constant ERR_SENDER_AND_RECIPENT_IS_EQUAL (err u1001))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u1002))
(define-constant ERR_GETING_BALANCE_OF_SENDER (err u1003))
(define-constant ERR_SENDER_BALANCE_NOT_VALID (err u1004))
(define-constant ERR_NOT_ALLOWED (err u1005))
(define-constant ERR_RECIPIENT_NOT_VALID (err u1006))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SIP10 Functions ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin

    ;; assert sender is tx-sender
    (asserts! (is-eq tx-sender sender) ERR_SENDER_NOT_VALID)

    ;; assert sender is not recipient
    (asserts! (not (is-eq sender recipient)) ERR_SENDER_AND_RECIPENT_IS_EQUAL)

    ;; assert amount transferred > 0
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)

    ;; assert amount transferred =< balance of sender
    (asserts! (<= amount (unwrap! (get-balance sender) ERR_GETING_BALANCE_OF_SENDER)) ERR_SENDER_BALANCE_NOT_VALID)

    ;; transfer
    (try! (ft-transfer? snow amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance snow account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply snow))
)

(define-read-only (get-token-uri)
  (ok TOKEN_URI)
)

(define-read-only (get-max-supply)
  (ok TOKEN_MAX_SUPPLY)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Mint Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (mint (amount uint) (recipient principal))
  (let
    (
      (current-total-supply (ft-get-supply snow))
    )

    ;; asserts that caller is either admin(?) or staking contract
    ;;(asserts! (or (is-eq tx-sender contract-owner) (is-eq contract-caller .staking)) (err u3))
    (asserts! (or (is-eq tx-sender contract-owner) (is-eq contract-caller 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-staking-2)) (err u3))


    ;; asserts that recipient is not staking contract
    ;;(asserts! (not (is-eq recipient .staking)) ERR_RECIPIENT_NOT_VALID)
    (asserts! (not (is-eq recipient 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-staking-2)) ERR_RECIPIENT_NOT_VALID)

    ;; asserts that amount is greater than 0
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)

    ;; asserts that amount is less than
    (asserts! (<= amount (- TOKEN_MAX_SUPPLY current-total-supply)) ERR_NOT_ALLOWED)
    (ft-mint? snow amount recipient)
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_SENDER_NOT_VALID)
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)
    (asserts! (<= amount (ft-get-balance snow sender)) ERR_SENDER_BALANCE_NOT_VALID)
    (ft-burn? snow amount sender)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;