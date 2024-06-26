(impl-trait .extension-trait.extension-trait)
(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-invalid-amount (err u1003))
(define-constant err-invalid-tx (err u1004))
(define-constant err-already-sent (err u1005))
(define-constant err-address-mismatch (err u1006))
(define-constant err-request-already-revoked (err u1007))
(define-constant err-request-already-finalized (err u1008))
(define-constant err-revoke-grace-period (err u1009))
(define-constant err-request-already-claimed (err u1010))
(define-constant err-bitcoin-tx-not-mined (err u1011))
(define-constant err-tx-mined-before-request (err u1013))
(define-constant err-slippage (err u1016))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-data-var fee-to-address principal tx-sender)
(define-data-var peg-out-paused bool true)
(define-data-var peg-out-fee uint u0)
(define-data-var peg-out-min-fee uint u0)
(define-public (set-fee-to-address (new-fee-to-address principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set fee-to-address new-fee-to-address))))
(define-public (pause-peg-out (paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-out-paused paused))))
(define-public (set-peg-out-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-out-fee fee))))
(define-public (set-peg-out-min-fee (fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set peg-out-min-fee fee))))
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised)))
(define-read-only (is-peg-out-paused)
	(var-get peg-out-paused))
(define-read-only (get-peg-out-fee)
	(var-get peg-out-fee))
(define-read-only (get-peg-out-min-fee)
	(var-get peg-out-min-fee))
(define-read-only (get-request-revoke-grace-period)
	(contract-call? .btc-bridge-registry-v2-01 get-request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(contract-call? .btc-bridge-registry-v2-01 get-request-claim-grace-period))
(define-read-only (get-request-or-fail (request-id uint))
	(contract-call? .btc-bridge-registry-v2-01 get-request-or-fail request-id))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? .btc-bridge-registry-v2-01 is-peg-in-address-approved address))
(define-read-only (get-peg-in-sent-or-default (tx (buff 32768)) (output uint))
	(contract-call? .btc-bridge-registry-v2-01 get-peg-in-sent-or-default tx output))
(define-read-only (get-fee-to-address)
	(var-get fee-to-address))
