;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(begin	
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 approve-peg-in-address 0x512021ddb5ba2744f83b478b60b11dc2e206af6a9039a726deab55ae2e4beecb9e38 false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-registry-v2-01 approve-peg-in-address 0x5120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3 true))
(ok true)))
