(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-token-not-found (err u1001))
(define-constant err-request-not-found (err u1002))
(define-constant err-invalid-input (err u1003))
(define-data-var contract-owner principal tx-sender)
(define-map approved-operators principal bool)
(define-map approved-peg-in-address (buff 128) bool)
(define-map approved-tokens (string-utf8 4) { token: principal, approved: bool, peg-in-paused: bool, peg-out-paused: bool, peg-in-fee: uint, peg-out-fee: uint, peg-out-gas-fee: uint })
(define-map token-to-tick principal (string-utf8 4))
(define-map peg-in-sent { tx: (buff 4096), output: uint, offset: uint } bool)
(define-data-var request-revoke-grace-period uint u432)
(define-data-var request-nonce uint u0)
(define-map requests uint {
	requested-by: principal,
	peg-out-address: (buff 128),
	tick: (string-utf8 4),
	amount-net: uint,
	fee: uint,
	gas-fee: uint,
	revoked: bool,
	finalized: bool,
	requested-at: uint})
(define-public (approve-operator (operator principal) (approved bool))
	(begin
		(try! (is-contract-owner))
		(ok (map-set approved-operators operator approved))))
(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-contract-owner))
		(ok (var-set request-revoke-grace-period grace-period))))
(define-public (pause-peg-in (tick (string-utf8 4)) (paused bool))
	(let (
			(token-details (try! (get-token-details-or-fail tick))))
		(try! (is-contract-owner))
		(ok (map-set approved-tokens tick (merge token-details { peg-in-paused: paused })))))
(define-public (pause-peg-out (tick (string-utf8 4)) (paused bool))
	(let (
			(token-details (try! (get-token-details-or-fail tick))))
		(try! (is-contract-owner))
		(ok (map-set approved-tokens tick (merge token-details { peg-out-paused: paused })))))
(define-public (set-peg-in-fee (tick (string-utf8 4)) (new-peg-in-fee uint))
	(let (
			(token-details (try! (get-token-details-or-fail tick))))
		(try! (is-contract-owner))
		(ok (map-set approved-tokens tick (merge token-details { peg-in-fee: new-peg-in-fee })))))
(define-public (set-peg-out-fee (tick (string-utf8 4)) (new-peg-out-fee uint))
	(let (
			(token-details (try! (get-token-details-or-fail tick))))
		(try! (is-contract-owner))
		(ok (map-set approved-tokens tick (merge token-details { peg-out-fee: new-peg-out-fee })))))
(define-public (set-peg-out-gas-fee (tick (string-utf8 4)) (new-peg-out-gas-fee uint))
	(let (
			(token-details (try! (get-token-details-or-fail tick))))
		(try! (is-contract-owner))
		(ok (map-set approved-tokens tick (merge token-details { peg-out-gas-fee: new-peg-out-gas-fee })))))
(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-contract-owner))))
(define-public (approve-token (tick (string-utf8 4)) (token principal) (approved bool))
	(begin
		(try! (is-contract-owner))
		(map-set token-to-tick token tick)
		(ok
			(match (map-get? approved-tokens tick)
				token-details
				(map-set approved-tokens tick (merge token-details { token: token, approved: approved }))
				(map-set approved-tokens tick { token: token, approved: approved, peg-in-paused: true, peg-out-paused: true, peg-in-fee: u1000000, peg-out-fee: u1000000, peg-out-gas-fee: u3000000000 })))))
(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-contract-owner))
		(ok (map-set approved-peg-in-address address approved))))
(define-read-only (get-request-revoke-grace-period)
	(var-get request-revoke-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(default-to false (map-get? approved-peg-in-address address)))
(define-read-only (get-token-to-tick-or-fail (token principal))
	(ok (unwrap! (map-get? token-to-tick token) err-token-not-found)))
(define-read-only (get-token-details-or-fail (tick (string-utf8 4)))
	(ok (unwrap! (map-get? approved-tokens tick) err-token-not-found)))
(define-read-only (get-token-details-or-fail-by-address (token principal))
	(get-token-details-or-fail (try! (get-token-to-tick-or-fail token))))
(define-read-only (is-approved-token (tick (string-utf8 4)))
	(match (get-token-details-or-fail tick) ok-value (get approved ok-value) err-value false))
(define-read-only (get-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? requests request-id) err-request-not-found)))
(define-read-only (create-order-or-fail (order principal))
	(ok (unwrap! (to-consensus-buff? order) err-invalid-input)))
(define-read-only (get-approved-operator-or-default (operator principal))
	(default-to false (map-get? approved-operators operator))
)
(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 4096)) (output uint) (offset uint))
	(default-to false (map-get? peg-in-sent { tx: bitcoin-tx, output: output, offset: offset }))
)
(define-public (set-peg-in-sent (peg-in-tx { tx: (buff 4096), output: uint, offset: uint }) (sent bool))
	(begin 
		(try! (is-approved-operator))
		(ok (map-set peg-in-sent peg-in-tx sent))
	)
)
(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), tick: (string-utf8 4), amount-net: uint, fee: uint, gas-fee: uint, revoked: bool, finalized: bool, requested-at: uint}))
	(let 
		(
			(id (if (is-some (map-get? requests request-id)) request-id (begin (var-set request-nonce (+ (var-get request-nonce) u1)) (var-get request-nonce))))
		)
		(try! (is-approved-operator))
		(map-set requests id details)
		(ok id)
	)
)
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised)))
(define-private (is-approved-operator)
	(ok (asserts! (or (get-approved-operator-or-default tx-sender) (is-ok (is-contract-owner))) err-unauthorised))
)