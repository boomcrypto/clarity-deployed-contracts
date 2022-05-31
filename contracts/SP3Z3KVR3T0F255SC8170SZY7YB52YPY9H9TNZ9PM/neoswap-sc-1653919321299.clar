(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1N4YMXJ23X5BEA7BQB4H9TTDDVSZBQWM2HRX6BX)
(define-constant agent-2 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant agent-3 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)
(define-constant agent-4 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D)
(define-constant agent-5 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-6 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
(define-constant agent-7 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-8 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864)
(define-constant agent-9 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
(define-constant agent-10 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-11 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X)
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


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status) (ok (var-get contract-status)))

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u8600000 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u1085 tx-sender agent-2)))
		(as-contract (stx-transfer? u83650005 tx-sender agent-2)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender agent-3)))
		(as-contract (stx-transfer? u4587920 tx-sender agent-3)))
	)
	(unwrap-panic (as-contract (contract-call? 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.htl transfer u131 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u107 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u107 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4791 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5321 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5588 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u6882 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7700 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh transfer u1119 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u9923 tx-sender agent-6)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.openxis transfer u142 tx-sender agent-7)))
		(as-contract (stx-transfer? u7450005 tx-sender agent-7)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u7214 tx-sender agent-8)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1089 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4601 tx-sender agent-9)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1271 tx-sender agent-10)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1920000 tx-sender agent-11)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u12080000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh transfer u1119 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4601 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4791 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5321 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5588 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u6882 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7700 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1271 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u13749995 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u1085 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1089 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.openxis transfer u142 tx-sender agent-5)))
		(as-contract (stx-transfer? u61960000 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u27897655 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u107 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.htl transfer u131 tx-sender agent-7)))
	(var-set agent-7-status false))
	true)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1902369 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u107 tx-sender agent-9)))
		(as-contract (stx-transfer? u8029996 tx-sender agent-9)))
	)
	(var-set agent-9-status false)
	)
	true
	)
	(if (is-eq (var-get agent-10-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u9923 tx-sender agent-10)))
		(as-contract (stx-transfer? u4747915 tx-sender agent-10)))
	)
	(var-set agent-10-status false)
	)
	true
	)
	(if (is-eq (var-get agent-11-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u7214 tx-sender agent-11)))
	(var-set agent-11-status false))
	true)

	(var-set contract-status u502)
	(ok true)
))

(define-public (confirm-and-escrow)
(begin
	(var-set flag false)
	(unwrap-panic (begin
		(if (is-eq tx-sender agent-1)
		(begin
		(asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2313 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh transfer u1119 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4601 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4791 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u5321 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer u5588 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u6882 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7700 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1271 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u13749995 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft transfer u1085 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1089 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.openxis transfer u142 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u61960000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u27897655 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u107 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W.htl transfer u131 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u1902369 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u107 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u8029996 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u9923 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u4747915 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u7214 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-11-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) true) (begin (unwrap-panic (release-escrow))) true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	(ok false))
))
