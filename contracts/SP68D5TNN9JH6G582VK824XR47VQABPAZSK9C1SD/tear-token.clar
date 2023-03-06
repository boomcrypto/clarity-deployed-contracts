;; TEAR Test Token
;; This is a test token for the upcoming ____ FT
;; Written by StrataLabs

;; Need to replace with mainnet sip-10 address
;;(impl-trait .sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard.ft-trait)


(define-constant CONTRACT_DEPLOYER tx-sender)
(define-constant TOKEN_NAME "Test Token")
(define-constant TOKEN_SYMBOL "TEAR")
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_URI none)
(define-constant TOKEN_MAX_SUPPLY u1900000000000000)
(define-constant ERR_SENDER_NOT_VALID (err u1000))
(define-constant ERR_SENDER_AND_RECIPENT_IS_EQUAL (err u1001))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u1002))
(define-constant ERR_GETING_BALANCE_OF_SENDER (err u1003))
(define-constant ERR_SENDER_BALANCE_NOT_VALID (err u1004))
(define-constant ERR_NOT_ALLOWED (err u1005))
(define-constant ERR_RECIPIENT_NOT_VALID (err u1006))

(define-fungible-token uTEAR TOKEN_MAX_SUPPLY)

;; in tests
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_SENDER_NOT_VALID)
    (asserts! (not (is-eq sender recipient)) ERR_SENDER_AND_RECIPENT_IS_EQUAL)
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)
    (asserts! (<= amount (unwrap! (get-balance-of sender) ERR_GETING_BALANCE_OF_SENDER)) ERR_SENDER_BALANCE_NOT_VALID)
    (try! (ft-transfer? uTEAR amount sender recipient))
    (ok true)
  )
)

;; in tests
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; in tests
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; in tests
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; in tests
(define-read-only (get-balance-of (account principal))
  (ok (ft-get-balance uTEAR account))
)

;; in tests
(define-read-only (get-total-supply)
  (ok (ft-get-supply uTEAR))
)

;; in tests
(define-read-only (get-token-uri)
  (ok TOKEN_URI)
)

;; in tests
(define-read-only (get-max-supply)
  (ok TOKEN_MAX_SUPPLY)
)

;; in tests
(define-read-only (get-contract-deployer)
  (ok CONTRACT_DEPLOYER)
)

;; in tests
(define-public (mint (amount uint) (recipient principal))
  (let
    (
      (tokenTotalSupply (ft-get-supply uTEAR))
    )
    (asserts! (is-eq contract-caller .tear-mining-staking) ERR_NOT_ALLOWED)
    (asserts! (not (is-eq contract-caller recipient)) ERR_RECIPIENT_NOT_VALID)
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)
    (asserts! (<= amount (- TOKEN_MAX_SUPPLY tokenTotalSupply)) ERR_NOT_ALLOWED)
    (ft-mint? uTEAR amount recipient)
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq sender tx-sender) ERR_NOT_ALLOWED)
    (asserts! (> amount u0) ERR_INSUFFICIENT_AMOUNT)
    (asserts! (<= amount (ft-get-balance uTEAR sender)) ERR_SENDER_BALANCE_NOT_VALID)
    (ft-burn? uTEAR amount sender)
  )
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint})))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior okValue result
               errValue (err errValue)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint }))
  (send-token-with-memo (get amount recipient) (get to recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal))
  (let
    (
      (transferOk (try! (transfer amount tx-sender to)))
    )
    (ok transferOk)
  )
)
