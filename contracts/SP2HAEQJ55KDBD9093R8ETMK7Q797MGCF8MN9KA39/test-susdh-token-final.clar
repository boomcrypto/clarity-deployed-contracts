(impl-trait .sip-010-trait.sip-010-trait)
(impl-trait .token-migration-trait.token-migration-trait)

;; Defines the sUSDh token according to the SIP010 Standard
(define-fungible-token susdh)

(define-constant ERR_NOT_AUTHORIZED (err u1551))
(define-constant ERR_ONLY_PROTOCOL (err u1552))
(define-constant ERR_NOT_MIGRATING (err u1553))
(define-constant ERR_MIGRATION_NOT_COMPLETE (err u1554))
(define-constant ERR_NOT_INTERIM_TOKEN (err u1555))
(define-constant ERR_NOT_WAITING_FOR_MIGRATION (err u1556))
(define-constant ERR_ALREADY_MIGRATED (err u1557))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-constant interim-token-principal .test-susdh-token)
(define-constant migration-state-waiting 0x00)
(define-constant migration-state-migrating 0x01)
(define-constant migration-state-complete 0x02)

(define-data-var migration-state (buff 1) migration-state-waiting)
(define-data-var migration-snapshot-height uint u0)
(define-data-var migration-snapshot-supply uint u0)
(define-data-var migrated-amount uint u0)
(define-map migrated-amounts principal uint)

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var token-name (string-ascii 32) "Test sUSDh Final")

(define-data-var blacklist-enabled bool false)
(define-data-var only-protocol bool false)
(define-data-var counter uint u0)

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
    (asserts! (is-eq migration-state-complete (var-get migration-state)) ERR_MIGRATION_NOT_COMPLETE)
    (asserts! (or (is-eq sender contract-caller) (is-eq sender tx-sender)) ERR_NOT_AUTHORIZED)

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
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-mint? susdh amount recipient)
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-burn? susdh amount sender)
  )
)

;;-------------------------------------
;; Migration
;;-------------------------------------

(define-public (start-migration (snapshot-height uint) (total-supply uint))
	(begin
		(asserts! (is-eq interim-token-principal contract-caller) ERR_NOT_INTERIM_TOKEN)
		(asserts! (is-eq migration-state-waiting (var-get migration-state)) ERR_NOT_WAITING_FOR_MIGRATION)
		(var-set migration-snapshot-height snapshot-height)
		(var-set migration-state migration-state-migrating)
		(ok (var-set migration-snapshot-supply total-supply))
	)
)

(define-read-only (get-migration-snapshot-supply)
	(var-get migration-snapshot-supply)
)

(define-read-only (get-total-migrated-amount)
	(var-get migrated-amount)
)

(define-read-only (get-migrated-amount (who principal))
	(map-get? migrated-amounts who)
)

;; We can do at-block to be safe, but it should not be necessary if transfer/mint/burn are frozen
;; in the interim contract.
(define-private (migrate-tokens-iter (who principal))
	(let ((snapshot-balance (try! (contract-call? .test-susdh-token migrate-balance who))))
		(asserts! (is-none (map-get? migrated-amounts who)) ERR_ALREADY_MIGRATED)
		(map-set migrated-amounts who snapshot-balance)
		(try! (ft-mint? susdh snapshot-balance who))
		(ok snapshot-balance)
	)
)

(define-private (sum-ok (current (response uint uint)) (previous uint))
	(match current
		ok-amount (+ ok-amount previous)
		err previous
	)
)

;; Anyone can call this. People can call it for themselves or benevolent principals can do it for others.
(define-public (migrate-tokens (principals (list 2000 principal)))
	(let (
		(migration-result (map migrate-tokens-iter principals))
		(migration-total (fold sum-ok migration-result u0))
		(total-migrated-amount (+ migration-total (var-get migrated-amount)))
	)
		(asserts! (is-eq migration-state-migrating (var-get migration-state)) ERR_NOT_MIGRATING)
		(if (>= total-migrated-amount (var-get migration-snapshot-supply))
			(begin
				(var-set migration-state migration-state-complete)
				(print { event: "migration", complete: true, total: total-migrated-amount })
			)
			(print { event: "migration", complete: false, total: total-migrated-amount })
		)
		(var-set migrated-amount total-migrated-amount)
		(ok migration-result)
	)
)