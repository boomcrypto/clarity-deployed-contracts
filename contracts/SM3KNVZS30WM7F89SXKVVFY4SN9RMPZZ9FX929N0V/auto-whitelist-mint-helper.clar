
;; SPDX-License-Identifier: BUSL-1.1

;; snapshot block height for cycle #80 and #81
(define-constant stacks-snapshot-height1 u144186) ;; btc height 836387
(define-constant stacks-snapshot-height2 u142306) ;; btc height 834056

(define-constant fastpool-pox-address {version: 0x04, hashbytes: 0x83ed66860315e334010bbfb76eb3eef887efee0a}) ;; bc1qs0kkdpsrzh3ngqgth7mkavlwlzr7lms2zv3wxe
(define-constant xverse-pox-address {version: 0x04, hashbytes: 0xdb14133a9dbb1d0e16b60513453e48b6ff2847a9}) ;; bc1qmv2pxw5ahvwsu94kq5f520jgkmljs3af8ly6tr

(define-read-only (is-eligible-pox-address (pox-address { version: (buff 1), hashbytes: (buff 32) }))
	(or (is-eq pox-address fastpool-pox-address) (is-eq pox-address xverse-pox-address))
)

(define-read-only (is-whitelisted (who principal))
	(contract-call? .lqstx-mint-endpoint-v1-02 is-whitelisted-or-mint-for-all who)
)

(define-private (set-whitelisted (who principal))
	(contract-call? .lqstx-mint-endpoint-v1-02 set-whitelisted who true)
)

(define-read-only (was-stacking-in-eligible-pool-height (who principal) (height uint))
	(at-block (unwrap! (get-block-info? id-header-hash height) false)
		(is-eligible-pox-address (get pox-addr (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-stacker-info who) false)))
	)
)

(define-read-only (was-stacking-in-eligible-pool (who principal))
	(or
		(was-stacking-in-eligible-pool-height who stacks-snapshot-height1)
		(was-stacking-in-eligible-pool-height who stacks-snapshot-height2)
	)
)

(define-read-only (is-whitelisted-or-eligible (who principal))
	(or
		(is-whitelisted who)
		(was-stacking-in-eligible-pool who)
	)
)

(define-public (request-mint (amount uint))
	(begin
		(and
			(not (is-whitelisted tx-sender))
			(was-stacking-in-eligible-pool tx-sender)
			(try! (set-whitelisted tx-sender))
		)
		(contract-call? .lqstx-mint-endpoint-v1-02 request-mint amount)
	)
)
