;; Title: DDE000 Governance Token
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis:
;; This extension defines the governance token of DeGrants program.
;; Description:
;; The governance token is a simple SIP010-compliant fungible token
;; with some added functions to make it easier to manage by
;; DeGrants DAO proposals and extensions.

(impl-trait .dao-traits-v0.governance-token-trait)
(impl-trait .dao-traits-v0.sip010-ft-trait)
(impl-trait .dao-traits-v0.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-fungible-token wisdom)
(define-fungible-token wisdom-locked)

(define-data-var token-name (string-ascii 32) "Wisdom")
(define-data-var token-symbol (string-ascii 10) "WIS")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/wisdom.json"))
(define-data-var token-decimals uint u6)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .degrants-dao) (contract-call? .degrants-dao is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

;; governance-token-trait

(define-public (dmg-transfer (amount uint) (sender principal) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-transfer? wisdom amount sender recipient)
	)
)

(define-public (dmg-lock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? wisdom amount owner))
		(ft-mint? wisdom-locked amount owner)
	)
)

(define-public (dmg-unlock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? wisdom-locked amount owner))
		(ft-mint? wisdom amount owner)
	)
)

(define-public (dmg-mint (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? wisdom amount recipient)
	)
)

(define-public (dmg-burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? wisdom amount owner)
	)
)

;; Other

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))
	)
)

(define-private (dmg-mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? wisdom (get amount item) (get recipient item))
)

(define-public (dmg-mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map dmg-mint-many-iter recipients))
	)
)

;; --- Public functions

;; sip010-ft-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? wisdom amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (+ (ft-get-balance wisdom who) (ft-get-balance wisdom-locked who)))
)

(define-read-only (get-total-supply)
	(ok (+ (ft-get-supply wisdom) (ft-get-supply wisdom-locked)))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; governance-token-trait

(define-read-only (dmg-get-balance (who principal))
	(get-balance who)
)

(define-read-only (dmg-has-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

(define-read-only (dmg-get-locked (owner principal))
	(ok (ft-get-balance wisdom-locked owner))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
