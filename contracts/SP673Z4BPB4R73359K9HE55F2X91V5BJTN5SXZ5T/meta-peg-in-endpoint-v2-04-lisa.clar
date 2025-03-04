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
(define-constant err-invalid-request (err u1018))

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

;; @dev cross-swap order size > 80 bytes, so uses drop
(define-read-only (create-order-request-burn-or-fail (order { pay: (buff 128), inscribe: (buff 128), token: principal }))
	(ok (unwrap! (to-consensus-buff? { p: (get pay order), i: (get inscribe order), y: (get token order) }) err-invalid-input)))

;; @dev no op-code offset for drop-based order
(define-read-only (decode-order-request-burn-or-fail (order-script (buff 512)))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { p: (buff 128), i: (buff 128), y: principal } (unwrap-panic (slice? order-script u0 (len order-script)))) err-invalid-input)))
		(ok { pay: (get p raw-order), inscribe: (get i raw-order), token: (get y raw-order) })))

(define-read-only (decode-order-request-burn-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx))))
    (ok { commit-txid: (get commit-txid decoded-data), order-details: (try! (decode-order-request-burn-or-fail (get order-script decoded-data))) })))

(define-read-only (validate-tx-request-burn (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }) (token principal))
  (let (
			(validation-data (try! (validate-drop-common commit-tx)))
			(reveal-tx-data (try! (decode-order-request-burn-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx))))
      (order-details (get order-details reveal-tx-data)))
    (asserts! (is-eq (get token order-details) token) err-token-mismatch)
    (asserts! (is-eq (get token (get pair-details validation-data)) token) err-token-mismatch)
    (try! (contract-call? .liabtc-mint-endpoint validate-request-burn (fixed-to-liabtc (get amt-net validation-data))))
    (asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
    (ok (merge validation-data { order-details: order-details }))))

;; @dev remove update burn size > 80 bytes, so uses drop
(define-read-only (create-order-update-burn-or-fail (order { pay: (buff 128), inscribe: (buff 128), token: principal, request-id: uint, status: (buff 1) }))
  (ok (unwrap! (to-consensus-buff? { p: (get pay order), i: (get inscribe order), y: (get token order), r: (int-to-ascii (get request-id order)), s: (get status order) }) err-invalid-input)))

(define-read-only (decode-order-update-burn-or-fail (order-script (buff 512)))
	(let (
			(raw-order (unwrap! (from-consensus-buff? { p: (buff 128), i: (buff 128), y: principal, r: (string-ascii 40), s: (buff 1) } (unwrap-panic (slice? order-script u0 (len order-script)))) err-invalid-input)))
		(ok { pay: (get p raw-order), inscribe: (get i raw-order), token: (get y raw-order), request-id: (unwrap-string-to-uint (get r raw-order)), status: (get s raw-order) })))

(define-read-only (decode-order-update-burn-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (let (
      (decoded-data (try! (decode-from-reveal-tx-or-fail tx order-idx))))
    (ok { commit-txid: (get commit-txid decoded-data), order-details: (try! (decode-order-update-burn-or-fail (get order-script decoded-data))) })))

(define-read-only (validate-tx-update-burn (commit-tx { tx: (buff 32768), fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
  (let (         
      (reveal-tx-data (try! (decode-order-update-burn-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx))))
			(order-details (get order-details reveal-tx-data))      
      (status (try! (contract-call? .meta-bridge-registry-v2-03-lisa get-burn-request-or-fail { pay: (get pay order-details), inscribe: (get inscribe order-details), token: (get token order-details), request-id: (get request-id order-details) })))
      (revoke-or-finalize (asserts! (or (is-eq (get status order-details) 0x01) (is-eq (get status order-details) 0x02)) err-invalid-request))
      (request-details (if (is-eq (get status order-details) 0x01) ;; FINALIZED
        (try! (contract-call? .liabtc-mint-endpoint validate-finalize-burn (get request-id order-details)))
        (try! (contract-call? .liabtc-mint-endpoint validate-revoke-burn (get request-id order-details))))))
    (asserts! (is-eq status 0x00) err-invalid-request)
    (asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
    (ok (merge { order-details: order-details, request-details: request-details } (try! (process-fee (get tx commit-tx) (get fee-idx commit-tx)))))))

(define-read-only (get-liabtc-decimals)
  (contract-call? .token-liabtc get-decimals))

(define-read-only (liabtc-to-fixed (amount uint))
  (if (is-eq (unwrap-panic (get-liabtc-decimals)) u8) amount (/ (* amount ONE_8) (pow u10 (unwrap-panic (get-liabtc-decimals))))))

(define-read-only (fixed-to-liabtc (amount uint))
  (if (is-eq (unwrap-panic (get-liabtc-decimals)) u8) amount (/ (* amount (pow u10 (unwrap-panic (get-liabtc-decimals)))) ONE_8)))

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

(define-public (finalize-peg-in-request-burn-liabtc-on-index
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (fee-idx (optional uint))
  (liabtc-message { token: principal, accrued-rewards: uint, update-block: uint })
  (liabtc-signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))    
  (begin
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-in-request-burn-liabtc { tx: (get bitcoin-tx tx), output-idx: (get output tx), fee-idx: fee-idx } reveal-tx reveal-block reveal-proof liabtc-message liabtc-signature-packs)))

(define-public (finalize-peg-in-request-burn-liabtc
  (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) 
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (message { token: principal, accrued-rewards: uint, update-block: uint })
  (signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))  
  (let (
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (try! (validate-tx-request-burn commit-tx reveal-tx 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc)))
      (tx (get tx commit-tx))
      (order-details (get order-details validation-data))
			(token-details (get token-details validation-data))
      (fee (get fee validation-data))
      (amt-net (get amt-net validation-data))
      (peg-out-balance (- (unwrap-panic (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc get-balance-fixed .meta-peg-out-endpoint-v2-04)) amt-net)) 
      (tranfer-all (as-contract (try! (contract-call? .meta-peg-out-endpoint-v2-04 transfer-all-to tx-sender 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc))))
      (transfer-balance (as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc transfer-fixed peg-out-balance tx-sender .meta-peg-out-endpoint-v2-04 none))))
      (liabtc-amount (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc get-shares-to-tokens-fixed amt-net))
      (burn-vliabtc (as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc burn-fixed amt-net tx-sender))))
      (request-details (as-contract (try! (contract-call? .liabtc-mint-endpoint request-burn (fixed-to-liabtc liabtc-amount) message signature-packs)))))
    (asserts! (not (get peg-in-paused token-details)) err-paused)
		(asserts! (< burn-height-start (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-mined-or-fail tx))) err-tx-mined-before-start)		
    (match (get fee-idx commit-tx) some-value (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx some-value true))) true)
    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: (get output-idx commit-tx), offset: u0 } true)))
    (and (> fee u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed fee (var-get fee-to-address))))
    (try! (contract-call? .meta-bridge-registry-v2-03-lisa update-burn-request { pay: (get pay order-details), inscribe: (get inscribe order-details), token: (get token order-details), request-id: (get request-id request-details) } 0x00))
    (try! (contract-call? .meta-bridge-registry-v2-03-lisa add-inscribe-request-id (get inscribe order-details) (get request-id request-details)))
		(print (merge request-details (merge (get tx-idxed validation-data) { type: "peg-in", order-details: order-details, fee: fee, amt-net: amt-net, tx-id: (try! (get-txid tx)), output-idx: (get output-idx commit-tx), offset-idx: u0 })))
		(ok true)))

