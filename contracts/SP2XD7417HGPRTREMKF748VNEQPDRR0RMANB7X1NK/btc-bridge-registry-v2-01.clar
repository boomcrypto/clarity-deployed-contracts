(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-request-not-found (err u1002))
(define-constant err-invalid-input (err u1003))
(define-map approved-peg-in-address (buff 128) bool)
(define-data-var request-claim-grace-period uint u144)
(define-data-var request-revoke-grace-period uint u432)
(define-data-var request-nonce uint u0)
(define-map requests uint {
	requested-by: principal,
	peg-out-address: (buff 128),
	amount-net: uint,
	fee: uint,
	gas-fee: uint,
	claimed: uint,
	claimed-by: principal,
	fulfilled-by: (buff 128),
	revoked: bool,
	finalized: bool,
	requested-at: uint,
	requested-at-burn-height: uint})
(define-map peg-in-sent { tx: (buff 32768), output: uint } bool)
(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set request-revoke-grace-period grace-period))))
(define-public (set-request-claim-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set request-claim-grace-period grace-period))))
(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-peg-in-address address approved))))
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised)))
(define-read-only (get-request-revoke-grace-period)
	(var-get request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(var-get request-claim-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(default-to false (map-get? approved-peg-in-address address)))
(define-read-only (get-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? requests request-id) err-request-not-found)))
(define-read-only (get-peg-in-sent-or-default (tx (buff 32768)) (output uint))
	(or
		(contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-bridge-registry-v1-04 get-peg-in-sent-or-default tx output)
		(default-to false (map-get? peg-in-sent { tx: tx, output: output }))))
(define-public (set-peg-in-sent (tx (buff 32768)) (output uint) (sent bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set peg-in-sent { tx: tx, output: output } sent))))
(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), amount-net: uint, fee: uint, gas-fee: uint, claimed: uint, claimed-by: principal, fulfilled-by: (buff 128), revoked: bool, finalized: bool, requested-at: uint, requested-at-burn-height: uint}))
	(let (
			(id (if (is-some (map-get? requests request-id)) request-id (begin (var-set request-nonce (+ (var-get request-nonce) u1)) (var-get request-nonce)))))
		(try! (is-dao-or-extension))
		(map-set requests id details)
		(ok id)))