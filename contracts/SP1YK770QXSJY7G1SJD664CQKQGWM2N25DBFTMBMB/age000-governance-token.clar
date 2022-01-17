;; Title: EDE000 Governance Token
;; Author: Marvin Janssen
;; Depends-On: 
;; Synopsis:
;; This extension defines the governance token of ExecutorDAO.
;; Description:
;; The governance token is a simple SIP010-compliant fungible token
;; with some added functions to make it easier to manage by
;; ExecutorDAO proposals and extensions.

(impl-trait .governance-token-trait.governance-token-trait)
(impl-trait .trait-sip-010.sip-010-trait)
(impl-trait .extension-trait.extension-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-not-token-owner (err u4))

(define-fungible-token alex)
(define-fungible-token alex-locked)

(define-data-var token-name (string-ascii 32) "ALEX Token")
(define-data-var token-symbol (string-ascii 10) "alex")
(define-data-var token-decimals uint u8)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-alex.json"))
(define-map approved-contracts principal bool)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised))
)

;; @desc check-is-approved
;; @restricted Approved-Contracts/Contract-Owner
;; @params sender
;; @returns (response bool)
(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) err-unauthorised))
)

;; --- Internal DAO functions

;; governance-token-trait

(define-public (edg-transfer (amount uint) (sender principal) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-transfer? alex amount sender recipient)
	)
)

(define-public (edg-lock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? alex amount owner))
		(ft-mint? alex-locked amount owner)
	)
)

(define-public (edg-unlock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? alex-locked amount owner))
		(ft-mint? alex amount owner)
	)
)

(define-public (edg-mint (amount uint) (recipient principal))
	(begin		
		(asserts! (or (is-ok (is-dao-or-extension)) (is-ok (check-is-approved))) err-unauthorised)
		(ft-mint? alex amount recipient)
	)
)

(define-public (edg-burn (amount uint) (owner principal))
	(begin
		(asserts! (or (is-ok (is-dao-or-extension)) (is-ok (check-is-approved))) err-unauthorised)
		(ft-burn? alex amount owner)
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

(define-private (edg-mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? alex (get amount item) (get recipient item))
)

(define-public (edg-mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map edg-mint-many-iter recipients))
	)
)

(define-public (edg-add-approved-contract (new-approved-contract principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set approved-contracts new-approved-contract true))
  )
)

;; --- Public functions

;; sip010-ft-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? alex amount sender recipient)
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
	(ok (+ (ft-get-balance alex who) (ft-get-balance alex-locked who)))
)

(define-read-only (get-total-supply)
	(ok (+ (ft-get-supply alex) (ft-get-supply alex-locked)))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; governance-token-trait

(define-read-only (edg-get-balance (who principal))
	(get-balance who)
)

(define-read-only (edg-has-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

(define-read-only (edg-get-locked (owner principal))
	(ok (ft-get-balance alex-locked owner))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Protocol functions

(define-constant ONE_8 (pow u10 u8))

;; @desc mint
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint (amount uint) (recipient principal))
  (edg-mint amount recipient)
)

;; @desc burn
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn (amount uint) (sender principal))
  (edg-burn amount sender)
)

;; @desc pow-decimals
;; @returns uint
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)

;; @desc fixed-to-decimals
;; @params amount
;; @returns uint
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)

;; @desc decimals-to-fixed 
;; @params amount
;; @returns uint
(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals))
)

;; @desc get-total-supply-fixed
;; @params token-id
;; @returns (response uint)
(define-read-only (get-total-supply-fixed)
  (ok (decimals-to-fixed (unwrap-panic (get-total-supply))))
)

;; @desc get-balance-fixed
;; @params token-id
;; @params who
;; @returns (response uint)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account))))
)

;; @desc transfer-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response bool)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)

;; @desc mint-fixed
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)

;; @desc burn-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)

;; for testing only
(map-set approved-contracts .alex-reserve-pool true)
(map-set approved-contracts .exchange true)
(map-set approved-contracts .faucet true)
(map-set approved-contracts tx-sender true)



