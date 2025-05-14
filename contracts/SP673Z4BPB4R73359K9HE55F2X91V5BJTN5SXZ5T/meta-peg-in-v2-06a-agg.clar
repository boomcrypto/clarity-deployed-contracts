;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

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
(define-constant err-slippage-error (err u1016))
(define-constant err-bitcoin-tx-not-mined (err u1017))
(define-constant err-invalid-routing (err u1018))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant burn-height-start burn-block-height)

(define-data-var paused bool true)
(define-data-var fee-to-address principal 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao)

(define-data-var peg-in-fee uint u0) ;; fixed in BTC

;; read-only functions

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (is-paused)
	(var-get paused))

(define-read-only (get-fee-to-address)
  (var-get fee-to-address))

(define-read-only (get-peg-in-fee)
	(var-get peg-in-fee))

(define-read-only (get-pair-details (pair { token: principal, chain-id: uint }))
  (match (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair) ok-value (some ok-value) err-value none))

(define-read-only (get-pair-details-many (pairs (list 200 { token: principal, chain-id: uint })))
  (map get-pair-details pairs))

(define-read-only (get-tick-to-pair-or-fail (tick (string-utf8 256)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-tick-to-pair-or-fail tick))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 is-peg-in-address-approved address))

(define-read-only (get-pair-details-or-fail (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair))

(define-read-only (is-approved-pair (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 is-approved-pair pair))

(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-peg-in-sent-or-default bitcoin-tx output offset))

;; @dev agg order size > 80 bytes, so uses drop
(define-read-only (create-order-agg-or-fail (order { from: (buff 128), to: (buff 128), token-in: principal, token-out: principal, min-amount-out: (optional uint), chain-id: (optional uint), dest-chain-id: uint, swap-token-in: principal, swap-token-out: principal }))
	(ok (unwrap! (to-consensus-buff? { f: (get from order), r: (get to order), i: (get token-in order), o: (get token-out order), m: (unwrap-panic (as-max-len? (match (get min-amount-out order) some-value (int-to-ascii some-value) "none") u40)), c: (unwrap-panic (as-max-len? (match (get chain-id order) some-value (int-to-ascii some-value) "none") u5)), d: (unwrap-panic (as-max-len? (int-to-ascii (get dest-chain-id order)) u5)), s: (get swap-token-in order), t: (get swap-token-out order) }) err-invalid-input)))

(define-read-only (decode-order-agg-or-fail (order-script (buff 512)) (offset uint))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { f: (buff 128), r: (buff 128), i: principal, o: principal, m: (string-ascii 40), c: (string-ascii 5), d: (string-ascii 5), s: principal, t: principal } (unwrap-panic (slice? order-script offset (len order-script)))) err-invalid-input)))
		(ok { from: (get f raw-order), to: (get r raw-order), token-in: (get i raw-order), token-out: (get o raw-order), min-amount-out: (if (is-eq (get m raw-order) "none") none (some (unwrap-string-to-uint (get m raw-order)))), chain-id: (if (is-eq (get c raw-order) "none") none (some (unwrap-string-to-uint (get c raw-order)))), dest-chain-id: (unwrap-string-to-uint (get d raw-order)), swap-token-in: (get s raw-order), swap-token-out: (get t raw-order) })))

(define-read-only (decode-order-agg-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx)))
      (order-details (try! (decode-order-agg-or-fail (get order-script decoded-data) u0))))
    (ok { commit-txid: (get commit-txid decoded-data), order-details: order-details })))

;; @dev reveal-tx is sent by bot to peg-in-address by consuming previous input, so we skip verify-mine
(define-read-only (validate-tx-agg (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
	(let (
			(validation-data (try! (validate-drop-common commit-tx)))
      (reveal-tx-data (try! (decode-order-agg-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx))))
			(order-details (get order-details reveal-tx-data)))
    (asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
		(try! (check-token (get swap-token-in order-details) (get token-in order-details)))
		(try! (check-token (get swap-token-out order-details) (get token-out order-details)))
		(ok (merge validation-data { order-details: order-details }))))
    
;; governance functions
(define-public (pause (new-paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set paused new-paused))))

(define-public (set-fee-to-address (new-fee-to-address principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set fee-to-address new-fee-to-address))))

(define-public (set-peg-in-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-in-fee fee))))

(define-public (transfer-all-to (new-owner principal) (token-trait <ft-trait>))
  (begin 
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer-fixed (unwrap-panic (contract-call? token-trait get-balance-fixed tx-sender)) tx-sender new-owner none))))

(define-public (transfer-all-to-many (new-owner principal) (token-traits (list 10 <ft-trait>)))
  (ok (map transfer-all-to (list new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner) token-traits)))

;; public functions

(define-public (finalize-peg-in-agg-on-index
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (fee-idx (optional uint)) (token-in-trait <ft-trait>) (swap-token-in-trait <ft-trait>)) 
  (begin
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-in-agg { tx: (get bitcoin-tx tx), output-idx: (get output tx), fee-idx: fee-idx } reveal-tx reveal-block reveal-proof token-in-trait swap-token-in-trait)))

