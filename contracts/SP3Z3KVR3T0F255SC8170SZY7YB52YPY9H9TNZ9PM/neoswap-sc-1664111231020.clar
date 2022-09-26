(use-trait nft 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant agent-1 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF)
(define-constant agent-2 'SPT0H6K5XMT9KDN6PQ69QN6XRFSJR6YAWQMTF3ZZ)
(define-constant agent-3 'SPVDF4YJER5QZD2PEY7WEDY6ZX6EQ36V1WN5XME)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)


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

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(as-contract (stx-transfer? u3080000 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4054 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3603 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.luxury-blobs transfer u15 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.rpgcharacters transfer u2705 tx-sender agent-2)))
		(as-contract (stx-transfer? u12640000 tx-sender agent-2)))
	)
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8588 tx-sender agent-3)))

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8588 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.luxury-blobs transfer u15 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3603 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4054 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.rpgcharacters transfer u2705 tx-sender agent-3)))
		(as-contract (stx-transfer? u15720000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
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
		(asserts! (is-ok (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8588 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u404 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.luxury-blobs transfer u15 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u3603 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4054 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.rpgcharacters transfer u2705 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u15720000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) true)
		(var-set contract-status u504)
		true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3))
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
