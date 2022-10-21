(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP20BDA6WA8X478CV9YQ8DYK72W17R7K8MNJ40875)
(define-constant agent-2 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63)
(define-constant agent-3 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-4 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u57 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSP7FJR4TAZADS93NCAYMP5BXW77QDB42Y9SYC.block1-photogenesis transfer u3 tx-sender agent-1)))
		(as-contract (stx-transfer? u7466750 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u30 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9.round-face transfer u10 tx-sender agent-2)))
		(as-contract (stx-transfer? u1593000 tx-sender agent-2)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.mr-wagmis-adventure-volume-3 transfer u4 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP3R8APMXYQRQC6JZAE376ZDVKJAQG5KYMTPV3F9E.bitcoin-flowers transfer u198 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u10 tx-sender agent-3)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1226 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP2CV06TQ8B5NXKM6E66VCKYCS9FFDGEB8ZPK6JMR.citycats-nft transfer u248 tx-sender agent-4)))
		(as-contract (stx-transfer? u3809000 tx-sender agent-4)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u2265500 tx-sender agent-0)))
	)

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3R8APMXYQRQC6JZAE376ZDVKJAQG5KYMTPV3F9E.bitcoin-flowers transfer u198 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u30 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.mr-wagmis-adventure-volume-3 transfer u4 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1226 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9.round-face transfer u10 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2CV06TQ8B5NXKM6E66VCKYCS9FFDGEB8ZPK6JMR.citycats-nft transfer u248 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u57 tx-sender agent-3)))
		(as-contract (stx-transfer? u15134250 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u10 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSP7FJR4TAZADS93NCAYMP5BXW77QDB42Y9SYC.block1-photogenesis transfer u3 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender agent-4)))
	(var-set agent-4-status false))
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
		(asserts! (is-ok (contract-call? 'SP3R8APMXYQRQC6JZAE376ZDVKJAQG5KYMTPV3F9E.bitcoin-flowers transfer u198 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u30 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.mr-wagmis-adventure-volume-3 transfer u4 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs transfer u1226 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9.round-face transfer u10 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2CV06TQ8B5NXKM6E66VCKYCS9FFDGEB8ZPK6JMR.citycats-nft transfer u248 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u57 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u15134250 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u10 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSP7FJR4TAZADS93NCAYMP5BXW77QDB42Y9SYC.block1-photogenesis transfer u3 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4))
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
