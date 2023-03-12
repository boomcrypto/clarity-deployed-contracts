;; Title: DME000 Governance Token
;; Author: Ross Ragsdale
;; Depends-On: 
;; Synopsis:
;; This extension defines the governance token of DungeonMaster.
;; Description:
;; The governance token is a simple SIP010-compliant fungible token
;; with some added functions to make it easier to manage by
;; DungeonMaster proposals and extensions.

(impl-trait .governance-token-trait.governance-token-trait)
(impl-trait .sip010-ft-trait.sip010-ft-trait)
(impl-trait .extension-trait.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-fungible-token charisma)
(define-fungible-token charisma-locked)

(define-data-var token-name (string-ascii 32) "Charisma")
(define-data-var token-symbol (string-ascii 10) "CHA")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-decimals uint u6)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .dungeon-master) (contract-call? .dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

;; governance-token-trait

(define-public (dmg-transfer (amount uint) (sender principal) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-transfer? charisma amount sender recipient)
	)
)

(define-public (dmg-lock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? charisma amount owner))
		(ft-mint? charisma-locked amount owner)
	)
)

(define-public (dmg-unlock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? charisma-locked amount owner))
		(ft-mint? charisma amount owner)
	)
)

(define-public (dmg-mint (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? charisma amount recipient)
	)
)

(define-public (dmg-burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? charisma amount owner)
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
	(ft-mint? charisma (get amount item) (get recipient item))
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
		(ft-transfer? charisma amount sender recipient)
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
	(ok (+ (ft-get-balance charisma who) (ft-get-balance charisma-locked who)))
)

(define-read-only (get-total-supply)
	(ok (+ (ft-get-supply charisma) (ft-get-supply charisma-locked)))
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
	(ok (ft-get-balance charisma-locked owner))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
