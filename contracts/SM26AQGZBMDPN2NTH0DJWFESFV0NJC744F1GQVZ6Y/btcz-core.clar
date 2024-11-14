(define-constant err-unauthorized (err u6000))
(define-constant err-paused (err u6001))
(define-constant err-peg-in-address-not-found (err u6002))
(define-constant err-invalid-amount (err u6003))
(define-constant err-invalid-tx (err u6004))
(define-constant err-already-sent (err u6005))
(define-constant err-bitcoin-tx-not-mined (err u6006))
(define-constant err-invalid-input (err u6007))
(define-constant err-withdrawal-does-not-exist (err u6008))
(define-constant err-output-index-out-of-bounds (err u6009))
(define-constant err-order-index-out-of-bounds (err u6010))
(define-constant err-invalid-order-script (err u6011))
(define-constant err-reading-varint (err u6012))

(define-constant success (ok true))

(define-constant one-12 u1000000000000)
(define-constant sats-to-precision u10000)

(define-data-var contract-owner principal tx-sender)

(define-public (deposit
	(tx (buff 4096))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint)
	(order-idx uint))
	(let (
		(common-check (try! (verify-mined tx block proof)))
		(parsed-tx (try! (extract-tx-ins-outs tx)))
		(output (unwrap! (element-at (get outs parsed-tx) output-idx) err-output-index-out-of-bounds))
		(amount (get value output))
		(peg-in-address (get scriptPubKey output))
		(order-script (get scriptPubKey (unwrap! (element-at? (get outs parsed-tx) order-idx) err-order-index-out-of-bounds)))
		(fee (mul-sats-with-ratio-to-sats amount (contract-call? .peg-data get-peg-in-fee)))
		(amount-net (- amount fee))
		(recipient (try! (decode-order-0 order-script)))
		(btc-to-btcz-ratio (get-btc-to-btcz-ratio))
		(btcz-to-receive (div-sats-with-ratio amount-net btc-to-btcz-ratio))
	)
		(asserts! (not (contract-call? .peg-data is-peg-in-paused)) err-paused)
		(asserts! (not (contract-call? .btc-registry get-peg-in-sent tx output-idx)) err-already-sent)
		(asserts! (contract-call? .btc-registry is-peg-in-address-approved peg-in-address) err-peg-in-address-not-found)
		(asserts! (> amount-net u0) err-invalid-amount)

		(try! (set-total-btc (+ (get-total-btc) amount-net)))

		(try! (contract-call? .btc-registry set-peg-in-sent tx output-idx true))
		(try! (contract-call? .token-btc mint btcz-to-receive recipient))

		(print { action: "deposit", data: { tx-id: (get-txid tx), tx: tx, btcz-to-receive: btcz-to-receive, fee: fee, amount-net: amount-net, recipient: recipient, peg-in-address: peg-in-address, amount: amount } })
		(ok { order-script: order-script })
	)
)

(define-public (init-withdraw
	(peg-out-address (buff 128))
	(btcz-amount uint)
	)
	(let (
		(sender contract-caller)
		(redeemable-btc (get-redeemable-btc-by-amount btcz-amount))
		(fee (mul-sats-with-ratio-to-sats redeemable-btc (get-peg-out-fee)))
		(gas-fee (get-peg-out-gas-fee))
		(check-amount (asserts! (> redeemable-btc (+ fee gas-fee)) err-invalid-amount))
		(amount-net (- redeemable-btc fee gas-fee))
		(next-nonce (get-next-withdrawal-nonce))
		(withdraw-data {
			btc-amount: amount-net,
			btcz-amount: btcz-amount,
			peg-out-address: peg-out-address,
			requested-by: sender,
			fee: fee,
			gas-fee: gas-fee,
			finalized: false,
			requested-at: block-height,
			requested-at-burn-height: burn-block-height,
		})
	)
		(asserts! (not (contract-call? .peg-data is-peg-out-paused)) err-paused)
		(try! (contract-call? .token-btc burn btcz-amount sender))
		(try! (set-total-btc (- (get-total-btc) redeemable-btc)))

		(try! (set-withdrawal next-nonce withdraw-data))
		(try! (contract-call? .stacking-data set-withdrawal-nonce next-nonce))

		(print { action: "init-withdraw", data: { withdraw-data: withdraw-data, nonce: next-nonce } })
		(ok next-nonce)
	)
)

;; called by protocol
(define-public (finalize-withdraw (withdrawal-id uint))
	(let (
		(withdraw-data (unwrap! (contract-call? .stacking-data get-withdrawal withdrawal-id) err-withdrawal-does-not-exist))
	)
		(try! (is-contract-owner))
		(asserts! (not (get finalized withdraw-data)) err-already-sent)

		(try! (set-withdrawal withdrawal-id (merge withdraw-data { finalized: true })))
		(print { action: "finalize-withdraw", data: { withdraw-data: withdraw-data, withdrawal-id: withdrawal-id, finalize-height: burn-block-height } })
		success
	)
)

(define-public (add-rewards (btc-amount uint))
	(let (
		(new-total-btc (+ (get-total-btc) btc-amount))
	)
		(try! (is-contract-owner))

		(try! (set-total-btc new-total-btc))
		(print { action: "add-rewards", data: { new-total-btc: new-total-btc, btc-amount: btc-amount } })
		success
	)
)

