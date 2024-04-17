
;; title: USDB Token Contract

(impl-trait .sip-10.sip-010-trait)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Cons ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

(define-constant TOKEN_NAME "USDB")
(define-constant TOKEN_SYMBOL "USDB")
(define-constant TOKEN_DECIMALS u8)
(define-constant TOKEN_MAX_SUPPLY u1000000000000000)
(define-constant authorized-minter-and-burner .v-testing-v4)

;; Defines the USDB fungible token
(define-fungible-token usdb TOKEN_MAX_SUPPLY)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Errs ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

(define-constant err-unauthorized (err u1001))
(define-constant err-unauthorized-transfer (err u1002))
(define-constant err-insufficient-balance (err u1003))

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Read ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

(define-read-only (get-total-supply)
  (ok (ft-get-supply usdb))
)

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
  (ok (ft-get-balance usdb account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Maps ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Vars ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

(define-data-var auth-mint-burn (list 10 principal) (list .v-testing-v4 .s-testing-v4))

;; Var: total-supply
;; Description: Stores the total supply of USDB in circulation.
(define-data-var total-supply uint u0)
(define-data-var token-uri (string-utf8 256) u"")
;; List of trusted oracle contracts
(define-data-var trusted-oracles (list 10 principal) (list))


;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Public ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

;; Function: mint-usdb
;; Description: Mints new USDB against collateral deposited in a vault, only callable by the Vault Manager contract.
;; Inputs: 
;; - user (principal): The user for whom USDB is being minted.
;; - usdb-amount (uint): The amount of USDB to mint.

(define-public (mint-usdb (user principal) (usdb-amount uint))
  (begin
    (asserts! (is-some (index-of? (var-get auth-mint-burn) contract-caller)) err-unauthorized)
    (ft-mint? usdb usdb-amount user)
  )
)

;; Function: burn-usdb
;; Description: Burns USDB when collateral is withdrawn from a vault, only callable by the Vault Manager contract.
;; Inputs: 
;; - user (principal): The user whose USDB is being burned.
;; - usdb-amount (uint): The amount of USDB to burn.

(define-public (burn-usdb (user principal) (usdb-amount uint))
  (begin
    (asserts! (is-some (index-of? (var-get auth-mint-burn) contract-caller)) err-unauthorized)
    (ft-burn? usdb usdb-amount user)
  )
)

;; Function: transfer-usdb
;; Description: Transfers USDB from one user to another.
;; Inputs: 
;; - sender (principal): The user sending USDB.
;; - recipient (principal): The user receiving USDB.
;; - usdb-amount (uint): The amount of USDB to transfer.

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-some (index-of? (var-get auth-mint-burn) contract-caller))) err-unauthorized-transfer)

    (match (ft-transfer? usdb amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)


