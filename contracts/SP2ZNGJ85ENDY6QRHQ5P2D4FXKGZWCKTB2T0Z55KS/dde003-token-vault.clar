;; Title: DDE003 Token Vault
;; Author: rozar.btc
;; Depends-On: DDE000
;; Synopsis:
;; The Token Vault is a extention designed for managing token deposits and withdrawals in a secure manner. 
;; It ensures that only authorized DAO members or approved extensions can interact with the stored tokens.
;; Description:
;; The Token Vault is a extention that allows token management under specific authorization constraints. 
;; It interacts with tokens adhering to the SIP010 Fungible Token Trait. 
;; The contract provides methods for depositing tokens into the vault by any user and 
;; withdrawing them to specified recipients but only by the DAO or its authorized extensions.

(impl-trait .dao-traits-v0.extension-trait)
(use-trait token-trait .dao-traits-v0.sip010-ft-trait)

(define-constant err-unauthorized (err u1000))

(define-map tokens principal bool)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .degrants-dao) (contract-call? .degrants-dao is-extension contract-caller)) err-unauthorized))
)

;; --- Vault

(define-public (deposit (token <token-trait>) (amount uint))
	(contract-call? token transfer amount tx-sender (as-contract tx-sender) none)
)

(define-public (withdraw (token <token-trait>) (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? token transfer amount tx-sender recipient none))
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

