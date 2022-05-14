(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant agent-2 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63)
(define-constant agent-3 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
(define-constant agent-4 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B)
(define-constant agent-5 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-6 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
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


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status) (ok (var-get contract-status)))

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u2444 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u3982 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4334 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4635 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender agent-2)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u22520000 tx-sender agent-3)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender agent-4)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u8130000 tx-sender agent-5)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.bitcoin-on-the-beach transfer u100 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.okcoin-airdrop transfer u1740 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.gm-silver-airdrop transfer u88 tx-sender agent-6)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u3170000 tx-sender agent-0)))
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
		(unwrap-panic (as-contract (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.bitcoin-on-the-beach transfer u100 tx-sender agent-1)))
		(as-contract (stx-transfer? u9620000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.okcoin-airdrop transfer u1740 tx-sender agent-2)))
		(as-contract (stx-transfer? u3000000 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.gm-silver-airdrop transfer u88 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u3982 tx-sender agent-3)))
	(var-set agent-3-status false))
	true)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u8000000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u2444 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4334 tx-sender agent-5)))
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4635 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u13200000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)

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
		(asserts! (is-ok (contract-call? 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH.bitcoin-on-the-beach transfer u100 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u9620000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.okcoin-airdrop transfer u1740 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u3000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.gm-silver-airdrop transfer u88 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u7788 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u3982 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u8000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u2444 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4334 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u4635 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u13200000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true) (begin (unwrap-panic (release-escrow))) true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	(ok false))
))
