---
title: "Trait xip069"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 add-validator 0x03e33dce570d5bd07bc0b90a50fd07c6e0cb450884a95c35dac4b7df264c34d7c3 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1))

(ok true)))

```
