;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant REFUND_AMOUNT u11940460)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? .alex-launchpad-v2-03c transfer-all-to-dao 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-mineticket))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed REFUND_AMOUNT tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none))
		(ok true)))


