;; title: $MAX
;; version: 0.1
;; summary: A toy token for demonstration purposes
;; description: 

;; traits
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; constants
(define-constant contract-owner tx-sender)
(define-constant TOKEN_NAME "MAX")
(define-constant TOKEN_SYMBOL "$MAX")
(define-constant TOKEN_DECIMALS u3)
(define-constant TOKEN_URI none)
(define-constant TOKEN_MAX_SUPPLY u100)

;; error messages
(define-constant ERR_SENDER_NOT_VALID (err u1000))
(define-constant ERR_SENDER_AND_RECIPENT_IS_EQUAL (err u1001))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u1002))
(define-constant ERR_GETING_BALANCE_OF_SENDER (err u1003))
(define-constant ERR_CHECKING_OWNER (err u1004))
(define-constant ERR_USER_NOT_A_MAX_FANS_HOLDER (err u1005))
(define-constant ERR_SENDER_BALANCE_NOT_VALID (err u1006))
(define-constant ERR_NOT_ALLOWED (err u1007))
(define-constant ERR_RECIPIENT_NOT_VALID (err u1008))


;; token definitions
(define-fungible-token MAX TOKEN_MAX_SUPPLY)

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;; SIP-010 public functions
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
    (try! (ft-transfer? MAX amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)


;; non-SIP-010 public functions
;; mint
(define-public (mint (amount uint) (recipient principal))
  (let
    (
      (current-total-supply (ft-get-supply MAX))
    )

    ;; asserts that amount is greater than 0
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)

    ;; asserts that caller is a MAX-FANS holder
    (asserts! (unwrap! (contract-call? .nft-factory check-owner recipient) ERR_CHECKING_OWNER) ERR_USER_NOT_A_MAX_FANS_HOLDER)

    ;; asserts that amount is less than
    (asserts! (<= amount (- TOKEN_MAX_SUPPLY current-total-supply)) ERR_NOT_ALLOWED)
    (ft-mint? MAX amount recipient)
  )
)

;; burn
(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_SENDER_NOT_VALID)
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)
    (asserts! (<= amount (ft-get-balance MAX sender)) ERR_SENDER_BALANCE_NOT_VALID)
    (ft-burn? MAX amount sender)
  )
)


;; read only functions
;; SIP-010 functions
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
  (ok (ft-get-balance MAX account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply MAX))
)

(define-read-only (get-token-uri)
  (ok TOKEN_URI)
)

(define-read-only (get-max-supply)
  (ok TOKEN_MAX_SUPPLY)
)

;; private functions
;;