(define-read-only (extract-tx-ins-outs (tx (buff 32768)))
	(if (try! (contract-call? .clarity-bitcoin-v1-07 is-segwit-tx tx))
		(let (
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-07 parse-wtx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
		(let (
				(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-07 parse-tx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))))
(define-read-only (get-txid (tx (buff 32768)))
	(if (try! (contract-call? .clarity-bitcoin-v1-07 is-segwit-tx tx))
		(ok (contract-call? .clarity-bitcoin-v1-07 get-segwit-txid tx))
		(ok (contract-call? .clarity-bitcoin-v1-07 get-txid tx))))
(define-read-only (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(if (is-eq chain-id u1)
		(let (
				(response (if (try! (contract-call? .clarity-bitcoin-v1-07 is-segwit-tx tx))
					(contract-call? .clarity-bitcoin-v1-07 was-segwit-tx-mined? block tx proof)
					(contract-call? .clarity-bitcoin-v1-07 was-tx-mined? block tx proof))
				))
			(if (or (is-err response) (not (unwrap-panic response)))
				err-bitcoin-tx-not-mined
				(ok true)
			))
		(ok true))) ;; if not mainnet, assume verified
(define-read-only (validate-peg-out-0 (amount uint))
	(let (
			(gas-fee (var-get peg-out-min-fee))
			(fee (- (max (mul-down amount (var-get peg-out-fee)) gas-fee) gas-fee)))
		(asserts! (> amount (+ fee gas-fee)) err-invalid-amount)
		(ok { amount: (- amount fee gas-fee), fee: fee, gas-fee: gas-fee })))
(define-public (request-peg-out-0 (peg-out-address (buff 128)) (amount uint))
	(let (
			(validation-data (try! (validate-peg-out-0 amount)))
			(gas-fee (get gas-fee validation-data))
			(fee (get fee validation-data))
			(amount-net (get amount validation-data))
			(request-details { requested-by: tx-sender, peg-out-address: peg-out-address, amount-net: amount-net, fee: fee, gas-fee: gas-fee, claimed: u0, claimed-by: tx-sender, fulfilled-by: 0x, revoked: false, finalized: false, requested-at: block-height, requested-at-burn-height: burn-block-height })
			(request-id (as-contract (try! (contract-call? .btc-bridge-registry-v2-01 set-request u0 request-details)))))
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(try! (contract-call? .token-abtc transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(print (merge request-details { type: "request-peg-out", request-id: request-id }))
		(ok request-id)))
(define-public (claim-peg-out (request-id uint) (fulfilled-by (buff 128)))
	(let (
			(claimer tx-sender)
			(request-details (try! (get-request-or-fail request-id))))
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(asserts! (< (get claimed request-details) block-height) err-request-already-claimed)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v2-01 set-request request-id (merge request-details { claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))))
		(print (merge request-details { type: "claim-peg-out", request-id: request-id, claimed: (+ block-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))
		(ok true)))
(define-public (finalize-peg-out
	(request-id uint)
	(tx (buff 32768))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (fulfilled-by-idx uint))
	(let (
			(request-details (try! (get-request-or-fail request-id)))
			(was-mined (try! (verify-mined tx block proof)))
			(parsed-tx (try! (extract-tx-ins-outs tx)))
			(output (unwrap! (element-at (get outs parsed-tx) output-idx) err-invalid-tx))
			(fulfilled-by (get scriptPubKey (unwrap! (element-at (get outs parsed-tx) fulfilled-by-idx) err-invalid-tx)))
			(amount (get value output))
			(peg-out-address (get scriptPubKey output))
			(is-fulfilled-by-peg-in (is-peg-in-address-approved fulfilled-by)))
		(asserts! (not (var-get peg-out-paused)) err-paused)
		(asserts! (is-eq amount (get amount-net request-details)) err-invalid-amount)
		(asserts! (is-eq (get peg-out-address request-details) peg-out-address) err-address-mismatch)
		(asserts! (is-eq (get fulfilled-by request-details) fulfilled-by) err-address-mismatch)
		(asserts! (< (get requested-at-burn-height request-details) (get height block)) err-tx-mined-before-request)
		;; (asserts! (<= block-height (get claimed request-details)) err-request-claim-expired) ;; allow fulfilled if not claimed again
		(asserts! (not (get-peg-in-sent-or-default tx output-idx)) err-already-sent)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v2-01 set-peg-in-sent tx output-idx true)))
		(as-contract (try! (contract-call? .btc-bridge-registry-v2-01 set-request request-id (merge request-details { finalized: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get fee request-details) tx-sender (var-get fee-to-address) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get gas-fee request-details) tx-sender (if is-fulfilled-by-peg-in (var-get fee-to-address) (get claimed-by request-details)) none))))
		(if is-fulfilled-by-peg-in
			(as-contract (try! (contract-call? .token-abtc burn-fixed (get amount-net request-details) tx-sender)))
			(as-contract (try! (contract-call? .token-abtc transfer-fixed (get amount-net request-details) tx-sender (get claimed-by request-details) none))))
		(print { type: "finalize-peg-out", request-id: request-id, tx: tx })
		(ok true)))
(define-public (revoke-peg-out (request-id uint))
	(let (
			(request-details (try! (get-request-or-fail request-id))))
		(asserts! (> block-height (+ (get requested-at request-details) (get-request-revoke-grace-period))) err-revoke-grace-period)
		(asserts! (< (get claimed request-details) block-height) err-request-already-claimed)
		(asserts! (not (get revoked request-details)) err-request-already-revoked)
		(asserts! (not (get finalized request-details)) err-request-already-finalized)
		(as-contract (try! (contract-call? .btc-bridge-registry-v2-01 set-request request-id (merge request-details { revoked: true }))))
		(and (> (get fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get fee request-details) tx-sender (get requested-by request-details) none))))
		(and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? .token-abtc transfer-fixed (get gas-fee request-details) tx-sender (get requested-by request-details) none))))
		(as-contract (try! (contract-call? .token-abtc transfer-fixed (get amount-net request-details) tx-sender (get requested-by request-details) none)))
		(print { type: "revoke-peg-out", request-id: request-id })
		(ok true)))
(define-private (max (a uint) (b uint))
	(if (< a b) b a))
(define-private (min (a uint) (b uint))
	(if (< a b) a b))
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0) u0 (/ (* a ONE_8) b)))
(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))