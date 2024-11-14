---
title: "Trait xip049"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
  ;;  (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
      ;; { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01, enabled: false })))			

		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-endpoint-v2-03 true))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-out-endpoint-v2-03 true))
		;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-bridge-endpoint-v2-01 false))
		
		;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 pause true))
(ok true)))

```
