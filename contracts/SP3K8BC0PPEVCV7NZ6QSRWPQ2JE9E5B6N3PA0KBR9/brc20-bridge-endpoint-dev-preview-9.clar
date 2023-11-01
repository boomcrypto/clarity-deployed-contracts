(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-token-mismatch (err u1004))
(define-constant err-invalid-tx (err u1005))
(define-constant err-already-sent (err u1006))
(define-constant err-address-mismatch (err u1007))
(define-constant err-request-already-revoked (err u1008))
(define-constant err-request-already-finalized (err u1009))
(define-constant err-revoke-grace-period (err u1010))
(define-constant err-request-already-claimed (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-constant gas-fee-token .token-susdt)
(define-data-var contract-owner principal tx-sender)
(define-data-var fee-address principal tx-sender)
(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-contract-owner))))
(define-public (set-fee-address (new-fee-address principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set fee-address new-fee-address))))
(define-read-only (get-request-revoke-grace-period)
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-request-claim-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? .brc20-bridge-registry-dev-preview-2 is-peg-in-address-approved address))
(define-read-only (get-token-to-tick-or-fail (token principal))
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-token-to-tick-or-fail token))
(define-read-only (get-token-details-or-fail (tick (string-utf8 4)))
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-token-details-or-fail tick))
(define-read-only (get-token-details-or-fail-by-address (token principal))
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-token-details-or-fail-by-address token))
(define-read-only (is-approved-token (tick (string-utf8 4)))
	(contract-call? .brc20-bridge-registry-dev-preview-2 is-approved-token tick))
(define-read-only (get-request-or-fail (request-id uint))
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-request-or-fail request-id))
(define-read-only (create-order-or-fail (order { user: principal, dest: uint }))
	(ok (unwrap! (to-consensus-buff? order) err-invalid-input)))
(define-read-only (decode-order-or-fail (order-script (buff 128)))
	(ok (unwrap! (from-consensus-buff? { user: principal, dest: uint } (unwrap-panic (slice? order-script u2 (len order-script)))) err-invalid-input)))
(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 4096)) (output uint) (offset uint))
	(contract-call? .brc20-bridge-registry-dev-preview-2 get-peg-in-sent-or-default bitcoin-tx output offset))
(define-read-only (get-fee-address)
	(var-get fee-address))
