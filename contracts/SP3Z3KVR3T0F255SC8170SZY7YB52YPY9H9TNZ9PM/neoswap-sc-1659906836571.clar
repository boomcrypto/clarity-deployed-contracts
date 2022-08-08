(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant agent-2 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant agent-3 'SP1P5CCXH4CKPQADFHMT1XSFHYEJ9JHSGARZWZ7TX)
(define-constant agent-4 'SP1QB7R583ESMCVADS6AM6DFXHGBEBPV608GK7A02)
(define-constant agent-5 'SP21YF95G993XR9WQDVWGZDMKKGA14N3CWYPPQV27)
(define-constant agent-6 'SP24NY3XPNPB5DC9QN1YQ3JF06CYV0T01AJTYEKDW)
(define-constant agent-7 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-8 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP)
(define-constant agent-9 'SP2WV5BRWCCZ9XSWDHMEZXW7Q60JP56J0WGD967B9)
(define-constant agent-10 'SP31PS877Y1B78QR7NQ1BCHS7EG0798WC52ZY6MD9)
(define-constant agent-11 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(define-constant agent-12 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20)
(define-constant agent-13 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-14 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2)
(define-constant agent-15 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1)
(define-constant agent-16 'SP3VGP209AWPK0W7MQHNP7F8CK43FEHGNKQP7BA2F)
(define-constant agent-17 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u169 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u499 tx-sender agent-1)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u12750000 tx-sender agent-2)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u22000000 tx-sender agent-3)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u45000000 tx-sender agent-4)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1693 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u360 tx-sender agent-5)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u22000000 tx-sender agent-6)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2RFR92YDK6JBZQ9FTKYBYSQWEW447N9N6SZKFSV.vaping-ape transfer u39 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN.glitched-crash-punks transfer u9 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2185 tx-sender agent-8)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u23000000 tx-sender agent-9)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u40000000 tx-sender agent-10)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1813 tx-sender agent-11)))
	(unwrap-panic (as-contract (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u100 tx-sender agent-12)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2043 tx-sender agent-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u293 tx-sender agent-13)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u912 tx-sender agent-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1687 tx-sender agent-14)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3003 tx-sender agent-14)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2630 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2631 tx-sender agent-15)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u505 tx-sender agent-15)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u19490000 tx-sender agent-16)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.guests-hosted-stacks-parrots transfer u3 tx-sender agent-17)))
		(as-contract (stx-transfer? u8500000 tx-sender agent-17)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u16960000 tx-sender agent-0)))
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
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1687 tx-sender agent-1)))
		(as-contract (stx-transfer? u20620000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u912 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u100 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u169 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u293 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2043 tx-sender agent-5)))
		(as-contract (stx-transfer? u24930000 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u360 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.guests-hosted-stacks-parrots transfer u3 tx-sender agent-7)))
		(as-contract (stx-transfer? u43500000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u17010000 tx-sender agent-8)))
	)
	(var-set agent-8-status false)
	)
	true
	)
	(if (is-eq (var-get agent-9-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u499 tx-sender agent-9)))
	(var-set agent-9-status false))
	true)
	(if (is-eq (var-get agent-10-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u505 tx-sender agent-10)))
	(var-set agent-10-status false))
	true)
	(if (is-eq (var-get agent-11-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u15750000 tx-sender agent-11)))
	)
	(var-set agent-11-status false)
	)
	true
	)
	(if (is-eq (var-get agent-12-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3003 tx-sender agent-12)))
		(as-contract (stx-transfer? u2760000 tx-sender agent-12)))
	)
	(var-set agent-12-status false)
	)
	true
	)
	(if (is-eq (var-get agent-13-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1693 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2630 tx-sender agent-13)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2631 tx-sender agent-13)))
		(as-contract (stx-transfer? u38140000 tx-sender agent-13)))
	)
	(var-set agent-13-status false)
	)
	true
	)
	(if (is-eq (var-get agent-14-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1813 tx-sender agent-14)))
		(as-contract (stx-transfer? u25330000 tx-sender agent-14)))
	)
	(var-set agent-14-status false)
	)
	true
	)
	(if (is-eq (var-get agent-15-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2RFR92YDK6JBZQ9FTKYBYSQWEW447N9N6SZKFSV.vaping-ape transfer u39 tx-sender agent-15)))
		(as-contract (stx-transfer? u21660000 tx-sender agent-15)))
	)
	(var-set agent-15-status false)
	)
	true
	)
	(if (is-eq (var-get agent-16-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2185 tx-sender agent-16)))
	(var-set agent-16-status false))
	true)
	(if (is-eq (var-get agent-17-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN.glitched-crash-punks transfer u9 tx-sender agent-17)))
	(var-set agent-17-status false))
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
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1687 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u20620000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u912 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u100 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u169 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u293 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2043 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u24930000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u360 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.guests-hosted-stacks-parrots transfer u3 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u43500000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u17010000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-8-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-9)
		(begin
		(asserts! (is-eq (var-get agent-9-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u499 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-9-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-10)
		(begin
		(asserts! (is-eq (var-get agent-10-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u505 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-10-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-11)
		(begin
		(asserts! (is-eq (var-get agent-11-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u15750000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-11-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-12)
		(begin
		(asserts! (is-eq (var-get agent-12-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u3003 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u2760000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-12-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-13)
		(begin
		(asserts! (is-eq (var-get agent-13-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1693 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2630 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2631 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u38140000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-13-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-14)
		(begin
		(asserts! (is-eq (var-get agent-14-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1813 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u25330000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-14-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-15)
		(begin
		(asserts! (is-eq (var-get agent-15-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2RFR92YDK6JBZQ9FTKYBYSQWEW447N9N6SZKFSV.vaping-ape transfer u39 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u21660000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-15-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-16)
		(begin
		(asserts! (is-eq (var-get agent-16-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u2185 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-16-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-17)
		(begin
		(asserts! (is-eq (var-get agent-17-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN.glitched-crash-punks transfer u9 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-17-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) (var-get agent-9-status) (var-get agent-10-status) (var-get agent-11-status) (var-get agent-12-status) (var-get agent-13-status) (var-get agent-14-status) (var-get agent-15-status) (var-get agent-16-status) (var-get agent-17-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8) (is-eq tx-sender agent-9) (is-eq tx-sender agent-10) (is-eq tx-sender agent-11) (is-eq tx-sender agent-12) (is-eq tx-sender agent-13) (is-eq tx-sender agent-14) (is-eq tx-sender agent-15) (is-eq tx-sender agent-16) (is-eq tx-sender agent-17))
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
