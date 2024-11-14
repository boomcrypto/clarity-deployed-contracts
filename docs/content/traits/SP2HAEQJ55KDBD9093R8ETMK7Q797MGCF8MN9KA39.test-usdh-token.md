---
title: "Trait test-usdh-token"
draft: true
---
```
(impl-trait .sip-010-trait.sip-010-trait)
(impl-trait .interim-token-trait.interim-token-trait)
(use-trait token-migration-trait .token-migration-trait.token-migration-trait)

(define-fungible-token usdh)

(define-constant ERR_NOT_AUTHORIZED (err u1401))
(define-constant ERR_DEPRECATED_TOKEN (err u1402))
(define-constant ERR_NOT_MIGRATION_MANAGER (err u1403))

;;-------------------------------------
;; Const and vars
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var token-name (string-ascii 32) "Test USDh")

(define-data-var migration-start-height uint u0)
(define-data-var migration-manager (optional principal) none)

;;-------------------------------------
;; SIP-010
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply usdh))
)

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok "USDh")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance usdh account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-not-migrated))
    (asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) ERR_NOT_AUTHORIZED)

    (match (ft-transfer? usdh amount sender recipient)
      response (begin
        (print memo)
        (print { action: "transfer", data: { sender: tx-sender, recipient: recipient, amount: amount, block-height: block-height } })
        (ok response)
      )
      error (err error)
    )
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (contract-call? .test-hq check-is-admin tx-sender))
    (ok (var-set token-uri value))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

(define-public (mint-for-protocol (amount uint) (recipient principal))
  (begin
    (try! (is-not-migrated))
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-mint? usdh amount recipient)
  )
)

(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (is-not-migrated))
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-burn? usdh amount sender)
  )
)

(define-public (burn (amount uint))
  (ft-burn? usdh amount tx-sender)
)

;;-------------------------------------
;; Migration
;;-------------------------------------

(define-read-only (is-not-migrated)
	(ok (asserts! (is-eq u0 (var-get migration-start-height)) ERR_DEPRECATED_TOKEN))
)

(define-public (start-migration (new-token-name (string-ascii 32)) (manager <token-migration-trait>))
	(begin
		(try! (is-not-migrated))
		(try! (contract-call? .test-hq check-is-owner contract-caller))
		(var-set migration-start-height burn-block-height)
		(var-set token-name new-token-name)
		(var-set migration-manager (some (contract-of manager)))
		(contract-call? manager start-migration burn-block-height (ft-get-supply usdh))
	)
)

(define-public (migrate-balance (who principal))
	(let ((balance (ft-get-balance usdh who)))
		(asserts! (is-eq (var-get migration-manager) (some contract-caller)) ERR_NOT_MIGRATION_MANAGER)
		(asserts! (> balance u0) (ok u0))
		(try! (ft-burn? usdh balance who))
		(ok balance)
	)
)
```