(define-read-only (extract-tx-ins-outs (tx (buff 4096)))
	(if (try! (contract-call? .clarity-bitcoin-dev-preview-3 is-segwit-tx tx))
		(let 
			(
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-dev-preview-3 parse-wtx tx) err-invalid-tx))
			)
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) })
		)
		(let
			(
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-dev-preview-3 parse-tx tx) err-invalid-tx))
			)
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) })
		)
	)
)
(define-read-only (validate-tx (tx (buff 4096)) (output-idx uint) (offset-idx uint) (order-idx uint) (token principal))
	(let (
			(tx-idxed (try! (contract-call? .indexer-dev-preview-7 get-bitcoin-tx-indexed-or-fail tx output-idx offset-idx)))
			(parsed-tx (try! (extract-tx-ins-outs tx)))
			(order-script (get scriptPubKey (unwrap-panic (element-at? (get outs parsed-tx) order-idx))))
			(order-details (try! (decode-order-or-fail order-script)))
			(token-details (try! (get-token-details-or-fail (get tick tx-idxed))))
			(amt-in-fixed (decimals-to-fixed (get amt tx-idxed) (contract-call? .indexer-dev-preview-7 get-tick-decimals-or-default (get tick tx-idxed))))
			(fee (mul-down amt-in-fixed (get peg-in-fee token-details)))
			(amt-net (- amt-in-fixed fee)))
		(asserts! (is-eq token (get token token-details)) err-token-mismatch)
		(asserts! (not (get-peg-in-sent-or-default tx output-idx offset-idx)) err-already-sent)
		(asserts! (is-peg-in-address-approved (get to tx-idxed)) err-peg-in-address-not-found)
		(ok { order-details: order-details, fee: fee, amt-net: amt-net, tx-idxed: tx-idxed, token-details: token-details })
	)
)
(define-public (finalize-peg-in (tx (buff 4096)) (output-idx uint) (offset-idx uint) (order-idx uint) (token-trait <sip010-trait>))
	(let (
			(token (contract-of token-trait))
			(validation-data (try! (validate-tx tx output-idx offset-idx order-idx token)))
			(tx-idxed (get tx-idxed validation-data))
			(order-details (get order-details validation-data))
			(order-address (get user order-details))
			(dest (get dest order-details))
			(token-details (get token-details validation-data))
			(fee (get fee validation-data))
			(amt-net (get amt-net validation-data)))
		(asserts! (not (get peg-in-paused token-details)) err-paused)
		(as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-peg-in-sent { tx: tx, output: output-idx, offset: offset-idx } true)))
		(and (> fee u0) (as-contract (try! (contract-call? token-trait mint-fixed fee (var-get fee-address)))))
		;; map cannot hold traits, so the below have to be hard-coded.
		;; mint to order-address if either dest == 0 or order-address is not registered with b20, or token is not registered with b20
		(if (or (is-eq dest u0) (is-err (contract-call? .stxdx-registry get-user-id-or-fail order-address)) (is-none (contract-call? .stxdx-registry get-asset-id token)))
			(begin 
				(and (> amt-net u0) (as-contract (try! (contract-call? token-trait mint-fixed amt-net order-address))))
				(print (merge tx-idxed { type: "peg-in", order-address: order-address, fee: fee, amt-net: amt-net, dest: u0 }))
			)
			(begin 
				(and (> amt-net u0) (as-contract (try! (contract-call? token-trait mint-fixed amt-net tx-sender))))
				(and (> amt-net u0) (as-contract (try! (contract-call? .stxdx-wallet-zero transfer-in 
					amt-net 
					(try! (contract-call? .stxdx-registry get-user-id-or-fail order-address))  ;; user-id
					(unwrap-panic (contract-call? .stxdx-registry get-asset-id token)) ;; asset-id
					token-trait))))			
				(print (merge tx-idxed { type: "peg-in", order-address: order-address, fee: fee, amt-net: amt-net, dest: u1 }))
			)
		)
		
		(ok true)))
(define-public (request-peg-out (tick (string-utf8 4)) (amount uint) (peg-out-address (buff 128)) (token-trait <sip010-trait>))
	(let (
			(token (contract-of token-trait))
			(token-details (try! (get-token-details-or-fail tick)))
			(fee (mul-down amount (get peg-out-fee token-details)))
			(amount-net (- amount fee))
			(gas-fee (get peg-out-gas-fee token-details))
			(request-details { requested-by: tx-sender, peg-out-address: peg-out-address, tick: tick, amount-net: amount-net, fee: fee, gas-fee: gas-fee, claimed: u0, claimed-by: tx-sender, fulfilled-by: 0x, revoked: false, finalized: false, requested-at: block-height })
			(request-id (as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-request u0 request-details)))))
		(asserts! (not (get peg-out-paused token-details)) err-paused)
		(asserts! (is-eq token (get token token-details)) err-token-mismatch)
		(asserts! (> amount u0) err-invalid-amount)
		(try! (contract-call? token-trait transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(and (> gas-fee u0) (try! (contract-call? gas-fee-token transfer-fixed gas-fee tx-sender (as-contract tx-sender) none)))
		(print (merge request-details { type: "request-peg-out", request-id: request-id }))
		(ok true)))
