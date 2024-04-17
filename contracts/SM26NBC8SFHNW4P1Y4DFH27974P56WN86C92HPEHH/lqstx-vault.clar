
;; SPDX-License-Identifier: BUSL-1.1

;; This contract holds the STX of the members

(use-trait strategy-trait .strategy-trait.strategy-trait)
(use-trait proxy-trait .proxy-trait.proxy-trait)

(define-constant err-unauthorised (err u1000))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised)))

;; privileged calls

(define-public (fund-strategy (strategy <strategy-trait>) (payload (buff 2048)))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? strategy execute payload))
	)
)

(define-public (refund-strategy (strategy <strategy-trait>) (payload (buff 2048)))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? strategy refund payload))
	)
)

(define-public (proxy-call (proxy <proxy-trait>) (payload (buff 2048)))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? proxy proxy-call payload))
	)
)
