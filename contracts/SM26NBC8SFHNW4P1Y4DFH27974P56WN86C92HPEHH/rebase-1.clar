
;; SPDX-License-Identifier: BUSL-1.1


(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

(define-public (rebase)
	(contract-call? .lisa-rebase rebase (list .public-pools-strategy))
)

(define-public (finalize-mint (request-id uint))
	(begin 
		(try! (rebase))
		(as-contract (try! (contract-call? .lqstx-mint-endpoint-v1-01 finalize-mint request-id)))
		(try! (rebase))
		(ok true)))

(define-public (finalize-burn (request-id uint))
	(begin 
		(try! (rebase))
		(as-contract (try! (contract-call? .lqstx-mint-endpoint-v1-01 finalize-burn request-id)))
		(try! (rebase))
		(ok true)))

(define-public (request-burn (amount uint))
	(let (
		(sender tx-sender)
		(send-token (try! (contract-call? .token-lqstx transfer amount sender (as-contract tx-sender) none)))
		(request-data (as-contract (try! (contract-call? .lqstx-mint-endpoint-v1-01 request-burn sender amount)))))
		(match (finalize-burn (get request-id request-data))
			ok-value (ok { request-id: (get request-id request-data), status: FINALIZED })
			err-value (ok request-data))))