(define-public (claim-peg-out (request-id uint) (fulfilled-by (buff 128)))
	(let (
			(claimer tx-sender)
			(request-details (try! (get-request-or-fail request-id)))
			(token-details (try! (get-token-details-or-fail (get tick request-details)))))
		(asserts! (not (get peg-out-paused token-details)) err-paused)	
		(asserts! (< (get claimed request-details) block-height) err-request-already-claimed)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)		
		
		(as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-request request-id (merge request-details { claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))))
		(print (merge request-details { type: "claim-peg-out", request-id: request-id, claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))
		(ok true)
	)
)
(define-public (finalize-peg-out (request-id uint) (tx (buff 4096)) (output-idx uint) (offset-idx uint) (token-trait <sip010-trait>))
	(let (
			(token (contract-of token-trait))
			(request-details (try! (get-request-or-fail request-id)))
			(token-details (try! (get-token-details-or-fail (get tick request-details))))			
			(tx-idxed (try! (contract-call? .indexer-dev-preview-7 get-bitcoin-tx-indexed-or-fail tx output-idx offset-idx)))	
			(amount-in-fixed (decimals-to-fixed (get amt tx-idxed) (contract-call? .indexer-dev-preview-7 get-tick-decimals-or-default (get tick tx-idxed))))
			(fulfilled-by (get from tx-idxed))
			(is-fulfilled-by-peg-in (is-peg-in-address-approved fulfilled-by))			
			)
		(asserts! (not (get peg-out-paused token-details)) err-paused)
		(asserts! (is-eq token (get token token-details)) err-token-mismatch)
		(asserts! (is-eq (get tick request-details) (get tick tx-idxed)) err-token-mismatch)
		(asserts! (is-eq (get amount-net request-details) amount-in-fixed) err-invalid-amount)
		(asserts! (is-eq (get peg-out-address request-details) (get to tx-idxed)) err-address-mismatch)
		(asserts! (is-eq (get fulfilled-by request-details) fulfilled-by) err-address-mismatch)
		(asserts! (not (get-peg-in-sent-or-default tx output-idx offset-idx)) err-already-sent)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-peg-in-sent { tx: tx, output: output-idx, offset: offset-idx } true)))
		(as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-request request-id (merge request-details { finalized: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? token-trait transfer-fixed (get fee request-details) tx-sender (var-get fee-address) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? gas-fee-token transfer-fixed (get gas-fee request-details) tx-sender (if is-fulfilled-by-peg-in (var-get fee-address) (get claimed-by request-details)) none))))
		(if is-fulfilled-by-peg-in
			(as-contract (try! (contract-call? token-trait burn-fixed (get amount-net request-details) tx-sender)))
			(as-contract (try! (contract-call? token-trait transfer-fixed (get amount-net request-details) tx-sender (get claimed-by request-details) none)))
		)
		(print { type: "finalize-peg-out", request-id: request-id, tx: tx })
		(ok true)))
(define-public (revoke-peg-out (request-id uint) (token-trait <sip010-trait>))
	(let (
			(token (contract-of token-trait))
			(request-details (try! (get-request-or-fail request-id)))
			(token-details (try! (get-token-details-or-fail (get tick request-details)))))
		(asserts! (not (get peg-out-paused token-details)) err-paused)
		(asserts! (is-eq token (get token token-details)) err-token-mismatch)
		(asserts! (> block-height (+ (get requested-at request-details) (get-request-revoke-grace-period))) err-revoke-grace-period)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .brc20-bridge-registry-dev-preview-2 set-request request-id (merge request-details { revoked: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? token-trait transfer-fixed (get fee request-details) tx-sender (get requested-by request-details) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? gas-fee-token transfer-fixed (get gas-fee request-details) tx-sender (get requested-by request-details) none))))
		(as-contract (try! (contract-call? token-trait transfer-fixed (get amount-net request-details) tx-sender (get requested-by request-details) none)))
		(print { type: "revoke-peg-out", request-id: request-id })
		(ok true)))
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised)))
(define-private (min (a uint) (b uint))
	(if (< a b) a b))
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0)
		u0
		(/ (* a ONE_8) b)))
(define-private (decimals-to-fixed (amount uint) (decimals uint))
	(/ (* amount ONE_8) (pow u10 decimals)))