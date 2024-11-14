---
title: "Trait meta-peg-in-endpoint-v2-03"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

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
(define-constant err-slippage-error (err u1016))
(define-constant err-bitcoin-tx-not-mined (err u1017))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant burn-height-start burn-block-height)

(define-data-var paused bool true)
(define-data-var fee-to-address principal tx-sender)

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
  (match (contract-call? .meta-bridge-registry-v2-03 get-pair-details-or-fail pair) ok-value (some ok-value) err-value none))

(define-read-only (get-pair-details-many (pairs (list 200 { token: principal, chain-id: uint })))
  (map get-pair-details pairs))

(define-read-only (get-tick-to-pair-or-fail (tick (string-utf8 256)))
	(contract-call? .meta-bridge-registry-v2-03 get-tick-to-pair-or-fail tick))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
  (contract-call? .meta-bridge-registry-v2-03 is-peg-in-address-approved address))

(define-read-only (get-pair-details-or-fail (pair { token: principal, chain-id: uint }))
  (contract-call? .meta-bridge-registry-v2-03 get-pair-details-or-fail pair))

(define-read-only (is-approved-pair (pair { token: principal, chain-id: uint }))
  (contract-call? .meta-bridge-registry-v2-03 is-approved-pair pair))

(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
  (contract-call? .meta-bridge-registry-v2-03 get-peg-in-sent-or-default bitcoin-tx output offset))

;; @dev cross order size > 80 bytes, so uses drop
(define-read-only (create-order-cross-or-fail (order { from: (buff 128), to: (buff 128), chain-id: (optional uint), token: principal, token-out: principal }))
	(contract-call? .bridge-common-v2-02 create-order-cross-or-fail order))

;; @dev no op-code offset for drop-based order
(define-read-only (decode-order-cross-or-fail (order-script (buff 128)))
	(contract-call? .bridge-common-v2-02 decode-order-cross-or-fail order-script u0))

(define-read-only (decode-order-cross-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? .bridge-common-v2-02 decode-order-cross-from-reveal-tx-or-fail tx order-idx))

;; @dev reveal-tx is sent by bot to peg-in-address by consuming previous input, so we skip verify-mine
(define-read-only (validate-tx-cross (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }) (token-out-trait <ft-trait>))
	(validate-tx-cross-extra (try! (validate-tx-cross-base commit-tx reveal-tx)) token-out-trait))

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

(define-public (finalize-peg-in-cross-on-index
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (reveal-tx { tx: (buff 32768), order-idx: uint })
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (fee-idx (optional uint))
  (token-trait <ft-trait>)
  (token-out-trait <ft-trait>))
  (begin
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-in-cross { tx: (get bitcoin-tx tx), output-idx: (get output tx), fee-idx: fee-idx } reveal-tx reveal-block reveal-proof token-trait token-out-trait)))

(define-public (finalize-peg-in-cross 
  (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) 
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })  
  (token-trait <ft-trait>)
  (token-out-trait <ft-trait>))
  (let (
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (try! (validate-tx-cross-base commit-tx reveal-tx)))
      (tx (get tx commit-tx))
      (order-details (get order-details validation-data))
      (token-details (get token-details validation-data))
      (fee (get fee validation-data))
      (amt-net (get amt-net validation-data))
			(print-msg (merge (get tx-idxed validation-data) { type: "peg-in", order-details: order-details, fee: fee, amt-net: amt-net, tx-id: (try! (get-txid tx)), output-idx: (get output-idx commit-tx), offset-idx: u0 })))
    (asserts! (not (get peg-in-paused token-details)) err-paused)
		(asserts! (< burn-height-start (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-mined-or-fail tx))) err-tx-mined-before-start)		
    (match (get fee-idx commit-tx) some-value (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx some-value true))) true)
    (as-contract (try! (contract-call? .meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: (get output-idx commit-tx), offset: u0 } true)))
    (and (> fee u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed fee tx-sender))))
    (try! (check-trait token-trait (get token (get pair-details validation-data))))
    (and (> amt-net u0) (if (get no-burn token-details) 
      (let (
          (peg-out-balance (- (unwrap-panic (contract-call? token-trait get-balance-fixed .meta-peg-out-endpoint-v2-03)) amt-net))) 
        (as-contract (try! (contract-call? .meta-peg-out-endpoint-v2-03 transfer-all-to tx-sender token-trait)))
        (as-contract (try! (contract-call? token-trait transfer-fixed peg-out-balance tx-sender .meta-peg-out-endpoint-v2-03 none))))
      (as-contract (try! (contract-call? token-trait mint-fixed amt-net tx-sender)))))
		(match (validate-tx-cross-extra validation-data token-out-trait)
			ok-value
			(begin
				(and (> fee u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed fee tx-sender (var-get fee-to-address) none))))		
				(as-contract (try! (contract-call? .cross-router-v2-02 route amt-net (list token-trait) (list ) token-out-trait none { address: (get to order-details), chain-id: (get chain-id order-details) })))
				(print (merge print-msg { success: true }))
				(ok true))
			err-value
			(begin
			  (as-contract (try! (refund fee amt-net (get from order-details) token-trait (get chain-id (get pair-details validation-data)))))
				(print (merge print-msg { success: false, err-value: err-value }))
				(ok false)))))

