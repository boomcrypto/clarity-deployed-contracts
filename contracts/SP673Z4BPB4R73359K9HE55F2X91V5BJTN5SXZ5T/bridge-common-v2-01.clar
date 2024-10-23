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
(define-constant err-tx-mined-before-request (err u1013))
(define-constant err-commit-tx-mismatch (err u1014))
(define-constant err-invalid-burn-height (err u1003))
(define-constant err-tx-mined-before-start (err u1015))
(define-constant err-invalid-routing (err u1016))

(define-read-only (destruct-principal (address principal))
	(principal-destruct? address))

(define-read-only (construct-principal (hash-bytes (buff 20)))
	(principal-construct? (if (is-eq chain-id u1) 0x16 0x1a) hash-bytes))
	
(define-read-only (get-txid (tx (buff 32768)))
	(if (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 is-segwit-tx tx))
		(ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid tx))
		(ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-txid tx))))

(define-read-only (decode-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (parsed-tx (unwrap! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 parse-wtx tx) err-invalid-tx))
      (commit-txid (get hash (get outpoint (unwrap-panic (element-at? (get ins parsed-tx) u0)))))
      (raw-order-script (unwrap-panic (element-at? (unwrap-panic (element-at? (get witnesses parsed-tx) u0)) order-idx)))
			(order-script (unwrap-panic (as-max-len? (unwrap-panic (slice? raw-order-script u1 (+ (buff-to-uint-be (unwrap-panic (element-at? raw-order-script u0))) u1))) u256))))
		(ok { commit-txid: commit-txid, order-script: order-script })))

(define-read-only (create-order-or-fail (order principal))
  (ok (unwrap! (to-consensus-buff? order) err-invalid-input)))

(define-read-only (decode-order-or-fail (order-script (buff 256)) (offset uint))
  (ok (unwrap! (from-consensus-buff? principal (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))

(define-read-only (decode-order-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-or-fail (get order-script decoded-data) u0))))
      (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

(define-read-only (create-order-cross-or-fail (order { from: (buff 128), to: (buff 128), chain-id: uint, token: principal }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), c: (int-to-ascii (get chain-id order)), t: (get token order) }) err-invalid-input)))

(define-read-only (decode-order-cross-or-fail (order-script (buff 256)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), c: (string-ascii 40), t: principal } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), chain-id: (unwrap! (string-to-uint? (get c raw-order)) err-invalid-input), token: (get t raw-order) })))

(define-read-only (decode-order-cross-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-cross-or-fail (get order-script decoded-data) u0))))
      (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

;; @dev cross-swap order size > 80 bytes, so uses drop
(define-read-only (create-order-cross-swap-or-fail (order { from: (buff 128), to: (buff 128), routing: (list 4 uint), min-amount-out: (optional uint), chain-id: (optional uint) }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), p: (map int-to-ascii (get routing order)), m: (match (get min-amount-out order) some-value (int-to-ascii some-value) "none"), c: (match (get chain-id order) some-value (int-to-ascii some-value) "none") }) err-invalid-input)))

(define-read-only (decode-order-cross-swap-or-fail (order-script (buff 256)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), p: (list 4 (string-ascii 40)), m: (string-ascii 40), c: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), routing: (map unwrap-string-to-uint (get p raw-order)), min-amount-out: (if (is-eq (get m raw-order) "none") none (some (unwrap-string-to-uint (get m raw-order)))), chain-id: (if (is-eq (get c raw-order) "none") none (some (unwrap-string-to-uint (get c raw-order)))) })))

(define-read-only (decode-order-cross-swap-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-cross-swap-or-fail (get order-script decoded-data) u0))))
    (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

(define-read-only (break-routing-id (routing-ids (list 4 uint)))
	(fold break-routing-id-iter routing-ids (ok { routing-tokens: (list ), routing-factors: (list ) })))

(define-read-only (extract-tx-ins-outs (tx (buff 32768)))
  (if (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 is-segwit-tx tx))
    (let (
        (parsed-tx (unwrap! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 parse-wtx tx) err-invalid-tx)))
      (ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
    (let (
        (parsed-tx (unwrap! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 parse-tx tx) err-invalid-tx)))
      (ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))))

;; private calls

(define-private (break-routing-id-iter (routing-id uint) (prev-val (response { routing-tokens: (list 5 principal), routing-factors: (list 4 uint) } uint)))
	(match prev-val
		ok-value
		(let (
				(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details-by-id routing-id)))
				(prev-routing-tokens (unwrap-panic (as-max-len? (get routing-tokens ok-value) u4)))
				(prev-routing-factors (unwrap-panic (as-max-len? (get routing-factors ok-value) u3)))
				(len-routing-tokens (len prev-routing-tokens)))
				(if (is-eq len-routing-tokens u0)
					(if (is-eq (get token-x pool-details) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
						(ok { routing-tokens: (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc (get token-y pool-details)), routing-factors: (list (get factor pool-details)) })
						(if (is-eq (get token-y pool-details) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
							 (ok { routing-tokens: (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc (get token-x pool-details)), routing-factors: (list (get factor pool-details)) })
							 err-invalid-routing))
					(if (is-eq (get token-x pool-details) (unwrap-panic (element-at? prev-routing-tokens (- len-routing-tokens u1))))
						(ok { routing-tokens: (append prev-routing-tokens (get token-y pool-details)), routing-factors: (append prev-routing-factors (get factor pool-details)) })
						(if (is-eq (get token-y pool-details) (unwrap-panic (element-at? prev-routing-tokens (- len-routing-tokens u1))))
							(ok { routing-tokens: (append prev-routing-tokens (get token-x pool-details)), routing-factors: (append prev-routing-factors (get factor pool-details)) })
							err-invalid-routing))))
		err-value (err err-value)))

(define-private (unwrap-string-to-uint (input (string-ascii 40)))
	(unwrap-panic (string-to-uint? input)))
