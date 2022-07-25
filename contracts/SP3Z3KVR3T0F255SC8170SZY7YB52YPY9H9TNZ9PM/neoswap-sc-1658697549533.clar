(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant agent-2 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-3 'SP2846GM0SKSB3XJ57CVVWH4AX61YGXT0N2GKRZ6W)
(define-constant agent-4 'SP2JGQT966TBN0HTKS1BHNZY44GZ7NZV9JM6YEK9V)
(define-constant agent-5 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP)
(define-constant agent-6 'SP34S80102KYXHC0C5VC3GDPDVY3WFG1G5G507Y0K)
(define-constant agent-7 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0)
(define-constant agent-8 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B)
(define-constant agent-9 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-10 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-11 'SP1J5A19QEDEEY3342W53RVWRZCMMHKZCVX3FQ2Y7)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool true)
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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.worry-nft-music transfer u160 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2506 tx-sender agent-1)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u31900000 tx-sender agent-2)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1000000 tx-sender agent-3)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u810000 tx-sender agent-4)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u15050000 tx-sender agent-5)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u21432 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2596 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u8681 tx-sender agent-6)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u128 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2069 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u242 tx-sender agent-7)))
		(as-contract (stx-transfer? u3900000 tx-sender agent-7)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u256 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1092 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP2EK5VZQKRR1WYQ3F8MH86QDRDEHMC5WY6E3KA34.flavored-pops transfer u5 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6567 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u660 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6737 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP3M7N9Q9HDRM7RVP1Q26P0EE69358PZZAX4MD19Q.nft-nyc-exclusive transfer u834 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u15 tx-sender agent-10)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1120 tx-sender agent-11)))
	(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u87 tx-sender agent-11)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2770000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1092 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6567 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u660 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6737 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2EK5VZQKRR1WYQ3F8MH86QDRDEHMC5WY6E3KA34.flavored-pops transfer u5 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u8681 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP3M7N9Q9HDRM7RVP1Q26P0EE69358PZZAX4MD19Q.nft-nyc-exclusive transfer u834 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u10610000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1120 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.worry-nft-music transfer u160 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u15 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u256 tx-sender agent-7)))
	(var-set agent-7-status false))
	true)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u87 tx-sender agent-8)))
		(as-contract (stx-transfer? u4120000 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u128 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2069 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u21432 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u242 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2506 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2596 tx-sender agent-9)))
		(as-contract (stx-transfer? u38550000 tx-sender agent-9)))
	)
	(var-set agent-9-status false)
	)
	true
	)
	(if (is-eq (var-get agent-10-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1160000 tx-sender agent-10)))
	)
	(var-set agent-10-status false)
	)
	true
	)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u990000 tx-sender agent-11)))
	)
	(var-set agent-11-status false)
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
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1092 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6567 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u660 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u6737 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2EK5VZQKRR1WYQ3F8MH86QDRDEHMC5WY6E3KA34.flavored-pops transfer u5 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u8681 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3M7N9Q9HDRM7RVP1Q26P0EE69358PZZAX4MD19Q.nft-nyc-exclusive transfer u834 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u10610000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1120 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.worry-nft-music transfer u160 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u15 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u256 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u87 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u4120000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u128 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u2069 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u21432 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u242 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2506 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2596 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u38550000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u1160000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u990000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-11-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11))
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
