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
(define-data-var peg-out-fee uint u0)
(define-data-var peg-out-gas-fee uint u0) ;; fixed in BTC (charged upfront)

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

(define-public (set-peg-out-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-out-fee fee))))

(define-public (set-peg-out-gas-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-out-gas-fee fee))))

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

(define-read-only (get-peg-out-fee)
	(var-get peg-out-fee))

(define-read-only (get-peg-out-gas-fee)
	(var-get peg-out-gas-fee))

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
  
(define-read-only (break-routing-id (routing-ids (list 4 uint)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 break-routing-id routing-ids))

;; @dev cross-swap order size > 80 bytes, so uses drop
(define-read-only (create-order-cross-swap-or-fail (order { from: (buff 128), to: (buff 128), routing: (list 4 uint), token-out: principal, min-amount-out: (optional uint), chain-id: (optional uint) }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 create-order-cross-swap-or-fail order))

;; @dev no op-code offset for drop-based order
(define-read-only (decode-order-cross-swap-or-fail (order-script (buff 512)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-order-cross-swap-or-fail order-script u0))

(define-read-only (decode-order-cross-swap-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-order-cross-swap-from-reveal-tx-or-fail tx order-idx))

;; @dev reveal-tx is sent by bot to peg-in-address by consuming previous input, so we skip verify-mine
(define-read-only (validate-tx-cross-swap (commit-tx { tx: (buff 32768), output-idx: uint }) (reveal-tx { tx: (buff 32768), order-idx: uint }) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>))
	(validate-tx-cross-swap-extra (try! (validate-tx-cross-swap-base commit-tx reveal-tx)) routing-traits token-out-trait))

(define-read-only (get-default-peg-out-fee (pair-tuple { token: principal, chain-id: (optional uint) }))
	(match (get chain-id pair-tuple)
		some-value
		(if (is-eq some-value u0)
    		(ok { peg-out-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee), peg-out-gas-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee) })
    		(if (or (is-eq some-value u1001) (is-eq some-value u1002)) ;; brc20 or runes
      			(let (
        			(pair-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 get-pair-details-or-fail { token: (get token pair-tuple), chain-id: some-value }))))
					(ok { peg-out-fee: (get peg-out-fee pair-details), peg-out-gas-fee: (get peg-out-gas-fee pair-details) }))
      			(let (
        			(pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: (get token pair-tuple), chain-id: some-value }))))
					(ok { peg-out-fee: (get fee pair-details), peg-out-gas-fee: (get min-fee pair-details) }))))
		(ok { peg-out-fee: u0, peg-out-gas-fee: u0 })))

;; public functions

(define-public (finalize-peg-in-cross-swap
	(tx (buff 32768))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) 
	(reveal-tx { tx: (buff 32768), order-idx: uint })
	(reveal-block { header: (buff 80), height: uint })
	(reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(routing-traits (list 5 <ft-trait>))
	(token-out-trait <ft-trait>))
	(let (
			(is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
			(common-check (try! (finalize-peg-in-common tx block proof)))
			(validation-data (try! (validate-tx-cross-swap-base { tx: tx, output-idx: output-idx } reveal-tx)))
			(order-details (get order-details validation-data))
			(pair-tuple { token: (get token-out order-details), chain-id: (get chain-id order-details) })
			(token-is-meta (or (is-eq (get chain-id order-details) (some u1001)) (is-eq (get chain-id order-details) (some u1002))))
			(print-msg { type: "finalize-peg-in-cross-swap", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: (get fee validation-data), amount-net: (get amount-net validation-data) })
			(default-fee-tuple (try! (get-default-peg-out-fee pair-tuple))))
		(as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed (+ (get fee validation-data) (get amount-net validation-data)) tx-sender)))
		(as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx output-idx true)))
		(try! (update-peg-out-fee pair-tuple (var-get peg-out-fee) u0))
		(match (validate-tx-cross-swap-extra validation-data routing-traits token-out-trait)
			ok-value
			(begin
				(and (> (get fee validation-data) u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (get fee validation-data) tx-sender (var-get fee-to-address) none))))
				(as-contract (try! (contract-call? .cross-router-v2-03 route (get amount-net validation-data) routing-traits (get routing-factors ok-value) token-out-trait (get min-amount-out order-details) { address: (get to order-details), chain-id: (get chain-id order-details) })))
				(try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple)))
				(print (merge print-msg { success: true }))
				(ok true))
			err-value
			(begin
				(as-contract (try! (refund (+ (get fee validation-data) (get amount-net validation-data)) (get from order-details))))
				(try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple)))
				(print (merge print-msg { success: false, err-value: err-value }))
				(ok false)))))

