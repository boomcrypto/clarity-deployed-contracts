(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR)
(define-constant agent-2 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)
(define-constant agent-3 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant agent-4 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant agent-5 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E)
(define-constant agent-6 'SP3Y43V5ADNCGMBEY2N29VJSG8AE35W1SG5KK8DMB)
(define-constant agent-7 'SPKKH2MBR4FA5XWTTCE3NJZ85EDTBS283B9S2BFR)
(define-constant agent-8 'SPPCHF5474M4X5ZS79TCKSNRKJ24Y71J77ZKTAP3)
(define-constant agent-0 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)
(define-data-var agent-7-status bool false)
(define-data-var agent-8-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (as-contract (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u1036 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels transfer u93 tx-sender agent-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1051 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1345 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u2145 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u224 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u237 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u3417 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u407 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u662 tx-sender agent-2)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1387 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes transfer u15 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u17 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2288 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u361 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u364 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u49 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u50 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5333 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u592 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.stxnft-valentines-2022 transfer u76 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u11 tx-sender agent-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u412 tx-sender agent-4)))
	(unwrap-panic (begin
		(as-contract (stx-transfer? u15000000 tx-sender agent-5)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u17000000 tx-sender agent-6)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u740 tx-sender agent-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u743 tx-sender agent-7)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u441 tx-sender agent-8)))
		(as-contract (stx-transfer? u25000000 tx-sender agent-8)))
	)
	(unwrap-panic (begin
		(as-contract (stx-transfer? u21200000 tx-sender agent-0)))
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
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes transfer u15 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u17 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u3417 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5333 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u592 tx-sender agent-1)))
		(as-contract (stx-transfer? u11800000 tx-sender agent-1)))
	)
	(var-set agent-1-status false)
	)
	true
	)
	(if (is-eq (var-get agent-2-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2288 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u361 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u364 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.stxnft-valentines-2022 transfer u76 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels transfer u93 tx-sender agent-2)))
		(as-contract (stx-transfer? u11290000 tx-sender agent-2)))
	)
	(var-set agent-2-status false)
	)
	true
	)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u1036 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1051 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u11 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1345 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u412 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u237 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u441 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u740 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u743 tx-sender agent-3)))
		(as-contract (stx-transfer? u44240000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u9900000 tx-sender agent-4)))
	)
	(var-set agent-4-status false)
	)
	true
	)
	(if (is-eq (var-get agent-5-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender agent-5)))
	(var-set agent-5-status false))
	true)
	(if (is-eq (var-get agent-6-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u2145 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u224 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u407 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u662 tx-sender agent-6)))
	(var-set agent-6-status false))
	true)
	(if (is-eq (var-get agent-7-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1387 tx-sender agent-7)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u49 tx-sender agent-7)))
		(as-contract (stx-transfer? u970000 tx-sender agent-7)))
	)
	(var-set agent-7-status false)
	)
	true
	)
	(if (is-eq (var-get agent-8-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender agent-8)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u50 tx-sender agent-8)))
	(var-set agent-8-status false))
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
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes transfer u15 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community transfer u17 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u3417 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer u5333 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents transfer u592 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u11800000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2288 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u361 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxplates transfer u364 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.stxnft-valentines-2022 transfer u76 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels transfer u93 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u11290000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild transfer u1036 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-skaters transfer u1051 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u11 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1345 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels transfer u412 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u237 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala transfer u441 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u740 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-pixels transfer u743 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u44240000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (stx-transfer? u9900000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u401 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-giantpandas transfer u2145 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth transfer u224 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u407 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers transfer u662 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-6-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-7)
		(begin
		(asserts! (is-eq (var-get agent-7-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1387 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u49 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u970000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-7-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-8)
		(begin
		(asserts! (is-eq (var-get agent-8-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u2295 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-king transfer u50 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-8-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) (var-get agent-7-status) (var-get agent-8-status) true) (begin (unwrap-panic (release-escrow))) true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6) (is-eq tx-sender agent-7) (is-eq tx-sender agent-8))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	(ok false))
))
