(define-constant err-unauthorised (err u1000))
(define-constant err-pair-not-found (err u1001))
(define-constant err-request-not-found (err u1002))

(define-data-var chain-nonce uint u1000)
(define-map approved-chains uint (string-utf8 256))

(define-map tick-to-pair (string-utf8 256) { token: principal, chain-id: uint })

(define-map approved-pairs 
	{ token: principal, chain-id: uint } 
	{ 
		approved: bool, 
		tick: (string-utf8 256),
		peg-in-paused: bool, 
		peg-out-paused: bool, 
		peg-in-fee: uint, 
		peg-out-fee: uint, 
		peg-out-gas-fee: uint,
		no-burn: bool
	})

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (get-request-nonce)
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 get-request-nonce))

(define-read-only (get-request-revoke-grace-period)
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 get-request-revoke-grace-period))

(define-read-only (get-request-claim-grace-period)
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 get-request-claim-grace-period))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 is-peg-in-address-approved address))

(define-read-only (get-request-or-fail (request-id uint))
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 get-request-or-fail request-id))

(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 get-peg-in-sent-or-default bitcoin-tx output offset))

(define-read-only (get-pair-details-or-fail (pair { token: principal, chain-id: uint }))
	(ok (unwrap! (map-get? approved-pairs pair) err-pair-not-found)))

(define-read-only (is-approved-pair (pair { token: principal, chain-id: uint }))
	(match (get-pair-details-or-fail pair) ok-value (get approved ok-value) err-value false))

(define-read-only (get-tick-to-pair-or-fail (tick (string-utf8 256)))
	(ok (unwrap! (map-get? tick-to-pair tick) err-pair-not-found)))

;; governance functions

(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 set-request-revoke-grace-period grace-period)))

(define-public (set-request-claim-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))	
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 set-request-claim-grace-period grace-period)))

(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 approve-peg-in-address address approved)))

(define-public (set-approved-chain (the-chain-id uint) (chain-name (string-utf8 256)))
  (let (
      (the-chain-id-next (+ (var-get chain-nonce) u1))
      (print-msg { notification: "set-approved-chain", chain-name: chain-name }))
    (try! (is-dao-or-extension))
    (match (map-get? approved-chains the-chain-id)
      some-value (begin (map-set approved-chains the-chain-id chain-name) (print (merge print-msg { chain-id: the-chain-id })) (ok the-chain-id))
      (begin 
        (var-set chain-nonce the-chain-id-next)
        (map-set approved-chains the-chain-id-next chain-name)
        (print (merge print-msg { chain-id: the-chain-id-next }))
        (ok the-chain-id-next)))))

(define-public (pause-peg-in (pair { token: principal, chain-id: uint }) (paused bool))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-paused: paused })))))

(define-public (pause-peg-out (pair { token: principal, chain-id: uint }) (paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-paused: paused })))))

(define-public (set-peg-in-fee (pair { token: principal, chain-id: uint }) (new-peg-in-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-fee: new-peg-in-fee })))))

(define-public (set-peg-out-fee (pair { token: principal, chain-id: uint }) (new-peg-out-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-fee: new-peg-out-fee })))))

(define-public (set-peg-out-gas-fee (pair { token: principal, chain-id: uint }) (new-peg-out-gas-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-gas-fee: new-peg-out-gas-fee })))))

(define-public (set-token-no-burn (pair { token: principal, chain-id: uint }) (no-burn bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { no-burn: no-burn })))))

(define-public (approve-pair (pair { token: principal, chain-id: uint }) (tick (string-utf8 256)) (approved bool) )
	(begin
		(try! (is-dao-or-extension))
		(match (map-get? approved-pairs pair)
			token-details 
			(map-set approved-pairs pair (merge token-details { approved: approved, tick: tick }))
			(map-set approved-pairs pair { approved: approved, tick: tick, peg-in-paused: true, peg-out-paused: true, peg-in-fee: u0, peg-out-fee: u0, peg-out-gas-fee: u0, no-burn: false }))
		(ok (map-set tick-to-pair tick pair))))

;; priviledged functions

(define-public (set-peg-in-sent (peg-in-tx { tx: (buff 32768), output: uint, offset: uint }) (sent bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 set-peg-in-sent peg-in-tx sent)))

(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), tick: (string-utf8 256), token: principal, amount-net: uint, fee: uint, gas-fee: uint, claimed: uint, claimed-by: principal, fulfilled-by: (buff 128), revoked: bool, finalized: bool, requested-at: uint, requested-at-burn-height: uint}))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 set-request request-id details)))
		
;; internal functions