(define-public (finalize-peg-in-update-burn-liabtc
  (commit-tx { tx: (buff 32768), fee-idx: (optional uint) })  
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })  
  (reveal-tx { tx: (buff 32768), order-idx: uint })
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (message { token: principal, accrued-rewards: uint, update-block: uint })
  (signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))    
  (let (
      (is-commit-tx-mined (try! (verify-mined (get tx commit-tx) block proof)))
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (as-contract (try! (validate-tx-update-burn commit-tx reveal-tx))))
      (order-details (get order-details validation-data))
      (token-details (try! (get-pair-details-or-fail { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 })))
      (fee (get fee validation-data))
      (request-details (get request-details validation-data)))
    (asserts! (not (get peg-in-paused token-details)) err-paused)		
    (match (get fee-idx commit-tx) some-value (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent (get tx commit-tx) some-value true))) true)
    (as-contract (try! (contract-call? .meta-bridge-registry-v2-03-lisa update-burn-request { pay: (get pay order-details), inscribe: (get inscribe order-details), token: (get token order-details), request-id: (get request-id order-details) } (get status order-details))))
		(if (is-eq (get status order-details) 0x01) ;; FINALIZED
      (begin        
        (as-contract (try! (contract-call? .liabtc-mint-endpoint finalize-burn (get request-id order-details))))
        (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 (get pay order-details) (liabtc-to-fixed (get amount request-details)))))
        true)
      (let (
          (liabtc-in-fixed (liabtc-to-fixed (get amount request-details)))
          (burn-revoked (as-contract (try! (contract-call? .liabtc-mint-endpoint revoke-burn (get request-id order-details) message signature-packs))))
          (vliabtc-amount (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc get-tokens-to-shares-fixed liabtc-in-fixed)))                
        (as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc mint-fixed liabtc-in-fixed tx-sender)))
        (as-contract (try! (contract-call? .meta-peg-out-endpoint-v2-04 request-peg-out vliabtc-amount (get inscribe order-details) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc u1001)))))		
			  (print (merge request-details { type: "finalize-peg-in-update-burn-liabtc", order-details: order-details, fee: fee, tx-id: (try! (get-txid (get tx commit-tx))) }))
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

(define-private (break-routing-id (routing-ids (list 4 uint)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 break-routing-id routing-ids))

(define-private (extract-tx-ins-outs (tx (buff 32768)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 extract-tx-ins-outs tx))

(define-private (get-txid (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 get-txid tx))

(define-private (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 verify-mined tx block proof))

(define-private (refund (btc-amount uint) (token-amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
      (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
	    (token-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair-details)))
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
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details u0))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details u0))
      (try! (contract-call? .meta-peg-out-endpoint-v2-04 request-peg-out token-amount from token-trait the-chain-id))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details (get peg-out-fee token-details)))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details (get peg-out-gas-fee token-details)))
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