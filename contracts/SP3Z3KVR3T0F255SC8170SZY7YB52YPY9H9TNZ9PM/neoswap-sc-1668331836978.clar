(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4)
(define-constant agent-2 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87)
(define-constant agent-3 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant agent-4 'SP2A0AHSWNYPAS1KRNMEFQMV8WQ2KZRRW8DZC8Z3K)
(define-constant agent-5 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX)
(define-constant agent-6 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant agent-7 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV)
(define-constant agent-8 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-9 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR)
(define-constant agent-10 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35)
(define-constant agent-11 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant agent-12 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)
(define-data-var agent-7-status bool false)
(define-data-var agent-8-status bool false)
(define-data-var agent-9-status bool false)
(define-data-var agent-10-status bool false)
(define-data-var agent-11-status bool false)
(define-data-var agent-12-status bool false)


(define-data-var flag bool false)

(define-data-var deal bool false)

(define-constant deal-closed (err u300))
(define-constant cannot-escrow-nft (err u301))
(define-constant cannot-escrow-stx (err u302))
(define-constant sender-already-confirmed (err u303))
(define-constant non-tradable-agent (err u304))
(define-constant release-escrow-failed (err u305))
(define-constant deal-cancelled (err u306))
(define-constant escrow-not-ready (err u307))


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished ; u504 - Escrow Ready
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status) (ok (var-get contract-status)))

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5249 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3075 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u2620 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2360 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2401 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2399 tx-sender agent-2)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5362500 tx-sender agent-3)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u200000000 tx-sender agent-4)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u27000000 tx-sender agent-5)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u4400 tx-sender agent-6)))
		(as-contract (stx-transfer? u95466250 tx-sender agent-6)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u269 tx-sender agent-7)))
		(as-contract (stx-transfer? u54850000 tx-sender agent-7)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u238 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3818 tx-sender agent-9)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u26000000 tx-sender agent-10)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u236 tx-sender agent-11)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u268 tx-sender agent-12)))
		(as-contract (stx-transfer? u32750000 tx-sender agent-12)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u34996250 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u199618750 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u4400 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u268 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u269 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5249 tx-sender agent-2)))
		(as-contract (stx-transfer? u33868750 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u236 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3818 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2360 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u2620 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3075 tx-sender agent-7)))
	(var-set agent-7-status false))
	true)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u27300000 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u210000000 tx-sender agent-9)))
	)
	(var-set agent-9-status false)
	)
	true
	)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u238 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5637500 tx-sender agent-11)))
	)
	(var-set agent-11-status false)
	)
	true
	)
	(if (is-eq (var-get agent-12-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2399 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2401 tx-sender agent-12)))
	(var-set agent-12-status false))
	true)

	(var-set contract-status u502)
	(ok true)
))

(define-public (confirm-and-escrow)
(begin
	(asserts! (not (is-eq (var-get contract-status) u503)) deal-closed)
	(asserts! (not (is-eq (var-get contract-status) u502)) deal-cancelled)
	(var-set flag false)
	(unwrap-panic (begin
		(if (is-eq tx-sender agent-1)
		(begin
		(asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u199618750 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u4400 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u268 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u269 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5249 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u33868750 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u236 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3818 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2360 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u2620 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u3075 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u27300000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u210000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u238 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u5637500 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2399 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2401 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-12-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	non-tradable-agent)
))

(define-public (complete-neoswap)
(begin
	(asserts! (not (is-eq (var-get contract-status) u501)) escrow-not-ready)
	(asserts! (not (is-eq (var-get contract-status) u503)) deal-closed)
	(asserts! (not (is-eq (var-get contract-status) u502)) deal-cancelled)
	(unwrap-panic (release-escrow))
	(ok true)
))
