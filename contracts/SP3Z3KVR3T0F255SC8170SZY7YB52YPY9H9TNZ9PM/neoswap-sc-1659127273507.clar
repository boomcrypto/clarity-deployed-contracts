(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant agent-2 'SP15B9DHAWWBDNNAF7B63T1TXJYQMB3FQTGWMQRGG)
(define-constant agent-3 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-4 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant agent-5 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant agent-6 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6)
(define-constant agent-7 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-8 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ)
(define-constant agent-9 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-10 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2)
(define-constant agent-11 'SP5MJB2231XSTW82MEX7S7HRHAAM918CVJETR0K4)
(define-constant agent-12 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant agent-13 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ)
(define-constant agent-14 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0)
(define-constant agent-15 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant agent-16 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-constant agent-17 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G)
(define-constant agent-18 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(define-constant agent-19 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC)
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
(define-data-var agent-15-status bool true)
(define-data-var agent-16-status bool false)
(define-data-var agent-17-status bool false)
(define-data-var agent-18-status bool false)
(define-data-var agent-19-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1729 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u242 tx-sender agent-1)))
		(as-contract (stx-transfer? u290000 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u12500000 tx-sender agent-2)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u14400000 tx-sender agent-3)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC.seven-bitcoin-days transfer u1 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.punk-donuts transfer u284 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u4 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u112 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-expansion-nft transfer u59931 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales transfer u71 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP3J1ZP3R4MCMZ91KW1BFZWYKHEG553PX42C8H56E.sicko-sloths transfer u108 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.where-is-dr-suss-vol-i-san-miguel transfer u19 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10.airdropticket transfer u176 tx-sender agent-8)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1614 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u4272 tx-sender agent-9)))
		(as-contract (stx-transfer? u5660000 tx-sender agent-9)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u24000000 tx-sender agent-10)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2621 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2965 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3013 tx-sender agent-11)))
		(as-contract (stx-transfer? u236150000 tx-sender agent-11)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u8550000 tx-sender agent-12)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u10000000 tx-sender agent-13)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.satoshi-city transfer u2 tx-sender agent-14)))
	(unwrap-panic (as-contract (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.luxury-jewellery transfer u1 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.poseidon-awakening transfer u1 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.collection-one-life-vol-2 transfer u13 tx-sender agent-16)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1811 tx-sender agent-16)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u22 tx-sender agent-16)))
	(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.block-nights-i transfer u21 tx-sender agent-17)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1768 tx-sender agent-18)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u945 tx-sender agent-18)))
	(unwrap-panic (as-contract (contract-call? 'SP3D0WY16NZXVTF8Q8849Y2R93GNWJ162RZF1D1VQ.poker-faces transfer u349 tx-sender agent-19)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u74 tx-sender agent-19)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u21130000 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1811 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.satoshi-city transfer u2 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u4 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1614 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.punk-donuts transfer u284 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u4272 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales transfer u71 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-expansion-nft transfer u59931 tx-sender agent-4)))
		(as-contract (stx-transfer? u20990000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u112 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10.airdropticket transfer u176 tx-sender agent-5)))
		(as-contract (stx-transfer? u2100000 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u945 tx-sender agent-6)))
		(as-contract (stx-transfer? u14690000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u22 tx-sender agent-7)))
		(as-contract (stx-transfer? u100000000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u1680000 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.luxury-jewellery transfer u1 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.poseidon-awakening transfer u1 tx-sender agent-9)))
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.collection-one-life-vol-2 transfer u13 tx-sender agent-9)))
	(var-set agent-9-status false))
	true)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1768 tx-sender agent-10)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1729 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.block-nights-i transfer u21 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.where-is-dr-suss-vol-i-san-miguel transfer u19 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP3D0WY16NZXVTF8Q8849Y2R93GNWJ162RZF1D1VQ.poker-faces transfer u349 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SP3J1ZP3R4MCMZ91KW1BFZWYKHEG553PX42C8H56E.sicko-sloths transfer u108 tx-sender agent-11)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u242 tx-sender agent-11)))
	(var-set agent-11-status false))
	true)
	(if (is-eq (var-get agent-12-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2621 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2965 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3013 tx-sender agent-12)))
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u74 tx-sender agent-12)))
	(var-set agent-12-status false))
	true)
	(if (is-eq (var-get agent-13-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC.seven-bitcoin-days transfer u1 tx-sender agent-13)))
	(var-set agent-13-status false))
	true)
	(if (is-eq (var-get agent-14-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u10500000 tx-sender agent-14)))
	)
	(var-set agent-14-status false)
	)
	true
	)
	(if (is-eq (var-get agent-16-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u107110000 tx-sender agent-16)))
	)
	(var-set agent-16-status false)
	)
	true
	)
	(if (is-eq (var-get agent-17-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u44100000 tx-sender agent-17)))
	)
	(var-set agent-17-status false)
	)
	true
	)
	(if (is-eq (var-get agent-18-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u23100000 tx-sender agent-18)))
	)
	(var-set agent-18-status false)
	)
	true
	)
	(if (is-eq (var-get agent-19-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u8410000 tx-sender agent-19)))
	)
	(var-set agent-19-status false)
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
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1811 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.satoshi-city transfer u2 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1614 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.punk-donuts transfer u284 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u4272 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales transfer u71 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-expansion-nft transfer u59931 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u20990000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u112 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10.airdropticket transfer u176 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u2100000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u945 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u14690000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u14 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d transfer u22 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u100000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u1680000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.luxury-jewellery transfer u1 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0.poseidon-awakening transfer u1 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.collection-one-life-vol-2 transfer u13 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1768 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1729 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.block-nights-i transfer u21 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.where-is-dr-suss-vol-i-san-miguel transfer u19 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3D0WY16NZXVTF8Q8849Y2R93GNWJ162RZF1D1VQ.poker-faces transfer u349 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP3J1ZP3R4MCMZ91KW1BFZWYKHEG553PX42C8H56E.sicko-sloths transfer u108 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u242 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2621 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2965 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3013 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u74 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-12-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-13)
		(begin
		(asserts! (is-eq (var-get agent-13-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC.seven-bitcoin-days transfer u1 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-13-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-14)
		(begin
		(asserts! (is-eq (var-get agent-14-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u10500000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-14-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-16)
		(begin
		(asserts! (is-eq (var-get agent-16-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u107110000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-16-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-17)
		(begin
		(asserts! (is-eq (var-get agent-17-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u44100000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-17-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-18)
		(begin
		(asserts! (is-eq (var-get agent-18-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u23100000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-18-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-19)
		(begin
		(asserts! (is-eq (var-get agent-19-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u8410000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-19-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) (var-get agent-18-status) (var-get agent-19-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12) (is-eq tx-sender agent-13) (is-eq tx-sender agent-14) (is-eq tx-sender agent-15) (is-eq tx-sender agent-16) (is-eq tx-sender agent-17) (is-eq tx-sender agent-18) (is-eq tx-sender agent-19))
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
