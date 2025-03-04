;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(let (
			(peg-out-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
			(peg-out-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03a claim 
	u0
	(list (tuple (address 0x1d295335a342f39313dcb30b764140d39d68aedf) (chain-id none)) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u2))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u16))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))))
	'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
	none
))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03a refund 
	u0 
	(list ) 
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee peg-out-fee))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee peg-out-min-fee))

(ok true)))
