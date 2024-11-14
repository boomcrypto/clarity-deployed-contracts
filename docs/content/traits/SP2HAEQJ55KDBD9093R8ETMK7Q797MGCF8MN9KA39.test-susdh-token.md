---
title: "Trait test-susdh-token"
draft: true
---
```
(impl-trait .sip-010-trait.sip-010-trait)
(impl-trait .interim-token-trait.interim-token-trait)
(use-trait token-migration-trait .token-migration-trait.token-migration-trait)

(define-fungible-token susdh)

(define-constant ERR_NOT_AUTHORIZED (err u1501))
(define-constant ERR_ONLY_PROTOCOL (err u1502))
(define-constant ERR_DEPRECATED_TOKEN (err u1503))
(define-constant ERR_NOT_MIGRATION_MANAGER (err u1504))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var token-name (string-ascii 32) "Test Staked USDh")

(define-data-var blacklist-enabled bool false)
(define-data-var only-protocol bool false)
(define-data-var counter uint u0)

(define-data-var migration-start-height uint u0)
(define-data-var migration-manager (optional principal) none)

;;-------------------------------------
;; SIP-010 
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply susdh))
)

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok "sUSDh")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance susdh account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-read-only (get-blacklist-enabled)
  (var-get blacklist-enabled)
)

(define-read-only (get-only-protocol)
  (var-get only-protocol)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-not-migrated))
    (asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) ERR_NOT_AUTHORIZED)

    (if (var-get only-protocol) 
      (asserts! (or (contract-call? .test-hq get-contract-active sender) (contract-call? .test-hq get-contract-active recipient)) ERR_ONLY_PROTOCOL)
      true
    )

    (if (var-get blacklist-enabled)
      (try! (contract-call? .test-blacklist-susdh check-is-not-full-blacklist-two sender recipient))
      true
    )

    (match (ft-transfer? susdh amount sender recipient)
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

(define-public (enable-blacklist)
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (< (var-get counter) u1) ERR_NOT_AUTHORIZED)
    (var-set counter u1)
    (ok (var-set blacklist-enabled true))
  )
)

(define-public (disable-blacklist)
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (< (var-get counter) u2) ERR_NOT_AUTHORIZED)
    (var-set counter u2)
    (ok (var-set blacklist-enabled false))
  )
)

(define-public (set-only-protocol (value bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set only-protocol value))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-protocol (amount uint) (recipient principal))
  (begin
    (try! (is-not-migrated))
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-mint? susdh amount recipient)
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (is-not-migrated))
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-burn? susdh amount sender)
  )
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
		(contract-call? manager start-migration burn-block-height (ft-get-supply susdh))
	)
)

(define-public (migrate-balance (who principal))
	(let ((balance (ft-get-balance susdh who)))
		(asserts! (is-eq (var-get migration-manager) (some contract-caller)) ERR_NOT_MIGRATION_MANAGER)
		(asserts! (> balance u0) (ok u0))
		(try! (ft-burn? susdh balance who))
		(ok balance)
	)
)
```