(define-read-only (get-btc-to-btcz-ratio)
	(let (
		(btc-amount (get-total-btc))
		(btcz-supply (unwrap-panic (contract-call? .token-btc get-total-supply)))
	)
		(if (is-eq btcz-supply u0)
			one-12
			(div-sats-with-ratio btc-amount btcz-supply)
		)
	)
)

(define-read-only (get-next-withdrawal-nonce)
	(+ (contract-call? .stacking-data get-withdrawal-nonce) u1))

(define-read-only (get-redeemable-btc-by-amount (btcz-amount uint))
	(mul-btcz-with-ratio-to-sats btcz-amount (get-btc-to-btcz-ratio)))

(define-read-only (get-redeemable-btc-by-amount-after-fees (btcz-amount uint))
	(let (
		(redeemable-btc (get-redeemable-btc-by-amount btcz-amount))
		(fee (mul-sats-with-ratio-to-sats redeemable-btc (get-peg-out-fee)))
		(gas-fee (get-peg-out-gas-fee))
		(check-amount (asserts! (> redeemable-btc (+ fee gas-fee)) err-invalid-amount))
		(amount-net (- redeemable-btc fee gas-fee))
	)
		(ok amount-net)
	)
)

(define-read-only (get-redeemable-btc (user principal))
	(get-redeemable-btc-by-amount (unwrap-panic (contract-call? .token-btc get-balance user)))
)

(define-read-only (get-redeemable-btc-after-fees (user principal))
	(get-redeemable-btc-by-amount-after-fees (unwrap-panic (contract-call? .token-btc get-balance user)))
)

(define-read-only (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) contract-caller) err-unauthorized)))

(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(print { action: "set-contract-owner", data: { new-contract-owner: new-contract-owner } })
		(ok (var-set contract-owner new-contract-owner))))

(define-read-only (mul-sats-with-ratio (sats uint) (ratio uint))
	(/ (* (* sats sats-to-precision) ratio) one-12))

(define-read-only (mul-sats-with-ratio-to-sats (sats uint) (ratio uint))
	(/ (* sats ratio) one-12))

(define-read-only (mul-btcz-with-ratio-to-sats (btcz uint) (ratio uint))
	(/ (/ (* btcz ratio) one-12) sats-to-precision))

(define-read-only (div-sats-with-ratio (sats uint) (ratio uint))
	(/ (* (* sats sats-to-precision) one-12) ratio))

(define-read-only (div-sats-with-ratio-to-sats (sats uint) (ratio uint))
	(/ (* sats one-12) ratio))

;; stacking data
(define-read-only (get-peg-out-fee)
	(contract-call? .peg-data get-peg-out-fee))

(define-read-only (get-peg-out-gas-fee)
	(contract-call? .peg-data get-peg-out-gas-fee))

;; btc data
(define-read-only (get-total-btc)
	(contract-call? .stacking-data get-total-btc))

(define-private (set-total-btc (total-btc uint))
	(contract-call? .stacking-data set-total-btc total-btc))

(define-private (set-withdrawal
	(withdrawal-id uint)
	(new-withdrawal {
		btc-amount: uint,
		btcz-amount: uint,
		peg-out-address: (buff 128),
		requested-by: principal,
		fee: uint,
		gas-fee: uint,
		finalized: bool,
		requested-at: uint,
		requested-at-burn-height: uint
	}))
	(contract-call? .stacking-data set-withdrawal withdrawal-id new-withdrawal)
)

;; bitcoin parsing functions
(define-read-only (extract-tx-ins-outs (tx (buff 4096)))
	(if (try! (contract-call? .clarity-bitcoin-v1-02 is-segwit-tx tx))
		(let (
			(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-02 parse-wtx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
		(let (
			(parsed-tx (unwrap! (contract-call? .clarity-bitcoin-v1-02 parse-tx tx) err-invalid-tx)))
			(ok { ins: (get ins parsed-tx), outs: (get outs parsed-tx) }))
	))

(define-read-only (get-txid (tx (buff 4096)))
	(if (try! (contract-call? .clarity-bitcoin-v1-02 is-segwit-tx tx))
		(ok (contract-call? .clarity-bitcoin-v1-02 get-segwit-txid tx))
		(ok (contract-call? .clarity-bitcoin-v1-02 get-txid tx))
	))

(define-read-only (verify-mined (tx (buff 4096)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(if is-in-mainnet
		(let (
			(response (if (try! (contract-call? .clarity-bitcoin-v1-02 is-segwit-tx tx))
				(contract-call? .clarity-bitcoin-v1-02 was-segwit-tx-mined? block tx proof)
				(contract-call? .clarity-bitcoin-v1-02 was-tx-mined? block tx proof))))
			(if (or (is-err response) (not (unwrap-panic response)))
				err-bitcoin-tx-not-mined
				success
			))
		success)) ;; if not mainnet, assume verified

;; data output parse helpers
(define-read-only (decode-order-0 (order-script (buff 128)))
	(let (
		(op-code (unwrap! (slice? order-script u1 u2) err-invalid-order-script)))
		(ok (unwrap! (from-consensus-buff? principal (unwrap! (slice? order-script (if (< op-code 0x4c) u2 u3) (len order-script)) err-reading-varint)) err-invalid-input))))
