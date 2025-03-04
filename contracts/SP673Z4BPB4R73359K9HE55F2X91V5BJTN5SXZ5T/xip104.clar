;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(let (
			(peg-out-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
			(peg-out-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee))
			(token-details-bsc (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u2 })))
			(token-details-core (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u3 })))
			(token-details-base (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u16 })))
			(token-details-bitlayer (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u6 }))))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u2 } { fee: u0, min-fee: u0, min-amount: u0, max-amount: (get max-amount token-details-bsc), burnable: (get burnable token-details-bsc), approved: (get approved token-details-bsc) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u3 } { fee: u0, min-fee: u0, min-amount: u0, max-amount: (get max-amount token-details-core), burnable: (get burnable token-details-core), approved: (get approved token-details-core) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u16 } { fee: u0, min-fee: u0, min-amount: u0, max-amount: (get max-amount token-details-base), burnable: (get burnable token-details-base), approved: (get approved token-details-base) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u6 } { fee: u0, min-fee: u0, min-amount: u0, max-amount: (get max-amount token-details-bitlayer), burnable: (get burnable token-details-bitlayer), approved: (get approved token-details-bitlayer) }))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03b claim 
	u0
	(list (tuple (address 0x1d295335a342f39313dcb30b764140d39d68aedf) (chain-id none)) (tuple (address 0x6baf3e21c7b42f0d1b9a8f28d8ec026dc1fdcf0d) (chain-id none)) (tuple (address 0x6baf3e21c7b42f0d1b9a8f28d8ec026dc1fdcf0d) (chain-id none)) (tuple (address 0x6baf3e21c7b42f0d1b9a8f28d8ec026dc1fdcf0d) (chain-id none)) (tuple (address 0xbb8d784a430103105853c34b7ee1a5c5c7fdb313) (chain-id none)) (tuple (address 0x0ee2055b2178ffd0d6005cf3b30949a090f7fe2b) (chain-id none)) (tuple (address 0x0ee2055b2178ffd0d6005cf3b30949a090f7fe2b) (chain-id none)) (tuple (address 0x0ee2055b2178ffd0d6005cf3b30949a090f7fe2b) (chain-id none)) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x00144cc7e3c9d5ac8fda2f160191d2ec3e995b76dbcc) (chain-id (some u0))) (tuple (address 0x00144cc7e3c9d5ac8fda2f160191d2ec3e995b76dbcc) (chain-id (some u0))) (tuple (address 0x00144cc7e3c9d5ac8fda2f160191d2ec3e995b76dbcc) (chain-id (some u0))) (tuple (address 0x00143d4b9b0b6a7c4a430480e381c02e2e54b0ecd283) (chain-id (some u0))) (tuple (address 0x51203957a16684e58e466abc51def45d4ba2ec2ad5e0a01abc83863dc7fa0b5e8b92) (chain-id (some u0))))
	'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
	none
))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03b refund 
	u0 
	(list ) 
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03b claim 
	u1
	(list (tuple (address 0x1d295335a342f39313dcb30b764140d39d68aedf) (chain-id none)) (tuple (address 0x1d295335a342f39313dcb30b764140d39d68aedf) (chain-id none)) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))) (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))))
	'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
	none
))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03b refund 
	u1 
	(list (tuple (amount u6000) (recipient (tuple (address 0x1d295335a342f39313dcb30b764140d39d68aedf) (chain-id none)))) (tuple (amount u36000) (recipient (tuple (address 0x001487aba054763ede70d924424de9efbf5d7a2e77bb) (chain-id (some u0))))) (tuple (amount u6000) (recipient (tuple (address 0x51203957a16684e58e466abc51def45d4ba2ec2ad5e0a01abc83863dc7fa0b5e8b92) (chain-id (some u0))))) (tuple (amount u36000) (recipient (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u3))))) (tuple (amount u18000) (recipient (tuple (address 0x566632eecd46c7a7c49f6db558dfe79a9e88ac5d) (chain-id (some u16))))))
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee peg-out-fee))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee peg-out-min-fee))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u2 } { fee: (get fee token-details-bsc), min-fee: (get min-fee token-details-bsc), min-amount: (get min-amount token-details-bsc	), max-amount: (get max-amount token-details-bsc), burnable: (get burnable token-details-bsc), approved: (get approved token-details-bsc) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u3 } { fee: (get fee token-details-core), min-fee: (get min-fee token-details-core), min-amount: (get min-amount token-details-core), max-amount: (get max-amount token-details-core), burnable: (get burnable token-details-core), approved: (get approved token-details-core) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u16 } { fee: (get fee token-details-base), min-fee: (get min-fee token-details-base), min-amount: (get min-amount token-details-base), max-amount: (get max-amount token-details-base), burnable: (get burnable token-details-base), approved: (get approved token-details-base) }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u6 } { fee: (get fee token-details-bitlayer), min-fee: (get min-fee token-details-bitlayer), min-amount: (get min-amount token-details-bitlayer), max-amount: (get max-amount token-details-bitlayer), burnable: (get burnable token-details-bitlayer), approved: (get approved token-details-bitlayer) }))

(ok true)))
