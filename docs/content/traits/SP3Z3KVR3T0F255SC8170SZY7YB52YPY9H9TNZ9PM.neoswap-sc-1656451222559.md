---
title: "Trait neoswap-sc-1656451222559"
draft: true
---
```
(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-2 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-3 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant agent-4 'SP25J2EJ4GNE42860RAZ2DF18X5JNKVMC0WRGV65R)
(define-constant agent-5 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-6 'SP2BTKF13RC0Y36K3D41RJT6PA3A662BXSM63JSJ2)
(define-constant agent-7 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
(define-constant agent-8 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N)
(define-constant agent-9 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B)
(define-constant agent-10 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-11 'SPERQB4H1J2RMFH105766940WT6K3R6RE6ZKMT9A)
(define-constant agent-12 'SPKKH2MBR4FA5XWTTCE3NJZ85EDTBS283B9S2BFR)
(define-constant agent-13 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D)
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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u497 tx-sender agent-1)))
		(as-contract (stx-transfer? u60530000 tx-sender agent-1)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u1044 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u84 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.bitmetaverse transfer u18 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u44 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.magic-ape-school transfer u169 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u332 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights transfer u77 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u1743 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPERQB4H1J2RMFH105766940WT6K3R6RE6ZKMT9A.mr-wagmis-adventure transfer u22 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u31 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u3 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u426 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u479 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2VDFN6HACT6P551FN5ED79VK6JSEM5ACDMY308V.flowing-water transfer u4 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u5 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2675 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2340 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5556 tx-sender agent-7)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u27280000 tx-sender agent-8)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u483 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender agent-10)))
	(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u244 tx-sender agent-10)))
	(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender agent-10)))
	(unwrap-panic (as-contract (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u20 tx-sender agent-11)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u319 tx-sender agent-11)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1090 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles transfer u25 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u354 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u306 tx-sender agent-13)))
	(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u312 tx-sender agent-13)))
	(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5334 tx-sender agent-13)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u5410000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u1044 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.magic-ape-school transfer u169 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u1743 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u244 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u319 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u426 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u479 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights transfer u77 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u84 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u497 tx-sender agent-2)))
		(as-contract (stx-transfer? u12490000 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u900000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5556 tx-sender agent-4)))
		(as-contract (stx-transfer? u5940000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2340 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2675 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5334 tx-sender agent-5)))
		(as-contract (stx-transfer? u53620000 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u332 tx-sender agent-6)))
		(as-contract (stx-transfer? u800000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1480000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.bitmetaverse transfer u18 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u20 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u31 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u3 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u483 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u5 tx-sender agent-8)))
	(var-set agent-8-status false))
	true)
	(if (is-eq (var-get agent-9-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u44 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles transfer u25 tx-sender agent-9)))
		(as-contract (stx-transfer? u240000 tx-sender agent-9)))
	)
	(var-set agent-9-status false)
	)
	true
	)
	(if (is-eq (var-get agent-10-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1090 tx-sender agent-10)))
		(as-contract (stx-transfer? u270000 tx-sender agent-10)))
	)
	(var-set agent-10-status false)
	)
	true
	)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPERQB4H1J2RMFH105766940WT6K3R6RE6ZKMT9A.mr-wagmis-adventure transfer u22 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u354 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u306 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u312 tx-sender agent-11)))
		(as-contract (stx-transfer? u10000000 tx-sender agent-11)))
	)
	(var-set agent-11-status false)
	)
	true
	)
	(if (is-eq (var-get agent-12-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u3870000 tx-sender agent-12)))
	)
	(var-set agent-12-status false)
	)
	true
	)
	(if (is-eq (var-get agent-13-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2VDFN6HACT6P551FN5ED79VK6JSEM5ACDMY308V.flowing-water transfer u4 tx-sender agent-13)))
		(as-contract (stx-transfer? u3610000 tx-sender agent-13)))
	)
	(var-set agent-13-status false)
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
		(asserts! (is-ok (contract-call? 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.SDGU-stackspunks transfer u1044 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.magic-ape-school transfer u169 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u1743 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u233 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u244 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPXM7A1WWQPS3R504SNGXERRHEKHZEGQE40DJGJY.stockings transfer u248 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u319 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u426 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u479 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights transfer u77 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u84 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u497 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u12490000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u900000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5556 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u5940000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2340 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2675 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5334 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u53620000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3.king-katz transfer u332 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u800000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u1480000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.bitmetaverse transfer u18 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3PN1GRGNNV6KKS47XN34TJZ6MGBGC40G7KFEGMW.cool-ape transfer u20 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-girl transfer u31 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u3 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u483 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP20F15MKEWE4C2GACJK6EJS5ERYQKVCJTV84RYC0.free-and-abstract transfer u5 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.bitbombs-v2 transfer u44 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles transfer u25 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u240000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1136 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1126 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1090 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u270000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPERQB4H1J2RMFH105766940WT6K3R6RE6ZKMT9A.mr-wagmis-adventure transfer u22 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u354 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u306 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u312 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u10000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u3870000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-12-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-13)
		(begin
		(asserts! (is-eq (var-get agent-13-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2VDFN6HACT6P551FN5ED79VK6JSEM5ACDMY308V.flowing-water transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u3610000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-13-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12) (is-eq tx-sender agent-13))
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

```