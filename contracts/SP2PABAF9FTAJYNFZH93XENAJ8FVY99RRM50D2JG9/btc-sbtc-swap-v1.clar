(define-constant ERR-OUT-OF-BOUNDS u1)
(define-constant ERR_VERIFICATION_FAILED (err u1))
(define-constant ERR_FAILED_TO_PARSE_TX (err u2))
(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_FORBIDDEN (err u4))
(define-constant ERR_TX_VALUE_TOO_SMALL (err u5))
(define-constant ERR_TX_NOT_FOR_RECEIVER (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_NO_STX_RECEIVER (err u8))
(define-constant ERR_BTC_TX_ALREADY_USED (err u9))
(define-constant ERR_NATIVE_FAILURE (err u99))

(define-constant expiry u100)
(define-map swaps uint {sats: uint, btc-receiver: (buff 40), amount: uint, stx-receiver: (optional principal), sbtc-sender: principal, when: uint, done: bool, premium: uint})
(define-data-var next-id uint u0)
;; map between accepted btc txs and swap id
(define-map submitted-btc-txs (buff 128) uint)

(define-private (sbtc-transfer (amount uint) (sender principal) (recipient principal))
  (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount sender recipient none))


(define-read-only (read-uint32 (ctx { txbuff: (buff 4096), index: uint}))
		(let ((data (get txbuff ctx))
					(base (get index ctx)))
				(ok {uint32: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u4)) (err ERR-OUT-OF-BOUNDS)) u4))),
						 ctx: { txbuff: data, index: (+ u4 base)}})))

(define-private (find-out (entry {scriptPubKey: (buff 128), value: (buff 8)}) (result {pubscriptkey: (buff 40), out: (optional {scriptPubKey: (buff 128), value: uint})}))
  (if (is-eq (get scriptPubKey entry) (get pubscriptkey result))
    (merge result {out: (some {scriptPubKey: (get scriptPubKey entry), value: (get uint32 (unwrap-panic (read-uint32 {txbuff: (get value entry), index: u0})))})})
    result))


(define-public (get-out-value (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}) (pubscriptkey (buff 40)))
    (ok (fold find-out (get outs tx) {pubscriptkey: pubscriptkey, out: none})))

;; create a swap between btc and stx
(define-public (create-swap (sats uint) (btc-receiver (buff 40)) (amount uint) (stx-receiver (optional principal)) (premium uint))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {sats: sats, btc-receiver: btc-receiver, amount: amount, stx-receiver: stx-receiver,
        sbtc-sender: tx-sender, when: burn-block-height, done: false, premium: premium}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (match (sbtc-transfer amount tx-sender (as-contract tx-sender))
      success (ok id)
      error (err (* error u1000)))))

(define-public (set-stx-receiver (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (premium (get premium swap)))
    (asserts! (is-none (get stx-receiver swap)) ERR_ALREADY_DONE)
    (and (> premium u0))
      (try! (sbtc-transfer premium tx-sender (get sbtc-sender swap)))
    (ok (map-set swaps id (merge swap {stx-receiver: (some tx-sender), when: burn-block-height})))))

;; any user can cancle the swap after the expiry period
;; sbtc-sender can cancle it before if the stx-receiver was not yet set
(define-public (cancel (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID)))
    (asserts!
      (or
        (and (is-none (get stx-receiver swap)) (is-eq tx-sender (get sbtc-sender swap)))
        (< (+ (get when swap) expiry) burn-block-height)) ERR_FORBIDDEN)
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)
    (map-set swaps id (merge swap {done: true}))
    (as-contract (sbtc-transfer (get amount swap) tx-sender (get sbtc-sender swap)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (height uint)
    (blockheader (buff 80))
    (tx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)})
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (tx-buff (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-helper concat-tx tx))
        (stx-receiver (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER)))
      (asserts! (is-eq tx-sender stx-receiver) ERR_FORBIDDEN)
      (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-tx-mined-compact
                height tx-buff blockheader proof )
        result
          (begin
            (asserts! (is-none (map-get? submitted-btc-txs result)) ERR_BTC_TX_ALREADY_USED)
            (asserts! (not (get done swap)) ERR_ALREADY_DONE)
            (match (get out (unwrap! (get-out-value tx (get btc-receiver swap)) ERR_NATIVE_FAILURE))
              out (if (>= (get value out) (get sats swap))
                (begin
                      (map-set swaps id (merge swap {done: true}))
                      (map-set submitted-btc-txs result id)
                      (as-contract (stx-transfer? (get amount swap) tx-sender (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))))
                ERR_TX_VALUE_TOO_SMALL)
            ERR_TX_NOT_FOR_RECEIVER))
        error (err (* error u1000)))))


(define-public (submit-swap-segwit
    (id uint)
    (height uint)
    (wtx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)})
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 1024))
    (cproof (list 14 (buff 32))))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (tx-buff (contract-call? .bitcoin-helper-wtx-v1 concat-wtx wtx witness-data)))
      (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-segwit-tx-mined-compact
                height tx-buff header tx-index tree-depth wproof witness-merkle-root witness-reserved-value ctx cproof )
        result
          (begin
            (asserts! (is-none (map-get? submitted-btc-txs result)) ERR_BTC_TX_ALREADY_USED)
            (asserts! (not (get done swap)) ERR_ALREADY_DONE)
            (match (get out (unwrap! (get-out-value wtx (get btc-receiver swap)) ERR_NATIVE_FAILURE))
              out (if (>= (get value out) (get sats swap))
                (begin
                      (map-set swaps id (merge swap {done: true}))
                      (map-set submitted-btc-txs result id)
                      (as-contract (stx-transfer? (get amount swap) tx-sender (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))))
                ERR_TX_VALUE_TOO_SMALL)
            ERR_TX_NOT_FOR_RECEIVER))
        error (err (* error u1000)))))