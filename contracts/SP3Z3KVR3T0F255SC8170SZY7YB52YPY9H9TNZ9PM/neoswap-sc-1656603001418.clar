(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant agent-2 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant agent-3 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63)
(define-constant agent-4 'SP2BTKF13RC0Y36K3D41RJT6PA3A662BXSM63JSJ2)
(define-constant agent-5 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N)
(define-constant agent-6 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0)
(define-constant agent-7 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B)
(define-constant agent-8 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF)
(define-constant agent-9 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-10 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-11 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
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
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks transfer u2093 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender agent-1)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u9000000 tx-sender agent-2)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u11 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u123 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u30 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPVMRAH27D4TKMG42NQX2F1PNK5AT922ZNE6SDST.fluid-marble transfer u4 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u4 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u65 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender agent-4)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u167 tx-sender agent-5)))
		(as-contract (stx-transfer? u15900000 tx-sender agent-5)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u3000000 tx-sender agent-6)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u2 tx-sender agent-7)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u16 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls transfer u204 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.oriental-beauty transfer u8 tx-sender agent-8)))
		(as-contract (stx-transfer? u13500000 tx-sender agent-8)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u171 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u289 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u325 tx-sender agent-9)))
		(as-contract (stx-transfer? u8240000 tx-sender agent-9)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u7150000 tx-sender agent-10)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12388 tx-sender agent-11)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u62 tx-sender agent-11)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5680000 tx-sender agent-0)))
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
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u62 tx-sender agent-1)))
		(as-contract (stx-transfer? u31380000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u11 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u123 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12388 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u16 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls transfer u204 tx-sender agent-3)))
		(as-contract (stx-transfer? u9210000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u530000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u30 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u4 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.oriental-beauty transfer u8 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u2 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPVMRAH27D4TKMG42NQX2F1PNK5AT922ZNE6SDST.fluid-marble transfer u4 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u11900000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks transfer u2093 tx-sender agent-8)))
	(var-set agent-8-status false))
	true)
	(if (is-eq (var-get agent-9-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u167 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender agent-9)))
	(var-set agent-9-status false))
	true)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u171 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u289 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u325 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u65 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u9450000 tx-sender agent-11)))
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
		(if (is-eq tx-sender agent-1)
		(begin
		(asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u62 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u31380000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u11 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u123 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u12388 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u16 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls transfer u204 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u9210000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u530000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u30 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.oriental-beauty transfer u8 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u2 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPVMRAH27D4TKMG42NQX2F1PNK5AT922ZNE6SDST.fluid-marble transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u11900000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks transfer u2093 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u167 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u171 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u289 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u325 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u65 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u9450000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
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
