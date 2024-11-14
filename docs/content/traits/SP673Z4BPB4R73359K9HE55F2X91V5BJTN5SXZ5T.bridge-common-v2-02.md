---
title: "Trait bridge-common-v2-02"
draft: true
---
```
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

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
(define-constant err-bitcoin-tx-not-mined (err u1017))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

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
		(order-output-witnesses (unwrap-panic (element-at? (get witnesses parsed-tx) order-idx)))
      	(raw-order-script (unwrap-panic (element-at? order-output-witnesses u1)))
		(order-script-pos (unwrap-panic (get-order-script-pos raw-order-script)))
		(order-script (unwrap-panic (as-max-len? (unwrap-panic (slice? raw-order-script (get start order-script-pos) (get end order-script-pos))) u256))))
	(ok { commit-txid: commit-txid, order-script: order-script })))

(define-read-only (create-order-or-fail (order principal))
  (ok (unwrap! (to-consensus-buff? order) err-invalid-input)))

(define-read-only (decode-order-or-fail (order-script (buff 512)) (offset uint))
  (ok (unwrap! (from-consensus-buff? principal (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))

(define-read-only (decode-order-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-or-fail (get order-script decoded-data) u0))))
      (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

(define-read-only (create-order-cross-or-fail (order { from: (buff 128), to: (buff 128), chain-id: (optional uint), token: principal, token-out: principal }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), c: (match (get chain-id order) some-value (int-to-ascii some-value) "none"), t: (get token order), o: (get token-out order) }) err-invalid-input)))

(define-read-only (decode-order-cross-or-fail (order-script (buff 512)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), c: (string-ascii 40), t: principal, o: principal } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), chain-id: (if (is-eq (get c raw-order) "none") none (some (unwrap-string-to-uint (get c raw-order)))), token: (get t raw-order), token-out: (get o raw-order) })))

(define-read-only (decode-order-cross-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-cross-or-fail (get order-script decoded-data) u0))))
      (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

;; @dev cross-swap order size > 80 bytes, so uses drop
(define-read-only (create-order-cross-swap-or-fail (order { from: (buff 128), to: (buff 128), routing: (list 4 uint), token-out: principal, min-amount-out: (optional uint), chain-id: (optional uint) }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), p: (map int-to-ascii (get routing order)), o: (get token-out order), m: (match (get min-amount-out order) some-value (int-to-ascii some-value) "none"), c: (match (get chain-id order) some-value (int-to-ascii some-value) "none") }) err-invalid-input)))

(define-read-only (decode-order-cross-swap-or-fail (order-script (buff 512)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), p: (list 4 (string-ascii 40)), o: principal, m: (string-ascii 40), c: (string-ascii 40) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), routing: (map unwrap-string-to-uint (get p raw-order)), token-out: (get o raw-order), min-amount-out: (if (is-eq (get m raw-order) "none") none (some (unwrap-string-to-uint (get m raw-order)))), chain-id: (if (is-eq (get c raw-order) "none") none (some (unwrap-string-to-uint (get c raw-order)))) })))

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

;; verify-mined
;;
;; it takes Bitcoin tx and confirms if the tx is mined on Bitcoin L1
(define-read-only (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(if (is-eq chain-id u1)
		(let (
				(response (if (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 is-segwit-tx tx)) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 was-segwit-tx-mined? block tx proof) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 was-tx-mined? block tx proof))))
			(if (or (is-err response) (not (unwrap-panic response))) err-bitcoin-tx-not-mined (ok true)))
		(ok true))) ;; if not mainnet, assume verified

;; priviliged calls 

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

(define-private (parse-push-op (byte-offset uint) (acc { raw-order-script: (buff 32768), len: uint }))
	{ raw-order-script: (get raw-order-script acc), len: (+ (buff-to-uint-be (unwrap-panic (element-at? (get raw-order-script acc) byte-offset))) (get len acc)) })

(define-private (get-order-script-pos (raw-order-script (buff 32768)))
	(let (
			(op-push (buff-to-uint-be (unwrap-panic (element-at? raw-order-script u0))))
			(len-bytes (unwrap-panic (if (< op-push u76) ;; OP_PUSH
										(ok (list u0))
										(if (is-eq op-push u76) ;; OP_PUSHDATA1
											(ok (list u1))
											(if (is-eq op-push u77) ;; OP_PUSHDATA2
												(ok (list u1 u2))
												(if (is-eq op-push u78) ;; OP_PUSHDATA4
													(ok (list u1 u2 u3 u4))
													err-invalid-input ;; not a push op
													))))))
			(parsed (fold parse-push-op len-bytes { raw-order-script: raw-order-script, len: u0 }))
			(start (if (< op-push u76) u1 (+ u1 (len len-bytes)))))
		(ok { start: start, end: (+ start (get len parsed)), len: (get len parsed) })))

```
