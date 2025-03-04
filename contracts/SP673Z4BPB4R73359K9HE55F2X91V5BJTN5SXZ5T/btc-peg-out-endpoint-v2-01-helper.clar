;; SPDX-License-Identifier: BUSL-1.1

(use-trait sip010-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-public (claim-and-finalize-peg-out (request-id uint) (fulfilled-by (buff 128))
	(tx (buff 32768))
	(block { header: (buff 80), height: uint })
	(proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
	(output-idx uint) (fulfilled-by-idx uint))
	(begin 
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 claim-peg-out request-id fulfilled-by))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 finalize-peg-out request-id tx block proof output-idx fulfilled-by-idx)))
