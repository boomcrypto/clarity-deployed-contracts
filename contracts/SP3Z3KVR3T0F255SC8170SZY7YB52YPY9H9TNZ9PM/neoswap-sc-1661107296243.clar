(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1J5A19QEDEEY3342W53RVWRZCMMHKZCVX3FQ2Y7)
(define-constant agent-2 'SP1N41GX5EVPR9SD7JM8T1165YP5G279JE9V9XFH0)
(define-constant agent-3 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant agent-4 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant agent-5 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant agent-6 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u47600000 tx-sender agent-1)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u13 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u28 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u2 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u106 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2656 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u27 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3133 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u46 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u765 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.virtual-tulips transfer u84 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1731 tx-sender agent-4)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u4000000 tx-sender agent-5)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u134 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u135 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u60 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u92 tx-sender agent-6)))
		(as-contract (stx-transfer? u79870000 tx-sender agent-6)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u10190000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u134 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u135 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u27 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u46 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u60 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3133 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2656 tx-sender agent-2)))
		(as-contract (stx-transfer? u8900000 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender agent-3)))
		(as-contract (stx-transfer? u127510000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5250000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u92 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u106 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u13 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u28 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u2 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.virtual-tulips transfer u84 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u765 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1731 tx-sender agent-6)))
	(var-set agent-6-status false))
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
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u134 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u135 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u27 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u46 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3Z3GK22JHV7YYE479YVFAFQTX2XFSDJRPXG8GXF.posh-penguins transfer u60 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3133 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2656 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u8900000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u739 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u127510000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u5250000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u92 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u106 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u13 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u28 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u2 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.virtual-tulips transfer u84 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u765 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1731 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6))
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