;; internal functions

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-trait (token-trait <ft-trait>) (token principal))
  (ok (asserts! (is-eq (contract-of token-trait) token) err-token-mismatch)))

(define-private (validate-tx-cross-swap-base (commit-tx { tx: (buff 32768), output-idx: uint }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
	(let (
			(validation-data (try! (validate-drop-tx-common commit-tx reveal-tx))))
		(ok { order-details: (try! (decode-order-cross-swap-or-fail (get order-script validation-data))), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))

(define-private (validate-tx-cross-swap-extra (validation-data { order-details: { from: (buff 128), to: (buff 128), routing: (list 4 uint), token-out: principal, min-amount-out: (optional uint), chain-id: (optional uint) }, fee: uint, amount-net: uint }) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>))
	(let (			
			(order-details (get order-details validation-data))
			(routing-details (try! (break-routing-id (get routing order-details)))))
		(asserts! (is-eq (len routing-traits) (len (get routing-tokens routing-details))) err-token-mismatch)
		(try! (check-trait token-out-trait (get token-out order-details)))
      	(try! (fold check-err (map check-trait routing-traits (get routing-tokens routing-details)) (ok true)))			
		(try! (contract-call? .cross-router-v2-03 validate-route (get amount-net validation-data) (get routing-tokens routing-details) (get routing-factors routing-details) (get token-out order-details) (get min-amount-out order-details) { address: (get to order-details), chain-id: (get chain-id order-details) }))
		(ok (merge validation-data { routing-tokens: (get routing-tokens routing-details), routing-factors: (get routing-factors routing-details) }))))

(define-private (validate-tx-common (tx (buff 32768)) (output-idx uint) (order-idx uint))
	(let (
			(parsed-tx (try! (extract-tx-ins-outs tx)))
			(output (unwrap! (element-at (get outs parsed-tx) output-idx) err-invalid-tx))
			(amount (get value output))
			(peg-in-address (get scriptPubKey output))
			(order-script (get scriptPubKey (unwrap-panic (element-at? (get outs parsed-tx) order-idx))))
			(fee (max (mul-down amount (var-get peg-in-fee)) (var-get peg-in-min-fee)))
			(check-fee (asserts! (> amount fee) err-invalid-amount))
			(amount-net (- amount fee)))
		(asserts! (not (get-peg-in-sent-or-default tx output-idx)) err-already-sent)
		(asserts! (is-peg-in-address-approved peg-in-address) err-peg-in-address-not-found)

		(ok { parsed-tx: parsed-tx, order-script: order-script, fee: fee, amount-net: amount-net })))

(define-private (validate-drop-tx-common (commit-tx { tx: (buff 32768), output-idx: uint }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
	(let (
			(parsed-tx (try! (extract-tx-ins-outs (get tx commit-tx))))
			(output (unwrap! (element-at (get outs parsed-tx) (get output-idx commit-tx)) err-invalid-tx))
			(amount (get value output))
			(peg-in-address (get scriptPubKey output))			
			(reveal-tx-data (try! (decode-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx))))
			(fee (+ (max (mul-down amount (var-get peg-in-fee)) (var-get peg-in-min-fee)) (var-get peg-out-gas-fee)))
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

(define-private (refund (amount uint) (from (buff 128)))
	(ok (and (> amount u0)
  		(let (
      			(default-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
      			(default-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 from amount))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee default-fee))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee default-min-fee))
      	true))))

(define-private (update-peg-out-fee (pair-tuple { token: principal, chain-id: (optional uint) }) (the-peg-out-fee uint) (the-peg-out-gas-fee uint))
	(match (get chain-id pair-tuple)
		some-value
		(if (is-eq some-value u0)
			(begin
      			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee the-peg-out-fee))
      			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee the-peg-out-gas-fee))
      			(ok true))
    		(if (or (is-eq some-value u1001) (is-eq some-value u1002))
      			(begin
					(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: (get token pair-tuple), chain-id: some-value } the-peg-out-fee))
					(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: (get token pair-tuple), chain-id: some-value } the-peg-out-gas-fee))
        			(ok true))
				(let (
					(pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: (get token pair-tuple), chain-id: some-value })))
					(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: (get token pair-tuple), chain-id: some-value } { fee: the-peg-out-fee, min-fee: the-peg-out-gas-fee, approved: (get approved pair-details), burnable: (get burnable pair-details), max-amount: (get max-amount pair-details), min-amount: (get min-amount pair-details) })))		
					(ok true))))
		(ok true)))
