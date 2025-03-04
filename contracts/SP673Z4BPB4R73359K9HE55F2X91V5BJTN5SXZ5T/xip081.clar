;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .btc-peg-in-v2-05-swap, enabled: false }
{ extension: .btc-peg-in-v2-06-swap, enabled: true }
{ extension: .meta-peg-in-v2-04-swap, enabled: false }
{ extension: .meta-peg-in-v2-05-swap, enabled: true })))

(try! (contract-call? .btc-peg-in-v2-05-swap pause-peg-in true))
(try! (contract-call? .btc-peg-in-v2-06-swap pause-peg-in false))
(try! (contract-call? .meta-peg-in-v2-04-swap pause true))
(try! (contract-call? .meta-peg-in-v2-05-swap pause false))
(try! (contract-call? .meta-peg-in-v2-05-swap set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-04-swap false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-05-swap true))

(ok true)))