;; internal functions

(define-private (validate-tx-cross-base (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
  (let (
			(validation-data (try! (validate-drop-common commit-tx)))
			(reveal-tx-data (try! (decode-order-cross-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx)))))
    (asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
    (ok (merge validation-data { order-details: (get order-details reveal-tx-data) }))))

(define-private (validate-tx-cross-extra
  (validation-data {
    fee: uint, amt-net: uint, 
    tx-idxed: { tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128) }, 
    pair-details: { token: principal, chain-id: uint },
    token-details: { approved: bool, tick: (string-utf8 256), peg-in-paused: bool, peg-out-paused: bool, peg-in-fee: uint, peg-out-fee: uint, peg-out-gas-fee: uint, no-burn: bool },
    order-details: { from: (buff 128), to: (buff 128), chain-id: (optional uint), token: principal, token-out: principal }})
  (token-out-trait <ft-trait>))
	(let (			
			(order-details (get order-details validation-data)))
    (asserts! (is-eq (get token order-details) (get token (get pair-details validation-data))) err-token-mismatch)
    (try! (check-trait token-out-trait (get token-out order-details)))
		(try! (contract-call? .cross-router-v2-02 validate-route (get amt-net validation-data) (list (get token order-details)) (list ) (get token-out order-details) none { address: (get to order-details), chain-id: (get chain-id order-details) }))
		(ok validation-data)))

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
  (contract-call? .bridge-common-v2-02 decode-from-reveal-tx-or-fail tx order-idx))

(define-private (break-routing-id (routing-ids (list 4 uint)))
	(contract-call? .bridge-common-v2-02 break-routing-id routing-ids))

(define-private (extract-tx-ins-outs (tx (buff 32768)))
  (contract-call? .bridge-common-v2-02 extract-tx-ins-outs tx))

(define-private (get-txid (tx (buff 32768)))
	(contract-call? .bridge-common-v2-02 get-txid tx))

(define-private (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? .bridge-common-v2-02 verify-mined tx block proof))

(define-private (refund (btc-amount uint) (token-amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
      (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
	    (token-details (try! (contract-call? .meta-bridge-registry-v2-03 get-pair-details-or-fail pair-details)))
      (btc-peg-out-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
      (btc-peg-out-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
    (and (> btc-amount u0) (begin
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 from btc-amount))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee btc-peg-out-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee btc-peg-out-min-fee))
      true))
    (and (> token-amount u0) (begin
      (try! (contract-call? .meta-bridge-registry-v2-03 set-peg-out-fee pair-details u0))
      (try! (contract-call? .meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details u0))
      (try! (contract-call? .meta-peg-out-endpoint-v2-03 request-peg-out token-amount from token-trait the-chain-id))
      (try! (contract-call? .meta-bridge-registry-v2-03 set-peg-out-fee pair-details (get peg-out-fee token-details)))
      (try! (contract-call? .meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details (get peg-out-gas-fee token-details)))
      true))
    (ok true))) 

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
```
