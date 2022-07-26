(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant agent-2 'SP15B9DHAWWBDNNAF7B63T1TXJYQMB3FQTGWMQRGG)
(define-constant agent-3 'SP1CSP7FJR4TAZADS93NCAYMP5BXW77QDB42Y9SYC)
(define-constant agent-4 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR)
(define-constant agent-5 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-6 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-7 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-8 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB)
(define-constant agent-9 'SP2BTKF13RC0Y36K3D41RJT6PA3A662BXSM63JSJ2)
(define-constant agent-10 'SP2H6HVZK6X3Z8F4PKF284AZJR6FH4H9J4W6KVV8T)
(define-constant agent-11 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP)
(define-constant agent-12 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
(define-constant agent-13 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN)
(define-constant agent-14 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-15 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX)
(define-constant agent-16 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2)
(define-constant agent-17 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
(define-constant agent-18 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-19 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D)
(define-constant agent-20 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
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
(define-data-var agent-13-status bool false)
(define-data-var agent-14-status bool false)
(define-data-var agent-15-status bool false)
(define-data-var agent-16-status bool false)
(define-data-var agent-17-status bool false)
(define-data-var agent-18-status bool false)
(define-data-var agent-19-status bool false)
(define-data-var agent-20-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status) (var-get agent-20-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status) (var-get agent-20-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u9 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2382 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2595 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E.presale-90stx transfer u413 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u1518 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2240 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4683 tx-sender agent-4)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u750000 tx-sender agent-5)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u49 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3724 tx-sender agent-8)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u10500000 tx-sender agent-9)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u6800000 tx-sender agent-10)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3503 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3959 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u7869 tx-sender agent-11)))
		(as-contract (stx-transfer? u16425901 tx-sender agent-11)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u10 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2673 tx-sender agent-12)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u22 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u32 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u358 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u4 tx-sender agent-13)))
		(as-contract (stx-transfer? u158500000 tx-sender agent-13)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u9038 tx-sender agent-14)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender agent-15)))
		(as-contract (stx-transfer? u7220000 tx-sender agent-15)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2436 tx-sender agent-16)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u25335 tx-sender agent-16)))
	(unwrap-panic (as-contract (contract-call? 'SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV.surealnftstx transfer u10 tx-sender agent-17)))
	(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12500 tx-sender agent-17)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1800000 tx-sender agent-18)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4532 tx-sender agent-19)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3046 tx-sender agent-20)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u19710000 tx-sender agent-0)))
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
		(as-contract (stx-transfer? u31500000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u7150000 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u530000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u4 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4532 tx-sender agent-4)))
		(as-contract (stx-transfer? u3400000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2436 tx-sender agent-6)))
		(as-contract (stx-transfer? u37650000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3503 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3959 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u49 tx-sender agent-7)))
		(as-contract (stx-transfer? u46160000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2630000 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u32 tx-sender agent-9)))
	(var-set agent-9-status false))
	true)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u9038 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E.presale-90stx transfer u413 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u1518 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2240 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2673 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u358 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u25335 tx-sender agent-11)))
	(var-set agent-11-status false))
	true)
	(if (is-eq (var-get agent-12-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u7869 tx-sender agent-12)))
		(as-contract (stx-transfer? u38140000 tx-sender agent-12)))
	)
	(var-set agent-12-status false)
	)
	true
	)
	(if (is-eq (var-get agent-13-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u10 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u9 tx-sender agent-13)))
	(var-set agent-13-status false))
	true)
	(if (is-eq (var-get agent-14-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender agent-14)))
		(as-contract (stx-transfer? u5140000 tx-sender agent-14)))
	)
	(var-set agent-14-status false)
	)
	true
	)
	(if (is-eq (var-get agent-15-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12500 tx-sender agent-15)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2595 tx-sender agent-15)))
	(var-set agent-15-status false))
	true)
	(if (is-eq (var-get agent-16-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u22 tx-sender agent-16)))
		(as-contract (stx-transfer? u37605901 tx-sender agent-16)))
	)
	(var-set agent-16-status false)
	)
	true
	)
	(if (is-eq (var-get agent-17-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3046 tx-sender agent-17)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3724 tx-sender agent-17)))
		(as-contract (stx-transfer? u7600000 tx-sender agent-17)))
	)
	(var-set agent-17-status false)
	)
	true
	)
	(if (is-eq (var-get agent-18-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2382 tx-sender agent-18)))
	(var-set agent-18-status false))
	true)
	(if (is-eq (var-get agent-19-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV.surealnftstx transfer u10 tx-sender agent-19)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4683 tx-sender agent-19)))
		(as-contract (stx-transfer? u1570000 tx-sender agent-19)))
	)
	(var-set agent-19-status false)
	)
	true
	)
	(if (is-eq (var-get agent-20-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2630000 tx-sender agent-20)))
	)
	(var-set agent-20-status false)
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
		(asserts! (is-ok (stx-transfer? u31500000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u7150000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u530000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4532 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u3400000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2436 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u37650000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3503 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3959 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u49 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u46160000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u2630000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u32 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u9038 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E.presale-90stx transfer u413 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u1518 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2240 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u2673 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u358 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u25335 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u7869 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u38140000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-12-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-13)
		(begin
		(asserts! (is-eq (var-get agent-13-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u10 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u9 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-13-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-14)
		(begin
		(asserts! (is-eq (var-get agent-14-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u5140000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-14-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-15)
		(begin
		(asserts! (is-eq (var-get agent-15-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12500 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2595 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-15-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-16)
		(begin
		(asserts! (is-eq (var-get agent-16-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u22 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u37605901 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-16-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-17)
		(begin
		(asserts! (is-eq (var-get agent-17-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3046 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3724 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u7600000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-17-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-18)
		(begin
		(asserts! (is-eq (var-get agent-18-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2382 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-18-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-19)
		(begin
		(asserts! (is-eq (var-get agent-19-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV.surealnftstx transfer u10 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4683 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u1570000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-19-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-20)
		(begin
		(asserts! (is-eq (var-get agent-20-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u2630000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-20-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status) (var-get agent-20-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12) (is-eq tx-sender agent-13) (is-eq tx-sender agent-14) (is-eq tx-sender agent-15) (is-eq tx-sender agent-16) (is-eq tx-sender agent-17) (is-eq tx-sender agent-18) (is-eq tx-sender agent-19) (is-eq tx-sender agent-20))
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
