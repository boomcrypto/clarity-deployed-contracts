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

(define-read-only (create-order-mint-liabtc-or-fail (order { pay: (buff 128), inscribe: (buff 128) }))
	(ok (unwrap! (to-consensus-buff? { p: (get pay order), i: (get inscribe order) }) err-invalid-input)))

(define-read-only (decode-order-mint-liabtc-or-fail (order-script (buff 128)) (offset uint))
  (let (
      (raw-order (unwrap! (from-consensus-buff? { p: (buff 128), i: (buff 128) } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
    (ok { pay: (get p raw-order), inscribe: (get i raw-order) })))

(define-read-only (validate-tx-mint-liabtc (tx (buff 32768)) (output-idx uint) (order-idx uint))
  (validate-tx-mint-liabtc-extra (try! (validate-tx-mint-liabtc-base tx output-idx order-idx))))

(define-read-only (get-liabtc-decimals)
  (contract-call? .token-liabtc get-decimals))

(define-read-only (liabtc-to-fixed (amount uint))
	(if (is-eq (unwrap-panic (get-liabtc-decimals)) u8) amount (/ (* amount ONE_8) (pow u10 (unwrap-panic (get-liabtc-decimals))))))

(define-read-only (fixed-to-liabtc (amount uint))
	(if (is-eq (unwrap-panic (get-liabtc-decimals)) u8) amount (/ (* amount (pow u10 (unwrap-panic (get-liabtc-decimals)))) ONE_8)))

;; public functions

(define-public (finalize-peg-in-mint-liabtc
  (tx (buff 32768))
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (output-idx uint) (order-idx uint)
  (message { token: principal, accrued-rewards: uint, update-block: uint })
  (signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))  
  (let (
      	(common-check (try! (finalize-peg-in-common tx block proof)))
      	(validation-data (try! (validate-tx-mint-liabtc-base tx output-idx order-idx)))
		(amount-net (get amount-net validation-data))
		(fee (get fee validation-data))
      	(order-details (get order-details validation-data))
      	(print-msg { type: "finalize-peg-in-mint-liabtc", tx-id: (try! (get-txid tx)), output: output-idx, order-details: order-details, fee: fee, amount-net: amount-net }))
    (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed (+ fee amount-net) tx-sender)))
	(as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx output-idx true)))
    (match (validate-tx-mint-liabtc-extra validation-data)
      ok-value
      (let (
			(mint-liabt (as-contract (try! (contract-call? .liabtc-mint-endpoint mint (fixed-to-liabtc amount-net) message signature-packs))))
			(vliabtc-amount (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc get-tokens-to-shares-fixed amount-net)))
		(as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc mint-fixed amount-net tx-sender)))
		(as-contract (try! (contract-call? .meta-peg-out-endpoint-v2-04 request-peg-out vliabtc-amount (get inscribe order-details) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc u1001)))
		(and (> fee u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed fee tx-sender (var-get fee-to-address) none))))
        (print (merge print-msg { success: true }))
        (ok true))
      err-value
      (begin
			(as-contract (try! (refund (+ fee amount-net) (get pay order-details) )))
			(print (merge print-msg { success: false, err-value: err-value }))
        (ok false)))))

;; internal functions

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (validate-tx-mint-liabtc-base (tx (buff 32768)) (output-idx uint) (order-idx uint))
  (let (
      (validation-data (try! (validate-tx-common tx output-idx order-idx)))
	  (offset (if (< (unwrap-panic (slice? (get order-script validation-data) u1 u2)) 0x4c) u2 u3)))
    (ok { order-details: (try! (decode-order-mint-liabtc-or-fail (get order-script validation-data) offset)), fee: (get fee validation-data), amount-net: (get amount-net validation-data) })))

(define-private (validate-tx-mint-liabtc-extra (validation-data { order-details: { pay: (buff 128), inscribe: (buff 128) }, fee: uint, amount-net: uint }))
  (let (
		(vliabtc-amount (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc get-tokens-to-shares-fixed (get amount-net validation-data))))
	(try! (contract-call? .liabtc-mint-endpoint validate-mint (fixed-to-liabtc (get amount-net validation-data))))
	;; @dev we use the vliabtc amount to validate the peg-out, though it is not exactly correct due to rebase upon mint
  	(try! (contract-call? .meta-peg-out-endpoint-v2-04 validate-peg-out vliabtc-amount { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 }))
    (ok validation-data)))

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
      			(btc-peg-out-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
      			(btc-peg-out-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 from amount))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee btc-peg-out-fee))
      		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee btc-peg-out-min-fee))
      	true))))
