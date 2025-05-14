---
title: "Trait btc-peg-in-v2-07d-agg"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.extension-trait.extension-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-invalid-tx (err u1004))
(define-constant err-already-sent (err u1005))
(define-constant err-bitcoin-tx-not-mined (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant err-token-mismatch (err u1015))
(define-constant err-slippage (err u1016))
(define-constant err-not-in-whitelist (err u1017))
(define-constant err-invalid-routing (err u1018))
(define-constant err-commit-tx-mismatch (err u1019))
(define-constant err-invalid-token (err u1020))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-data-var fee-to-address principal 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao)

(define-data-var peg-in-paused bool true)
(define-data-var peg-in-fee uint u0)
(define-data-var peg-in-min-fee uint u0)

;; governance functions

(define-public (set-fee-to-address (new-fee-to-address principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set fee-to-address new-fee-to-address))))

(define-public (pause-peg-in (paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-in-paused paused))))

(define-public (set-peg-in-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-in-fee fee))))

(define-public (set-peg-in-min-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-in-min-fee fee))))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

;; read-only functions

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (is-peg-in-paused)
	(var-get peg-in-paused))

(define-read-only (get-peg-in-fee)
	(var-get peg-in-fee))

(define-read-only (get-peg-in-min-fee)
	(var-get peg-in-min-fee))

(define-read-only (get-fee-to-address)
	(var-get fee-to-address))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 is-peg-in-address-approved address))

(define-read-only (get-peg-in-sent-or-default (tx (buff 32768)) (output uint))
	(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 get-peg-in-sent-or-default tx output))

(define-read-only (extract-tx-ins-outs (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 extract-tx-ins-outs tx))

(define-read-only (get-txid (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 get-txid tx))

(define-read-only (destruct-principal (address principal))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 destruct-principal address))

(define-read-only (construct-principal (hash-bytes (buff 20)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 construct-principal hash-bytes))
	
(define-read-only (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 verify-mined tx block proof))

(define-read-only (decode-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-from-reveal-tx-or-fail tx order-idx))

;; @dev agg order size > 80 bytes, so uses drop
(define-read-only (create-order-agg-or-fail (order { from: (buff 128), to: (buff 128), token-out: principal, min-amount-out: (optional uint), chain-id: (optional uint), dest-chain-id: uint, swap-token-in: principal, swap-token-out: principal }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), o: (get token-out order), m: (match (get min-amount-out order) some-value (int-to-ascii some-value) "none"), c: (match (get chain-id order) some-value (int-to-ascii some-value) "none"), d: (int-to-ascii (get dest-chain-id order)), s: (get swap-token-in order), t: (get swap-token-out order) }) err-invalid-input)))

(define-read-only (decode-order-agg-or-fail (order-script (buff 512)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), o: principal, m: (string-ascii 40), c: (string-ascii 40), d: (string-ascii 40), s: principal, t: principal } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), token-out: (get o raw-order), min-amount-out: (if (is-eq (get m raw-order) "none") none (some (unwrap-string-to-uint (get m raw-order)))), chain-id: (if (is-eq (get c raw-order) "none") none (some (unwrap-string-to-uint (get c raw-order)))), dest-chain-id: (unwrap-string-to-uint (get d raw-order)), swap-token-in: (get s raw-order), swap-token-out: (get t raw-order) })))

(define-read-only (decode-order-agg-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-agg-or-fail (get order-script decoded-data) u0))))
    (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

;; @dev reveal-tx is sent by bot to peg-in-address by consuming previous input, so we skip verify-mine
(define-read-only (validate-tx-agg (commit-tx { tx: (buff 32768), output-idx: uint }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
	(let (
			(validation-data (try! (validate-drop-tx-common commit-tx reveal-tx)))
			(order-details (try! (decode-order-agg-or-fail (get order-script validation-data) u0))))
		(try! (check-token (get swap-token-in order-details) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))
		(try! (check-token (get swap-token-out order-details) (get token-out order-details)))
		(ok { order-details: order-details, fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))

;; public functions

(define-public (finalize-peg-in-agg
	(tx (buff 32768))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) 
	(reveal-tx { tx: (buff 32768), order-idx: uint })
	(reveal-block { header: (buff 80), height: uint })
	(reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(swap-token-in-trait <ft-trait>))
	(let (
			(is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
			(common-check (try! (finalize-peg-in-common tx block proof)))
			(validation-data (try! (validate-tx-agg { tx: tx, output-idx: output-idx } reveal-tx)))
			(order-details (get order-details validation-data)))
		(as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed (+ (get fee validation-data) (get amount-net validation-data)) tx-sender)))
		(as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx output-idx true)))			
		(asserts! (is-eq (get swap-token-in order-details) (contract-of swap-token-in-trait)) err-token-mismatch)
		(and (> (get fee validation-data) u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (get fee validation-data) tx-sender (var-get fee-to-address) none))))
		(as-contract (try! (contract-call? .cross-peg-out-v2-01b-agg transfer-to-swap 
			(get amount-net validation-data) 
			swap-token-in-trait (get swap-token-out order-details) (get min-amount-out order-details) (get dest-chain-id order-details) 
			{ address: (get to order-details), chain-id: (get chain-id order-details), token: (get token-out order-details) } 
			{ address: (get from order-details), chain-id: (some u0), token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc })))			
		(print { type: "finalize-peg-in-agg", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: (get fee validation-data), amount-net: (get amount-net validation-data) })
		(ok true)))

;; internal functions

(define-private (validate-drop-tx-common (commit-tx { tx: (buff 32768), output-idx: uint }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
	(let (
			(parsed-tx (try! (extract-tx-ins-outs (get tx commit-tx))))
			(output (unwrap! (element-at (get outs parsed-tx) (get output-idx commit-tx)) err-invalid-tx))
			(amount (get value output))
			(peg-in-address (get scriptPubKey output))			
			(reveal-tx-data (try! (decode-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx))))
			(fee (max (mul-down amount (var-get peg-in-fee)) (var-get peg-in-min-fee)))
			(check-fee (asserts! (> amount fee) err-invalid-amount))
			(amount-net (- amount fee)))
		(asserts! (not (get-peg-in-sent-or-default (get tx commit-tx) (get output-idx commit-tx))) err-already-sent)
		(asserts! (is-peg-in-address-approved peg-in-address) err-peg-in-address-not-found)
    	(asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)

		(ok { parsed-tx: parsed-tx, order-script: (get order-script reveal-tx-data), fee: fee, amount-net: amount-net })))

(define-private (finalize-peg-in-common
	(tx (buff 32768))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(begin
		(asserts! (not (var-get peg-in-paused)) err-paused)
		(verify-mined tx block proof)))

(define-private (max (a uint) (b uint))
	(if (< a b) b a))

(define-private (min (a uint) (b uint))
	(if (< a b) a b))

(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (unwrap-string-to-uint (input (string-ascii 40)))
	(unwrap-panic (string-to-uint? input)))

(define-private (check-token (token-a principal) (token-b principal))
  (ok (asserts! (or (is-eq token-a token-b) 
    (match (contract-call? .cross-router-v2-03 get-approved-wrapped-or-fail token-a)
      some-a (is-eq some-a token-b)
      err-a (match (contract-call? .cross-router-v2-03 get-approved-wrapped-or-fail token-b)
        some-b (is-eq some-b token-a)
        err-b false))) err-token-mismatch)))

```