(define-public (finalize-peg-in-agg 
  (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) 
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (token-in-trait <ft-trait>) (swap-token-in-trait <ft-trait>))
  (let (
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (try! (validate-tx-agg commit-tx reveal-tx)))
      (tx (get tx commit-tx))
      (order-details (get order-details validation-data))
			(token-details (get token-details validation-data))
      (pair-details (get pair-details validation-data))
      (fee (get fee validation-data))
      (amt-net (get amt-net validation-data)))
    (asserts! (not (get peg-in-paused token-details)) err-paused)
		;; (asserts! (< burn-height-start (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-mined-or-fail tx))) err-tx-mined-before-start)		
    (match (get fee-idx commit-tx) some-value (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx some-value true))) true)
    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: (get output-idx commit-tx), offset: u0 } true)))
    (and (> fee u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed fee tx-sender))))
    (try! (check-trait token-in-trait (get token-in order-details)))
    (try! (check-trait swap-token-in-trait (get swap-token-in order-details)))
    (and (> amt-net u0) (if (get no-burn token-details) 
      (let (
          (peg-out-balance (- (unwrap-panic (contract-call? token-in-trait get-balance-fixed .meta-peg-out-endpoint-v2-04)) amt-net))) 
        (as-contract (try! (contract-call? .meta-peg-out-endpoint-v2-04 transfer-all-to tx-sender token-in-trait)))
        (as-contract (try! (contract-call? token-in-trait transfer-fixed peg-out-balance tx-sender .meta-peg-out-endpoint-v2-04 none))))
      (as-contract (try! (contract-call? token-in-trait mint-fixed amt-net tx-sender)))))
    (as-contract (try! (contract-call? .cross-peg-out-v2-01b-agg transfer-to-swap amt-net swap-token-in-trait (get swap-token-out order-details) (get min-amount-out order-details) (get dest-chain-id order-details) 
      { address: (get to order-details), chain-id: (get chain-id order-details), token: (get token-out order-details) }
      { address: (get from order-details), chain-id: (some (get chain-id pair-details)), token: (get token-in order-details) })))
    (print (merge (get tx-idxed validation-data) { type: "finalize-peg-in-agg", order-details: order-details, fee: fee, amt-net: amt-net, tx-id: (try! (get-txid tx)), output-idx: (get output-idx commit-tx), offset-idx: u0 }))
    (ok true)))

;; internal functions

(define-private (validate-drop-common (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }))
	(let (
      (tx-idxed (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get tx commit-tx) (get output-idx commit-tx) u0)))      
      (pair-details (try! (get-tick-to-pair-or-fail (get tick tx-idxed))))
      (token-details (try! (get-pair-details-or-fail pair-details)))
      (amt-in-fixed (decimals-to-fixed (get amt tx-idxed) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-tick-decimals-or-default (get tick tx-idxed)))))    
    (asserts! (get approved token-details) err-unauthorised)
    (asserts! (not (get-peg-in-sent-or-default (get tx commit-tx) (get output-idx commit-tx) u0)) err-already-sent)
    (asserts! (is-peg-in-address-approved (get to tx-idxed)) err-peg-in-address-not-found)     	
    (ok (merge { tx-idxed: tx-idxed, pair-details: pair-details, token-details: token-details, amt-net: amt-in-fixed } (try! (process-fee (get tx commit-tx) (get fee-idx commit-tx)))))))

(define-private (index-tx
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) })))
  (begin 
    (and 
      (not (is-ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get bitcoin-tx tx) (get output tx) u0)))
      (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 index-tx-many (list { tx: (merge tx { offset: u0 }), block: block, proof: proof, signature-packs: signature-packs })))))
    (print { type: "indexed-tx", tx-id: (try! (get-txid (get bitcoin-tx tx))), block: block, proof: proof, signature-packs: signature-packs })
    (ok true)))

(define-private (max (a uint) (b uint))
	(if (< a b) b a))

(define-private (min (a uint) (b uint))
  (if (< a b) a b))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (decimals-to-fixed (amount uint) (decimals uint))
  (/ (* amount ONE_8) (pow u10 decimals)))

(define-private (unwrap-string-to-uint (input (string-ascii 40)))
	(unwrap-panic (string-to-uint? input)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-trait (token-trait <ft-trait>) (token principal))
  (ok (asserts! (is-eq (contract-of token-trait) token) err-token-mismatch)))

(define-private (decode-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-from-reveal-tx-or-fail tx order-idx))

(define-private (extract-tx-ins-outs (tx (buff 32768)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 extract-tx-ins-outs tx))

(define-private (get-txid (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 get-txid tx))

(define-private (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 verify-mined tx block proof))

(define-private (process-fee (tx (buff 32768)) (fee-idx (optional uint)))
  (match fee-idx some-value
    (let (
			  (fee-output (unwrap! (element-at (get outs (try! (extract-tx-ins-outs tx))) some-value) err-invalid-tx)))
      (asserts! (>= (get value fee-output) (get-peg-in-fee)) err-invalid-amount)  
		  (asserts! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 is-peg-in-address-approved (get scriptPubKey fee-output)) err-peg-in-address-not-found)
      (asserts! (not (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 get-peg-in-sent-or-default tx some-value)) err-already-sent)    
      (ok { fee: (get value fee-output) }))
    (begin 
      (asserts! (is-eq u0 (get-peg-in-fee)) err-invalid-amount)  
      (ok { fee: u0 }))))

(define-private (check-token (token-a principal) (token-b principal))
  (ok (asserts! (or (is-eq token-a token-b) 
    (match (contract-call? .cross-router-v2-03 get-approved-wrapped-or-fail token-a)
      some-a (is-eq some-a token-b)
      err-a (match (contract-call? .cross-router-v2-03 get-approved-wrapped-or-fail token-b)
        some-b (is-eq some-b token-a)
        err-b false))) err-token-mismatch)))