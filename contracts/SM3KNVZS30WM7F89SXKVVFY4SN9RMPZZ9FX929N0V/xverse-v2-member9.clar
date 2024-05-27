
;; SPDX-License-Identifier: BUSL-1.1
;; Pool member of Xverse (pox-4)
(define-constant err-unauthorised (err u5000))

(define-data-var pool-reward-pox-addr
	{ hashbytes: (buff 32), version: (buff 1) }
	{ hashbytes: 0x827a04335a9eb22cb46979f180670c8e7ba453b5, version: 0x04 }
)

(as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 allow-contract-caller 'SP001SFSMC2ZY76PD4M68P3WGX154XCH7NE3TYMX.pox4-pools none))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised))
)

(define-public (set-pool-reward-pox-addr (new-address { hashbytes: (buff 32), version: (buff 1) }))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set pool-reward-pox-addr new-address))
	)
)

(define-read-only (is-strategy-caller)
	(ok (asserts! (is-eq contract-caller .public-pools-strategy-v2) err-unauthorised))
)

(define-public (delegate-stx (amount uint))
	(begin
		(try! (is-strategy-caller))
		(try! (as-contract (contract-call? 'SP001SFSMC2ZY76PD4M68P3WGX154XCH7NE3TYMX.pox4-pools delegate-stx
			amount 'SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33 none none (var-get pool-reward-pox-addr) none)))
		(ok true)
	)
)

(define-public (revoke-delegate-stx)
	(begin
		(try! (is-strategy-caller))
		(match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx))
			ok-val (ok ok-val)
			err-val (err (to-uint err-val))
		)
	)
)

(define-public (refund-stx (recipient principal))
	(let ((balance (stx-get-balance (as-contract tx-sender))))
		(try! (is-strategy-caller))
		(try! (as-contract (stx-transfer? balance tx-sender recipient)))
		(ok balance)
	)
)

