;; Title: BME00 Governance Token
;; Synopsis:
;; This extension defines the governance token of BigMarket DAO.
;; Description:
;; The governance token is a simple SIP010-compliant fungible token
;; with some added functions to make it easier to manage by
;; BigMarket DAO proposals and extensions.
;; The operations vesting schedule and recipients can be updated (see current-key and 
;; set-core-team-vesting) up till the first claim. If more recipients are added they 
;; allocation is proportionally diluted.

(impl-trait 'SP22NW0RYCW4GFZRPE8VGJRCKGQMRMMX4903A2TRG.governance-token-trait.governance-token-trait)
(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)

(define-fungible-token bmg-token u100000000000000) ;; 100M
(define-fungible-token bmg-token-locked)

(define-constant core-team-max-vesting u1500000000000) ;; 15% of total supply (10,000,000 BIG)

(define-constant err-unauthorised (err u3000))
(define-constant err-not-token-owner (err u3001))
(define-constant err-not-core-team (err u3002))
(define-constant err-no-vesting-schedule (err u3003))
(define-constant err-nothing-to-claim (err u3004))
(define-constant err-core-vesting-limit (err u3005))
(define-constant err-cliff-not-reached (err u3006))
(define-constant err-recipients-are-locked (err u3007))
(define-constant err-transfers-blocked (err u3008))

(define-data-var token-name (string-ascii 32) "BigMarket Governance Token")
(define-data-var token-symbol (string-ascii 10) "BIG")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-decimals uint u6)
(define-data-var core-team-size uint u0)

(define-data-var token-price uint u100000)
(define-data-var transfers-active bool false)

(define-map core-team-vesting-tracker principal uint) ;; Tracks vested amount per recipient

;; ---- Vesting Storage ----
(define-data-var claim-made bool false)
(define-data-var current-key uint u0)
(define-map core-team-vesting {current-key: uint, recipient: principal}
  {total-amount: uint, start-block: uint, duration: uint, claimed: uint}
)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; ---- Vesting Methods ----

;; --- Vesting logic and sale
(define-public (set-transfers-active (new-transfers-active bool))
  (begin
    (try! (is-dao-or-extension))
    (var-set transfers-active new-transfers-active)
    (ok true)
  )
)
(define-read-only (get-transfers-active) (var-get transfers-active))

(define-public (set-token-price (new-token-price uint))
  (begin
    (try! (is-dao-or-extension))
    (var-set token-price new-token-price)
    (ok true)
  )
)

(define-public (set-core-team-vesting (core-team (list 200 {recipient: principal, start-block: uint, duration: uint})))
  (begin
	(try! (is-dao-or-extension))
	(asserts! (not (var-get claim-made)) err-recipients-are-locked)
	(var-set current-key (+ u1 (var-get current-key)))
	(var-set core-team-size (len core-team))
	(as-contract (fold set-core-team-vesting-iter core-team (ok true)))
  )
)
(define-private (set-core-team-vesting-iter (item {recipient: principal, start-block: uint, duration: uint}) (previous-result (response bool uint)))
	(begin
		(try! previous-result)
		(let (
				(amount (/ core-team-max-vesting (var-get core-team-size)))
			)
			(map-set core-team-vesting {current-key: (var-get current-key), recipient: (get recipient item)}
				{total-amount: amount, start-block: (get start-block item), duration: (get duration item), claimed: u0})
			(map-set core-team-vesting-tracker (get recipient item) amount)
			(print {event: "set-core-team-vesting", amount: amount, start-block: (get start-block item), duration: (get duration item), current-key: (var-get current-key)})
			(ok true)
		)
	)
)

(define-public (core-claim)
  (let
    (
      	(vesting (unwrap! (map-get? core-team-vesting {current-key: (var-get current-key), recipient: tx-sender}) err-no-vesting-schedule))
      	(current-block burn-block-height)
		(start-block (get start-block vesting))
		(duration (get duration vesting))
		(total-amount (get total-amount vesting))
		(claimed (get claimed vesting))
		(elapsed (if (> current-block start-block) (- current-block start-block) u0))
		(vested (if (> elapsed duration) total-amount (/ (* total-amount elapsed) duration)))
		(claimable (- vested claimed))
		(midpoint (+ start-block (/ duration u2)))
    )
    
	(asserts! (> burn-block-height midpoint) err-cliff-not-reached) 
	(asserts! (> claimable u0) err-nothing-to-claim) 
	(try! (as-contract (ft-mint? bmg-token claimable tx-sender)))

    (map-set core-team-vesting {current-key: (var-get current-key), recipient: tx-sender}
        (merge vesting {claimed: (+ claimed claimable)}))
	(var-set claim-made true)
    (print {event: "core-claim", claimed: claimed, recipient: tx-sender, claimable: claimable, elapsed: elapsed, vested: vested})
    (ok claimable)
  )
)

(define-read-only (get-vesting-schedule (who principal))
  (map-get? core-team-vesting {current-key: (var-get current-key), recipient: who})
)

;; --- Internal DAO functions

;; governance-token-trait

(define-public (bmg-transfer (amount uint) (sender principal) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-transfer? bmg-token amount sender recipient)
	)
)

(define-public (bmg-lock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? bmg-token amount owner))
		(ft-mint? bmg-token-locked amount owner)
	)
)

(define-public (bmg-unlock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (ft-burn? bmg-token-locked amount owner))
		(ft-mint? bmg-token amount owner)
	)
)

(define-public (bmg-mint (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? bmg-token amount recipient)
	)
)

(define-public (bmg-burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? bmg-token amount owner)
		
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

(define-private (bmg-mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? bmg-token (get amount item) (get recipient item))
)

(define-public (bmg-mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map bmg-mint-many-iter recipients))
	)
)

;; --- Public functions

;; sip-010-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
    	(asserts! (or (var-get transfers-active) (unwrap! (is-dao-or-extension) err-unauthorised)) err-transfers-blocked)
		(ft-transfer? bmg-token amount sender recipient)
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
	(ok (+ (ft-get-balance bmg-token who) (ft-get-balance bmg-token-locked who)))
)

(define-read-only (get-total-supply)
	(ok (+ (ft-get-supply bmg-token) (ft-get-supply bmg-token-locked)))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; governance-token-trait

(define-read-only (bmg-get-balance (who principal))
	(get-balance who)
)

(define-read-only (bmg-has-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

(define-read-only (bmg-get-locked (owner principal))
	(ok (ft-get-balance bmg-token-locked owner))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
