
;; SPDX-License-Identifier: BUSL-1.1

(use-trait proxy-trait .proxy-trait.proxy-trait)
(use-trait sip-010-transferable-trait .sip-010-transferable-trait.sip-010-transferable-trait)

(define-constant err-unauthorised (err u1000))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised))
)

(define-public (stx-transfer (amount uint) (recipient principal) (memo (optional (buff 34))))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (match memo
			to-print (stx-transfer-memo? amount tx-sender recipient to-print)
			(stx-transfer? amount tx-sender recipient)
		))
	)
)

(define-public (sip010-transfer (amount uint) (recipient principal) (memo (optional (buff 34))) (sip010 <sip-010-transferable-trait>))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? sip010 transfer amount (as-contract tx-sender) recipient memo)
	)
)

(define-public (proxy-call (proxy <proxy-trait>) (payload (buff 2048)))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? proxy proxy-call payload))
	)
)
