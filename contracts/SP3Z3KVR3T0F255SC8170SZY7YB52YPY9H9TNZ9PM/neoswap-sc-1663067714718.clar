(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-2 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-3 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant agent-4 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
(define-constant agent-5 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX)
(define-constant agent-6 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-7 'SPVDF4YJER5QZD2PEY7WEDY6ZX6EQ36V1WN5XME)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)
(define-data-var agent-7-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2203500 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u27000000 tx-sender agent-2)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u161 tx-sender agent-3)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1473 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2291 tx-sender agent-4)))
		(as-contract (stx-transfer? u36807000 tx-sender agent-4)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2W58YQZEAC870M2MKE6QEKS1DPG0RMZZ2BGXSM4.tickets-90stx-mini-raffle-26 transfer u85 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons transfer u567 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-Monkeys-NFTs transfer u11 tx-sender agent-5)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2485 tx-sender agent-6)))
		(as-contract (stx-transfer? u3118124 tx-sender agent-6)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4041 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3512 tx-sender agent-7)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u3696752 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons transfer u567 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u161 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2W58YQZEAC870M2MKE6QEKS1DPG0RMZZ2BGXSM4.tickets-90stx-mini-raffle-26 transfer u85 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u26250000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-Monkeys-NFTs transfer u11 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2485 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u46416500 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1473 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2291 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3512 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4041 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u158876 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)

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
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons transfer u567 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u161 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2W58YQZEAC870M2MKE6QEKS1DPG0RMZZ2BGXSM4.tickets-90stx-mini-raffle-26 transfer u85 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u26250000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-Monkeys-NFTs transfer u11 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2485 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u46416500 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1473 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2291 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3512 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4041 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u158876 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7))
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
